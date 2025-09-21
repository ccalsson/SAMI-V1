import 'operator.dart';

abstract class OperatorsRepository {
  Future<List<Operator>> fetchOperators({String? query, String? status});
  Future<Operator> getOperator(String id);
  Future<Operator> createOperator(Operator operator);
  Future<Operator> updateOperator(String id, Map<String, dynamic> updates);
}
