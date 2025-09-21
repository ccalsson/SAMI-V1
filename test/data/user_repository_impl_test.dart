import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sami_app/core/utils/password_hasher.dart';
import 'package:sami_app/data/repositories/user_repository_impl.dart';
import 'package:sami_app/data/sources/local/hive_local_storage.dart';
import 'package:sami_app/data/sources/local/mock_seed_service.dart';
import 'package:sami_app/domain/entities/user.dart';

import '../test_utils/path_provider_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final fakePathProvider = FakePathProviderPlatform();
  PathProviderPlatform.instance = fakePathProvider;

  late Directory tempDir;
  late HiveLocalStorage storage;
  late PasswordHasher hasher;
  late MockSeedService seedService;
  late UserRepositoryImpl repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('user_repo_test');
    storage = HiveLocalStorage();
    await storage.init(directory: tempDir.path);
    hasher = PasswordHasher();
    seedService = MockSeedService(storage, hasher);
    await seedService.seed();
    repository = UserRepositoryImpl(storage, hasher);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  tearDownAll(() async {
    await fakePathProvider.dispose();
  });

  test('initial seeded user exists', () async {
    final users = await repository.getUsers();
    expect(users.any((user) => user.username == 'ClaudioC'), isTrue);
  });

  test('save and retrieve new user', () async {
    const user = User(
      username: 'Operario1',
      displayName: 'Operario 1',
      role: UserRole.operario,
      status: UserStatus.active,
    );
    await repository.saveUser(user, password: 'Clave12345');
    final stored = await repository.getByUsername('Operario1');
    expect(stored, isNotNull);
    expect(stored!.displayName, 'Operario 1');
  });

  test('delete user removes entry', () async {
    const user = User(
      username: 'Temporal',
      displayName: 'Temporal',
      role: UserRole.viewer,
      status: UserStatus.active,
    );
    await repository.saveUser(user, password: 'Temporal123');
    await repository.deleteUser('Temporal');
    final stored = await repository.getByUsername('Temporal');
    expect(stored, isNull);
  });
}
