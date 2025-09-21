import '../../../core/network/http_client.dart';
import '../models/admin_user_dto.dart';
import '../models/role_permissions_dto.dart';

class AdminRemoteDataSource {
  AdminRemoteDataSource(this._client);

  final AppHttpClient _client;

  Future<List<AdminUserDto>> fetchUsers() async {
    final response = await _client.get<List<dynamic>>('/admin/users');
    final data = response.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminUserDto.fromJson)
        .toList();
  }

  Future<AdminUserDto> createUser(Map<String, dynamic> body) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/admin/users',
      data: body,
    );
    return AdminUserDto.fromJson(response.data ?? const {});
  }

  Future<AdminUserDto> updateUser(String id, Map<String, dynamic> body) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/admin/users/$id',
      data: body,
    );
    return AdminUserDto.fromJson(response.data ?? const {});
  }

  Future<void> disableUser(String id) async {
    await _client.post('/admin/users/$id/disable');
  }

  Future<List<RolePermissionsDto>> fetchRoles() async {
    final response = await _client.get<List<dynamic>>('/admin/roles');
    final data = response.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(RolePermissionsDto.fromJson)
        .toList();
  }
}
