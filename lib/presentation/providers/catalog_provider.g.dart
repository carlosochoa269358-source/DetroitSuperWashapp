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
    r'ba55c455d8376ae6f93fbbceb4724532bc453226';

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
    r'bbc953f865b23fbc0561d3a67edd3b2ff1f4f741';

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

String _$vehicleTypesHash() => r'3cd4947f82998624515234fbfdea64b5b636d2c8';

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
    r'3c97133476d00f29a856a94eca2f21c879cc14c9';

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
    r'0608a919d3fabdfbb2dcdd0ac00980cfceabf310';

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

String _$serviceCategoriesHash() => r'95b9532905b9f8df26c9e6ebc84ced03eb3ce93d';

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

String _$serviceDataSourceHash() => r'ac365ab79707b9465ba714b6e93cb60d1e77e32f';

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

String _$serviceRepositoryHash() => r'aa02df85a63c8ceb5813dd633c59e242417a42dc';

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

String _$servicesHash() => r'789ba09268deecf9a56ce00b94d01a35bddc9f09';
