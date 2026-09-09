import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/vehicle_datasource.dart';
import '../../data/repositories/vehicle_repository_impl.dart';
import '../../domain/entities/vehicle_entity.dart';
import 'auth_provider.dart';

part 'vehicle_provider.g.dart';

@riverpod
VehicleDataSource vehicleDataSource(Ref ref) => VehicleDataSource();

@riverpod
VehicleRepositoryImpl vehicleRepository(Ref ref) {
  return VehicleRepositoryImpl(ref.watch(vehicleDataSourceProvider));
}

@riverpod
Future<List<VehicleEntity>> vehiclesByCustomer(Ref ref, String customerId) async {
  final repo = ref.watch(vehicleRepositoryProvider);
  final result = await repo.getByCustomer(customerId);
  return result.fold((failure) => throw Exception(failure.message), (list) => list);
}

@riverpod
Future<VehicleEntity?> vehicleByPlate(Ref ref, String plate) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return null;
  final repo = ref.watch(vehicleRepositoryProvider);
  final result = await repo.getByPlate(companyId: user.companyId, plate: plate);
  return result.fold((failure) => throw Exception(failure.message), (vehicle) => vehicle);
}
