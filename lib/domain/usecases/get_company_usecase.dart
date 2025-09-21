import 'package:sami_app/domain/entities/company.dart';
import 'package:sami_app/domain/repositories/company_repository.dart';

class GetCompanyUseCase {
  const GetCompanyUseCase(this._repository);

  final CompanyRepository _repository;

  Future<Company> call() => _repository.loadCompany();
}
