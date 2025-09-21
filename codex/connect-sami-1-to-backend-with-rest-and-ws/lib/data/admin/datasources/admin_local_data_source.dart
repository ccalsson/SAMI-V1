import '../../../core/database/cache_store.dart';
import '../models/admin_user_dto.dart';

class AdminLocalDataSource {
  AdminLocalDataSource(this._cacheStore);

  final CacheStore _cacheStore;

  static const _usersType = 'admin_users';

  Future<void> cacheUsers(List<AdminUserDto> users) async {
    await _cacheStore.saveAll(
      _usersType,
      users.map((dto) => dto.toJson()).toList(),
    );
  }

  Future<void> upsertUser(AdminUserDto user) async {
    await _cacheStore.saveOne(_usersType, user.id, user.toJson());
  }

  Future<List<AdminUserDto>> loadUsers() async {
    final cached = await _cacheStore.readAll(_usersType);
    return cached.map(AdminUserDto.fromJson).toList();
  }
}
