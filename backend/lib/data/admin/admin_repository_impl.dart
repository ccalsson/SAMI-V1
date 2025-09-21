import 'package:uuid/uuid.dart';

import '../../core/config/app_config.dart';
import '../../core/errors/app_error.dart';
import '../../core/logging/app_logger.dart';
import '../../core/offline/outbox_service.dart';
import '../../domain/admin/admin_repository.dart';
import '../../domain/admin/user_account.dart';
import '../../domain/auth/entities/app_user.dart';
import 'datasources/admin_local_data_source.dart';
import 'datasources/admin_remote_data_source.dart';
import 'models/admin_user_dto.dart';
import 'models/role_permissions_dto.dart';

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(
    this._remote,
    this._local,
    this._config,
    this._outbox,
    this._logger,
  );

  final AdminRemoteDataSource _remote;
  final AdminLocalDataSource _local;
  final AppConfig _config;
  final OutboxService _outbox;
  final AppLogger _logger;
  final _uuid = const Uuid();

  List<AdminUserAccount> _cachedUsers = <AdminUserAccount>[];
  List<RolePermissions> _cachedRoles = <RolePermissions>[];

  @override
  Future<List<AdminUserAccount>> fetchUsers() async {
    final cached = await _local.loadUsers();
    if (_cachedUsers.isEmpty && cached.isNotEmpty) {
      _cachedUsers = cached.map((dto) => dto.toDomain()).toList();
    }

    if (_config.isDemoMode) {
      _cachedUsers = _demoUsers;
      return _cachedUsers;
    }

    try {
      final dtos = await _remote.fetchUsers();
      await _local.cacheUsers(dtos);
      _cachedUsers = dtos.map((dto) => dto.toDomain()).toList();
      return _cachedUsers;
    } on AppError catch (error) {
      _logger.warn('Failed to fetch admin users', error);
      if (_cachedUsers.isNotEmpty && error.code.isNetworkError) {
        return _cachedUsers;
      }
      rethrow;
    }
  }

  @override
  Future<AdminUserAccount> createUser({
    required String username,
    required String displayName,
    required UserRole role,
  }) async {
    final user = AdminUserAccount(
      id: _uuid.v4(),
      username: username,
      displayName: displayName,
      role: role,
    );

    if (_config.isDemoMode) {
      _cachedUsers = [..._cachedUsers, user];
      await _local.cacheUsers(
        _cachedUsers.map(AdminUserDto.fromDomain).toList(),
      );
      return user;
    }

    final body = {
      'username': username,
      'displayName': displayName,
      'role': role.name,
    };
    try {
      final dto = await _remote.createUser(body);
      await _local.upsertUser(dto);
      final domain = dto.toDomain();
      _cachedUsers = [..._cachedUsers, domain];
      return domain;
    } on AppError catch (error) {
      if (error.code.isNetworkError) {
        _cachedUsers = [..._cachedUsers, user];
        await _local.cacheUsers(
          _cachedUsers.map(AdminUserDto.fromDomain).toList(),
        );
        await _outbox.enqueue(
          method: 'POST',
          endpoint: '/admin/users',
          body: body,
          reference: user.id,
        );
        return user;
      }
      rethrow;
    }
  }

  @override
  Future<AdminUserAccount> updateUser(String id, Map<String, dynamic> updates) async {
    if (_config.isDemoMode) {
      _cachedUsers = _cachedUsers
          .map(
            (user) => user.id == id
                ? AdminUserAccount(
                    id: user.id,
                    username: updates['username'] as String? ?? user.username,
                    displayName:
                        updates['displayName'] as String? ?? user.displayName,
                    role: updates['role'] != null
                        ? UserRole.values.firstWhere(
                            (value) => value.name ==
                                (updates['role'] as String).toLowerCase(),
                            orElse: () => user.role,
                          )
                        : user.role,
                    disabled: updates['disabled'] as bool? ?? user.disabled,
                  )
                : user,
          )
          .toList();
      await _local.cacheUsers(
        _cachedUsers.map(AdminUserDto.fromDomain).toList(),
      );
      return _cachedUsers.firstWhere((user) => user.id == id);
    }

    try {
      final dto = await _remote.updateUser(id, updates);
      await _local.upsertUser(dto);
      final domain = dto.toDomain();
      _cachedUsers = _cachedUsers
          .map((user) => user.id == id ? domain : user)
          .toList();
      return domain;
    } on AppError catch (error) {
      if (error.code.isNetworkError) {
        await _outbox.enqueue(
          method: 'PATCH',
          endpoint: '/admin/users/$id',
          body: updates,
          reference: id,
        );
        return _cachedUsers.firstWhere((user) => user.id == id);
      }
      rethrow;
    }
  }

  @override
  Future<void> disableUser(String id) async {
    if (_config.isDemoMode) {
      _cachedUsers = _cachedUsers
          .map((user) => user.id == id
              ? AdminUserAccount(
                  id: user.id,
                  username: user.username,
                  displayName: user.displayName,
                  role: user.role,
                  disabled: true,
                )
              : user)
          .toList();
      await _local.cacheUsers(
        _cachedUsers.map(AdminUserDto.fromDomain).toList(),
      );
      return;
    }
    try {
      await _remote.disableUser(id);
      _cachedUsers = _cachedUsers
          .map((user) => user.id == id
              ? AdminUserAccount(
                  id: user.id,
                  username: user.username,
                  displayName: user.displayName,
                  role: user.role,
                  disabled: true,
                )
              : user)
          .toList();
      await _local.cacheUsers(
        _cachedUsers.map(AdminUserDto.fromDomain).toList(),
      );
    } on AppError catch (error) {
      if (error.code.isNetworkError) {
        await _outbox.enqueue(
          method: 'POST',
          endpoint: '/admin/users/$id/disable',
          body: const {},
          reference: id,
        );
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<List<RolePermissions>> fetchRoles() async {
    if (_cachedRoles.isNotEmpty) {
      return _cachedRoles;
    }
    if (_config.isDemoMode) {
      _cachedRoles = _demoRoles;
      return _cachedRoles;
    }
    try {
      final dtos = await _remote.fetchRoles();
      _cachedRoles = dtos.map((dto) => dto.toDomain()).toList();
      return _cachedRoles;
    } on AppError catch (error) {
      _logger.warn('Failed to fetch role permissions', error);
      rethrow;
    }
  }

  List<AdminUserAccount> get _demoUsers => <AdminUserAccount>[
        AdminUserAccount(
          id: 'admin-1',
          username: 'admin',
          displayName: 'Administrador',
          role: UserRole.admin,
        ),
        AdminUserAccount(
          id: 'sup-1',
          username: 'supervisor',
          displayName: 'Supervisor',
          role: UserRole.supervisor,
        ),
      ];

  List<RolePermissions> get _demoRoles => <RolePermissions>[
        RolePermissions(role: UserRole.admin, permissions: {'users': true, 'projects': true}),
        RolePermissions(role: UserRole.supervisor, permissions: {'users': false, 'projects': true}),
        RolePermissions(role: UserRole.operario, permissions: {'users': false, 'projects': false}),
        RolePermissions(role: UserRole.viewer, permissions: {'users': false, 'projects': false}),
      ];
}
