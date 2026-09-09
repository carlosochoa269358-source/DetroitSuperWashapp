// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(vehicleTypeDataSource)
final vehicleTypeDataSourceProvider = VehicleTypeDataSourceProvider._();

final class VehicleTypeDataSourceProvider
    extends
        $FunctionalProvider<
          VehicleTypeDataSource,
          VehicleTypeDataSource,
          VehicleTypeDataSource
        >
    with $Provider<VehicleTypeDataSource> {
  VehicleTypeDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vehicleTypeDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vehicleTypeDataSourceHash();

  @$internal
  @override
  $ProviderElement<VehicleTypeDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VehicleTypeDataSource create(Ref ref) {
    return vehicleTypeDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VehicleTypeDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VehicleTypeDataSource>(value),
    );
  }
}

String _$vehicleTypeDataSourceHash() =>
    r'a02e8500f96dc89d626dcc885d9e398a3474606a';

@ProviderFor(vehicleTypeRepository)
final vehicleTypeRepositoryProvider = VehicleTypeRepositoryProvider._();

final class VehicleTypeRepositoryProvider
    extends
        $FunctionalProvider<
          VehicleTypeRepositoryImpl,
          VehicleTypeRepositoryImpl,
          VehicleTypeRepositoryImpl
        >
    with $Provider<VehicleTypeRepositoryImpl> {
  VehicleTypeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vehicleTypeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vehicleTypeRepositoryHash();

  @$internal
  @override
  $ProviderElement<VehicleTypeRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VehicleTypeRepositoryImpl create(Ref ref) {
    return vehicleTypeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VehicleTypeRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VehicleTypeRepositoryImpl>(value),
    );
  }
}

String _$vehicleTypeRepositoryHash() =>
    r'400dfa31f171e130c2e3f9563abf543e707cca2e';

@ProviderFor(vehicleTypes)
final vehicleTypesProvider = VehicleTypesProvider._();

final class VehicleTypesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VehicleTypeEntity>>,
          List<VehicleTypeEntity>,
          FutureOr<List<VehicleTypeEntity>>
        >
    with
        $FutureModifier<List<VehicleTypeEntity>>,
        $FutureProvider<List<VehicleTypeEntity>> {
  VehicleTypesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vehicleTypesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vehicleTypesHash();

  @$internal
  @override
  $FutureProviderElement<List<VehicleTypeEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<VehicleTypeEntity>> create(Ref ref) {
    return vehicleTypes(ref);
  }
}

String _$vehicleTypesHash() => r'e3ff119f52079b98e75d6ecaaa830aa20ee5c7f7';

@ProviderFor(serviceCategoryDataSource)
final serviceCategoryDataSourceProvider = ServiceCategoryDataSourceProvider._();

final class ServiceCategoryDataSourceProvider
    extends
        $FunctionalProvider<
          ServiceCategoryDataSource,
          ServiceCategoryDataSource,
          ServiceCategoryDataSource
        >
    with $Provider<ServiceCategoryDataSource> {
  ServiceCategoryDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceCategoryDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceCategoryDataSourceHash();

  @$internal
  @override
  $ProviderElement<ServiceCategoryDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ServiceCategoryDataSource create(Ref ref) {
    return serviceCategoryDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServiceCategoryDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServiceCategoryDataSource>(value),
    );
  }
}

String _$serviceCategoryDataSourceHash() =>
    r'80ba24d2ae30a9932fae0e9faecc9b3cd0328917';

@ProviderFor(serviceCategoryRepository)
final serviceCategoryRepositoryProvider = ServiceCategoryRepositoryProvider._();

final class ServiceCategoryRepositoryProvider
    extends
        $FunctionalProvider<
          ServiceCategoryRepositoryImpl,
          ServiceCategoryRepositoryImpl,
          ServiceCategoryRepositoryImpl
        >
    with $Provider<ServiceCategoryRepositoryImpl> {
  ServiceCategoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceCategoryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceCategoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<ServiceCategoryRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ServiceCategoryRepositoryImpl create(Ref ref) {
    return serviceCategoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServiceCategoryRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServiceCategoryRepositoryImpl>(
        value,
      ),
    );
  }
}

String _$serviceCategoryRepositoryHash() =>
    r'7a04b993d549596c2d59871d6eba939e1a63dec9';

@ProviderFor(serviceCategories)
final serviceCategoriesProvider = ServiceCategoriesProvider._();

final class ServiceCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ServiceCategoryEntity>>,
          List<ServiceCategoryEntity>,
          FutureOr<List<ServiceCategoryEntity>>
        >
    with
        $FutureModifier<List<ServiceCategoryEntity>>,
        $FutureProvider<List<ServiceCategoryEntity>> {
  ServiceCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceCategoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<ServiceCategoryEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ServiceCategoryEntity>> create(Ref ref) {
    return serviceCategories(ref);
  }
}

String _$serviceCategoriesHash() => r'b007944ab25e4a9efa5b5086c974af9c3df34bad';

@ProviderFor(serviceDataSource)
final serviceDataSourceProvider = ServiceDataSourceProvider._();

final class ServiceDataSourceProvider
    extends
        $FunctionalProvider<
          ServiceDataSource,
          ServiceDataSource,
          ServiceDataSource
        >
    with $Provider<ServiceDataSource> {
  ServiceDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceDataSourceHash();

  @$internal
  @override
  $ProviderElement<ServiceDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ServiceDataSource create(Ref ref) {
    return serviceDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServiceDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServiceDataSource>(value),
    );
  }
}

String _$serviceDataSourceHash() => r'32ef9913ee193e5c33761ca4c1cab42b32106f44';

@ProviderFor(serviceRepository)
final serviceRepositoryProvider = ServiceRepositoryProvider._();

final class ServiceRepositoryProvider
    extends
        $FunctionalProvider<
          ServiceRepositoryImpl,
          ServiceRepositoryImpl,
          ServiceRepositoryImpl
        >
    with $Provider<ServiceRepositoryImpl> {
  ServiceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceRepositoryHash();

  @$internal
  @override
  $ProviderElement<ServiceRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ServiceRepositoryImpl create(Ref ref) {
    return serviceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServiceRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServiceRepositoryImpl>(value),
    );
  }
}

String _$serviceRepositoryHash() => r'0773fad38623b1cfa3ca7f4482acccd77b9de0c6';

@ProviderFor(services)
final servicesProvider = ServicesProvider._();

final class ServicesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ServiceEntity>>,
          List<ServiceEntity>,
          FutureOr<List<ServiceEntity>>
        >
    with
        $FutureModifier<List<ServiceEntity>>,
        $FutureProvider<List<ServiceEntity>> {
  ServicesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'servicesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$servicesHash();

  @$internal
  @override
  $FutureProviderElement<List<ServiceEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ServiceEntity>> create(Ref ref) {
    return services(ref);
  }
}

String _$servicesHash() => r'd92b53a64b84324c3e2235dc06d2416f06f41dd0';
