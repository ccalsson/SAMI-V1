import 'package:uuid/uuid.dart';

import '../../core/config/app_config.dart';
import '../../core/errors/app_error.dart';
import '../../core/logging/app_logger.dart';
import '../../core/offline/outbox_service.dart';
import '../../domain/projects/project.dart';
import '../../domain/projects/projects_repository.dart';
import 'datasources/projects_local_data_source.dart';
import 'datasources/projects_remote_data_source.dart';
import 'models/project_dto.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  ProjectsRepositoryImpl(
    this._remote,
    this._local,
    this._config,
    this._outbox,
    this._logger,
  );

  final ProjectsRemoteDataSource _remote;
  final ProjectsLocalDataSource _local;
  final AppConfig _config;
  final OutboxService _outbox;
  final AppLogger _logger;
  final _uuid = const Uuid();

  List<Project> _cached = <Project>[];

  @override
  Future<List<Project>> fetchProjects({String? query, String? status}) async {
    final cached = await _local.loadProjects();
    if (_cached.isEmpty && cached.isNotEmpty) {
      _cached = cached.map((dto) => dto.toDomain()).toList();
    }

    if (_config.isDemoMode) {
      _cached = _demoProjects;
      return _cached;
    }

    final params = <String, dynamic>{
      'q': query,
      'status': status,
    }..removeWhere((key, value) => value == null || (value is String && value.isEmpty));

    try {
      final dtos = await _remote.fetchProjects(params);
      await _local.cacheProjects(dtos);
      _cached = dtos.map((dto) => dto.toDomain()).toList();
      return _cached;
    } on AppError catch (error) {
      _logger.warn('Failed to fetch projects', error);
      if (_cached.isNotEmpty && error.code.isNetworkError) {
        return _cached;
      }
      rethrow;
    }
  }

  @override
  Future<Project> getProject(String id) async {
    final existing = _cached.firstWhere(
      (project) => project.id == id,
      orElse: () => Project(
        id: '',
        name: '',
        status: ProjectStatus.planned,
        progressPct: 0,
        ownerId: '',
        startAt: DateTime.now(),
      ),
    );
    if (existing.id.isNotEmpty) {
      return existing;
    }

    if (_config.isDemoMode) {
      return _demoProjects.firstWhere((project) => project.id == id,
          orElse: () => _demoProjects.first);
    }

    final cached = await _local.loadProject(id);
    if (cached != null) {
      return cached.toDomain();
    }
    final dto = await _remote.getProject(id);
    await _local.upsertProject(dto);
    final domain = dto.toDomain();
    _cached = [..._cached.where((project) => project.id != id), domain];
    return domain;
  }

  @override
  Future<Project> createProject(Project project) async {
    final withId = project.id.isEmpty
        ? Project(
            id: _uuid.v4(),
            name: project.name,
            status: project.status,
            progressPct: project.progressPct,
            ownerId: project.ownerId,
            startAt: project.startAt,
            endAt: project.endAt,
            budget: project.budget,
          )
        : project;

    if (_config.isDemoMode) {
      _cached = [..._cached, withId];
      await _local.cacheProjects(
        _cached.map(ProjectDto.fromDomain).toList(),
      );
      return withId;
    }

    final dto = ProjectDto.fromDomain(withId);
    try {
      final created = await _remote.createProject(dto.toJson());
      await _local.upsertProject(created);
      final domain = created.toDomain();
      _cached = [..._cached, domain];
      return domain;
    } on AppError catch (error) {
      if (error.code.isNetworkError) {
        _cached = [..._cached, withId];
        await _local.cacheProjects(
          _cached.map(ProjectDto.fromDomain).toList(),
        );
        await _outbox.enqueue(
          method: 'POST',
          endpoint: '/projects',
          body: dto.toJson(),
          reference: withId.id,
        );
        return withId;
      }
      rethrow;
    }
  }

  @override
  Future<Project> updateProject(String id, Map<String, dynamic> updates) async {
    if (_config.isDemoMode) {
      _cached = _cached
          .map(
            (project) => project.id == id
                ? Project(
                    id: project.id,
                    name: updates['name'] as String? ?? project.name,
                    status: updates['status'] != null
                        ? ProjectStatus.values.firstWhere(
                            (value) => value.name ==
                                (updates['status'] as String).toLowerCase(),
                            orElse: () => project.status,
                          )
                        : project.status,
                    progressPct: (updates['progressPct'] as num?)?.toDouble() ??
                        project.progressPct,
                    ownerId: updates['ownerId'] as String? ?? project.ownerId,
                    startAt: project.startAt,
                    endAt: project.endAt,
                    budget: (updates['budget'] as num?)?.toDouble() ??
                        project.budget,
                  )
                : project,
          )
          .toList();
      await _local.cacheProjects(
        _cached.map(ProjectDto.fromDomain).toList(),
      );
      return _cached.firstWhere((project) => project.id == id);
    }

    try {
      final dto = await _remote.updateProject(id, updates);
      await _local.upsertProject(dto);
      final domain = dto.toDomain();
      _cached = _cached
          .map((project) => project.id == id ? domain : project)
          .toList();
      return domain;
    } on AppError catch (error) {
      if (error.code.isNetworkError) {
        await _outbox.enqueue(
          method: 'PATCH',
          endpoint: '/projects/$id',
          body: updates,
          reference: id,
        );
        return _cached.firstWhere((project) => project.id == id);
      }
      rethrow;
    }
  }

  List<Project> get _demoProjects => <Project>[
        Project(
          id: 'proj-1',
          name: 'Instalación sensores',
          status: ProjectStatus.active,
          progressPct: 65,
          ownerId: 'op-1',
          startAt: DateTime.now().subtract(const Duration(days: 30)),
          endAt: DateTime.now().add(const Duration(days: 10)),
          budget: 120000,
        ),
        Project(
          id: 'proj-2',
          name: 'Renovación cámaras',
          status: ProjectStatus.planned,
          progressPct: 10,
          ownerId: 'op-2',
          startAt: DateTime.now().add(const Duration(days: 7)),
        ),
      ];
}
