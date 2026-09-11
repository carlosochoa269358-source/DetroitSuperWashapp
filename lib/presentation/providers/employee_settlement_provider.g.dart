// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_settlement_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(employeeSettlementDataSource)
final employeeSettlementDataSourceProvider =
    EmployeeSettlementDataSourceProvider._();

final class EmployeeSettlementDataSourceProvider
    extends
        $FunctionalProvider<
          EmployeeSettlementDataSource,
          EmployeeSettlementDataSource,
          EmployeeSettlementDataSource
        >
    with $Provider<EmployeeSettlementDataSource> {
  EmployeeSettlementDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'employeeSettlementDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$employeeSettlementDataSourceHash();

  @$internal
  @override
  $ProviderElement<EmployeeSettlementDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EmployeeSettlementDataSource create(Ref ref) {
    return employeeSettlementDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EmployeeSettlementDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EmployeeSettlementDataSource>(value),
    );
  }
}

String _$employeeSettlementDataSourceHash() =>
    r'4b797cff0cbb587dd064bcf9ce33bd29fcb0e221';

@ProviderFor(employeeSettlementRepository)
final employeeSettlementRepositoryProvider =
    EmployeeSettlementRepositoryProvider._();

final class EmployeeSettlementRepositoryProvider
    extends
        $FunctionalProvider<
          EmployeeSettlementRepositoryImpl,
          EmployeeSettlementRepositoryImpl,
          EmployeeSettlementRepositoryImpl
        >
    with $Provider<EmployeeSettlementRepositoryImpl> {
  EmployeeSettlementRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'employeeSettlementRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$employeeSettlementRepositoryHash();

  @$internal
  @override
  $ProviderElement<EmployeeSettlementRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EmployeeSettlementRepositoryImpl create(Ref ref) {
    return employeeSettlementRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EmployeeSettlementRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EmployeeSettlementRepositoryImpl>(
        value,
      ),
    );
  }
}

String _$employeeSettlementRepositoryHash() =>
    r'5451ead0767552f603c8a47c8b36dba5ebc8c5e9';

/// Cuánto se le debe a cada trabajador activo (comisión de órdenes ya
/// pagadas, sin liquidar), para la tarjeta de Liquidación en Caja.

@ProviderFor(employeePendingSummary)
final employeePendingSummaryProvider = EmployeePendingSummaryProvider._();

/// Cuánto se le debe a cada trabajador activo (comisión de órdenes ya
/// pagadas, sin liquidar), para la tarjeta de Liquidación en Caja.

final class EmployeePendingSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EmployeePendingSummaryEntity>>,
          List<EmployeePendingSummaryEntity>,
          FutureOr<List<EmployeePendingSummaryEntity>>
        >
    with
        $FutureModifier<List<EmployeePendingSummaryEntity>>,
        $FutureProvider<List<EmployeePendingSummaryEntity>> {
  /// Cuánto se le debe a cada trabajador activo (comisión de órdenes ya
  /// pagadas, sin liquidar), para la tarjeta de Liquidación en Caja.
  EmployeePendingSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'employeePendingSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$employeePendingSummaryHash();

  @$internal
  @override
  $FutureProviderElement<List<EmployeePendingSummaryEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<EmployeePendingSummaryEntity>> create(Ref ref) {
    return employeePendingSummary(ref);
  }
}

String _$employeePendingSummaryHash() =>
    r'75c372bbbd20dbb6f73632c9057bb33ff6130a57';
