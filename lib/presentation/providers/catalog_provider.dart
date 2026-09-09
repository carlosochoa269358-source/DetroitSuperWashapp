import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/service_category_datasource.dart';
import '../../data/datasources/service_datasource.dart';
import '../../data/datasources/vehicle_type_datasource.dart';
import '../../data/repositories/service_category_repository_impl.dart';
import '../../data/repositories/service_repository_impl.dart';
import '../../data/repositories/vehicle_type_repository_impl.dart';
import '../../domain/entities/service_category_entity.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/entities/vehicle_type_entity.dart';
import 'auth_provider.dart';

part 'catalog_provider.g.dart';

@riverpod
VehicleTypeDataSource vehicleTypeDataSource(Ref ref) => VehicleTypeDataSource();

@riverpod
VehicleTypeRepositoryImpl vehicleTypeRepository(Ref ref) {
  return VehicleTypeRepositoryImpl(ref.watch(vehicleTypeDataSourceProvider));
}

@riverpod
Future<List<VehicleTypeEntity>> vehicleTypes(Ref ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return [];
  final repo = ref.watch(vehicleTypeRepositoryProvider);
  final result = await repo.getAll(user.companyId);
  return result.fold((failure) => throw Exception(failure.message), (list) => list);
}

@riverpod
ServiceCategoryDataSource serviceCategoryDataSource(Ref ref) => ServiceCategoryDataSource();

@riverpod
ServiceCategoryRepositoryImpl serviceCategoryRepository(Ref ref) {
  return ServiceCategoryRepositoryImpl(ref.watch(serviceCategoryDataSourceProvider));
}

@riverpod
Future<List<ServiceCategoryEntity>> serviceCategories(Ref ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return [];
  final repo = ref.watch(serviceCategoryRepositoryProvider);
  final result = await repo.getAll(user.companyId);
  return result.fold((failure) => throw Exception(failure.message), (list) => list);
}

@riverpod
ServiceDataSource serviceDataSource(Ref ref) => ServiceDataSource();

@riverpod
ServiceRepositoryImpl serviceRepository(Ref ref) {
  return ServiceRepositoryImpl(ref.watch(serviceDataSourceProvider));
}

@riverpod
Future<List<ServiceEntity>> services(Ref ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return [];
  final repo = ref.watch(serviceRepositoryProvider);
  final result = await repo.getAll(user.companyId);
  return result.fold((failure) => throw Exception(failure.message), (list) => list);
}
