import 'package:sami_app/domain/entities/company.dart';
import 'package:sami_app/domain/repositories/company_repository.dart';

class SaveCompanyUseCase {
  const SaveCompanyUseCase(this._repository);

  final CompanyRepository _repository;

  Future<void> call(Company company) => _repository.saveCompany(company);
}
