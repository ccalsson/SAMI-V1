import 'package:sami_app/data/models/company_model.dart';
import 'package:sami_app/data/sources/local/hive_local_storage.dart';
import 'package:sami_app/domain/entities/company.dart';
import 'package:sami_app/domain/repositories/company_repository.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  CompanyRepositoryImpl(this._storage);

  final HiveLocalStorage _storage;

  @override
  Future<Company> loadCompany() async {
    final companyBox = _storage.box(HiveLocalStorage.companyBox);
    final Map<String, dynamic>? raw = companyBox.get('company');
    if (raw == null) {
      return const Company(id: 'company_1', name: 'Empresa');
    }
    return CompanyModel.fromMap(raw).toEntity();
  }

  @override
  Future<void> saveCompany(Company company) async {
    final companyBox = _storage.box(HiveLocalStorage.companyBox);
    await companyBox.put('company', CompanyModel.fromEntity(company).toMap());
  }
}
