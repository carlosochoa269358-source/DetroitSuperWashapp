// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(vehicleDataSource)
final vehicleDataSourceProvider = VehicleDataSourceProvider._();

final class VehicleDataSourceProvider
    extends
        $FunctionalProvider<
          VehicleDataSource,
          VehicleDataSource,
          VehicleDataSource
        >
    with $Provider<VehicleDataSource> {
  VehicleDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vehicleDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vehicleDataSourceHash();

  @$internal
  @override
  $ProviderElement<VehicleDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VehicleDataSource create(Ref ref) {
    return vehicleDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VehicleDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VehicleDataSource>(value),
    );
  }
}

String _$vehicleDataSourceHash() => r'8652fce11e6ff993f292f4db8437d1b3bccdbb6b';

@ProviderFor(vehicleRepository)
final vehicleRepositoryProvider = VehicleRepositoryProvider._();

final class VehicleRepositoryProvider
    extends
        $FunctionalProvider<
          VehicleRepositoryImpl,
          VehicleRepositoryImpl,
          VehicleRepositoryImpl
        >
    with $Provider<VehicleRepositoryImpl> {
  VehicleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vehicleRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vehicleRepositoryHash();

  @$internal
  @override
  $ProviderElement<VehicleRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VehicleRepositoryImpl create(Ref ref) {
    return vehicleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VehicleRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VehicleRepositoryImpl>(value),
    );
  }
}

String _$vehicleRepositoryHash() => r'5419f892518eb6cba51bf41ed7f2a05e8a811c38';

@ProviderFor(vehiclesByCustomer)
final vehiclesByCustomerProvider = VehiclesByCustomerFamily._();

final class VehiclesByCustomerProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VehicleEntity>>,
          List<VehicleEntity>,
          FutureOr<List<VehicleEntity>>
        >
    with
        $FutureModifier<List<VehicleEntity>>,
        $FutureProvider<List<VehicleEntity>> {
  VehiclesByCustomerProvider._({
    required VehiclesByCustomerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'vehiclesByCustomerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vehiclesByCustomerHash();

  @override
  String toString() {
    return r'vehiclesByCustomerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<VehicleEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<VehicleEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return vehiclesByCustomer(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is VehiclesByCustomerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vehiclesByCustomerHash() =>
    r'fac10ca5145ff8be54dc771b67f44c35ad1741b3';

final class VehiclesByCustomerFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<VehicleEntity>>, String> {
  VehiclesByCustomerFamily._()
    : super(
        retry: null,
        name: r'vehiclesByCustomerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  VehiclesByCustomerProvider call(String customerId) =>
      VehiclesByCustomerProvider._(argument: customerId, from: this);

  @override
  String toString() => r'vehiclesByCustomerProvider';
}

@ProviderFor(vehicleByPlate)
final vehicleByPlateProvider = VehicleByPlateFamily._();

final class VehicleByPlateProvider
    extends
        $FunctionalProvider<
          AsyncValue<VehicleEntity?>,
          VehicleEntity?,
          FutureOr<VehicleEntity?>
        >
    with $FutureModifier<VehicleEntity?>, $FutureProvider<VehicleEntity?> {
  VehicleByPlateProvider._({
    required VehicleByPlateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'vehicleByPlateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vehicleByPlateHash();

  @override
  String toString() {
    return r'vehicleByPlateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<VehicleEntity?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<VehicleEntity?> create(Ref ref) {
    final argument = this.argument as String;
    return vehicleByPlate(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is VehicleByPlateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vehicleByPlateHash() => r'9283a0c96d28e110039d18d5c8bff5965407ae1e';

final class VehicleByPlateFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<VehicleEntity?>, String> {
  VehicleByPlateFamily._()
    : super(
        retry: null,
        name: r'vehicleByPlateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  VehicleByPlateProvider call(String plate) =>
      VehicleByPlateProvider._(argument: plate, from: this);

  @override
  String toString() => r'vehicleByPlateProvider';
}

/// Búsqueda parcial de placas (cualquier coincidencia, no exacta) para
/// "Buscar por placa".

@ProviderFor(vehicleSearchByPlate)
final vehicleSearchByPlateProvider = VehicleSearchByPlateFamily._();

/// Búsqueda parcial de placas (cualquier coincidencia, no exacta) para
/// "Buscar por placa".

final class VehicleSearchByPlateProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VehicleEntity>>,
          List<VehicleEntity>,
          FutureOr<List<VehicleEntity>>
        >
    with
        $FutureModifier<List<VehicleEntity>>,
        $FutureProvider<List<VehicleEntity>> {
  /// Búsqueda parcial de placas (cualquier coincidencia, no exacta) para
  /// "Buscar por placa".
  VehicleSearchByPlateProvider._({
    required VehicleSearchByPlateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'vehicleSearchByPlateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vehicleSearchByPlateHash();

  @override
  String toString() {
    return r'vehicleSearchByPlateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<VehicleEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<VehicleEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return vehicleSearchByPlate(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is VehicleSearchByPlateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vehicleSearchByPlateHash() =>
    r'df6c342738d68641528b8c6500f6d78cab908e3d';

/// Búsqueda parcial de placas (cualquier coincidencia, no exacta) para
/// "Buscar por placa".

final class VehicleSearchByPlateFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<VehicleEntity>>, String> {
  VehicleSearchByPlateFamily._()
    : super(
        retry: null,
        name: r'vehicleSearchByPlateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Búsqueda parcial de placas (cualquier coincidencia, no exacta) para
  /// "Buscar por placa".

  VehicleSearchByPlateProvider call(String query) =>
      VehicleSearchByPlateProvider._(argument: query, from: this);

  @override
  String toString() => r'vehicleSearchByPlateProvider';
}
