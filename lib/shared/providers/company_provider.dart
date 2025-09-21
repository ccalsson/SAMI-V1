import 'package:flutter/foundation.dart';
import 'package:sami_app/domain/entities/company.dart';
import 'package:sami_app/domain/usecases/get_company_usecase.dart';
import 'package:sami_app/domain/usecases/save_company_usecase.dart';

class CompanyProvider extends ChangeNotifier {
  CompanyProvider({
    required GetCompanyUseCase getCompany,
    required SaveCompanyUseCase saveCompany,
  })  : _getCompany = getCompany,
        _saveCompany = saveCompany;

  final GetCompanyUseCase _getCompany;
  final SaveCompanyUseCase _saveCompany;

  Company _company = const Company(id: 'company_1', name: 'Empresa');
  bool _loading = true;

  Company get company => _company;
  bool get isLoading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _company = await _getCompany();
    _loading = false;
    notifyListeners();
  }

  Future<void> updateCompany({String? name, String? logoPath}) async {
    _company = _company.copyWith(name: name, logoPath: logoPath);
    await _saveCompany(_company);
    notifyListeners();
  }
}
