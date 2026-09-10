import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/employee_datasource.dart';
import '../../data/repositories/employee_repository_impl.dart';
import '../../domain/entities/employee_entity.dart';
import 'auth_provider.dart';

part 'employee_provider.g.dart';

@riverpod
EmployeeDataSource employeeDataSource(Ref ref) => EmployeeDataSource();

@riverpod
EmployeeRepositoryImpl employeeRepository(Ref ref) {
  return EmployeeRepositoryImpl(ref.watch(employeeDataSourceProvider));
}

@riverpod
Future<List<EmployeeEntity>> employees(Ref ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return [];
  final repo = ref.watch(employeeRepositoryProvider);
  final result = await repo.getAll(user.companyId);
  return result.fold((failure) => throw Exception(failure.message), (list) => list);
}
