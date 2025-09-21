import 'package:sami_app/domain/entities/company.dart';

abstract class CompanyRepository {
  Future<Company> loadCompany();
  Future<void> saveCompany(Company company);
}
