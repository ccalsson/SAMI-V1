import 'package:flutter_test/flutter_test.dart';
import 'package:sami_app/domain/entities/user.dart';
import 'package:sami_app/shared/providers/menu_provider.dart';

void main() {
  test('MenuProvider genera menú base y módulos', () {
    final provider = MenuProvider();
    provider.updateFor(role: UserRole.admin, modules: const ['production']);
    final paths = provider.items.map((item) => item.path).toList();
    expect(paths, contains('/dashboard'));
    expect(paths, contains('/module/production'));
  });

  test('MenuProvider filtra ítems sin scope para operario', () {
    final provider = MenuProvider();
    provider.updateFor(role: UserRole.operario, modules: const []);
    final paths = provider.items.map((item) => item.path).toList();
    expect(paths, contains('/dashboard'));
    expect(paths, isNot(contains('/alerts')));
  });
}
