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

String _$vehicleDataSourceHash() => r'4fc9da9c31c41c58ae9e8cc2550e661c854da5aa';

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

String _$vehicleRepositoryHash() => r'728a29cdcb8c353bae73513b0398a88ebe53e58f';

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
    r'20f8628970a7ecc55ea997072c9da20f32146b05';

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

String _$vehicleByPlateHash() => r'e20f86c802092ad4b1e58cb27c247fb486d33536';

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
