// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_register_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cashRegisterDataSource)
final cashRegisterDataSourceProvider = CashRegisterDataSourceProvider._();

final class CashRegisterDataSourceProvider
    extends
        $FunctionalProvider<
          CashRegisterDataSource,
          CashRegisterDataSource,
          CashRegisterDataSource
        >
    with $Provider<CashRegisterDataSource> {
  CashRegisterDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cashRegisterDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cashRegisterDataSourceHash();

  @$internal
  @override
  $ProviderElement<CashRegisterDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CashRegisterDataSource create(Ref ref) {
    return cashRegisterDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CashRegisterDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CashRegisterDataSource>(value),
    );
  }
}

String _$cashRegisterDataSourceHash() =>
    r'29101dc20dec85b28e89ecbae122978acd43d78c';

@ProviderFor(cashRegisterRepository)
final cashRegisterRepositoryProvider = CashRegisterRepositoryProvider._();

final class CashRegisterRepositoryProvider
    extends
        $FunctionalProvider<
          CashRegisterRepositoryImpl,
          CashRegisterRepositoryImpl,
          CashRegisterRepositoryImpl
        >
    with $Provider<CashRegisterRepositoryImpl> {
  CashRegisterRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cashRegisterRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cashRegisterRepositoryHash();

  @$internal
  @override
  $ProviderElement<CashRegisterRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CashRegisterRepositoryImpl create(Ref ref) {
    return cashRegisterRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CashRegisterRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CashRegisterRepositoryImpl>(value),
    );
  }
}

String _$cashRegisterRepositoryHash() =>
    r'9584302fe4c6922c7a0edf5acd0e5f4d83927267';

/// El turno abierto más antiguo para la empresa, sin importar la fecha
/// (si hay uno de un día anterior sin cerrar, este es el que hay que cerrar primero).

@ProviderFor(anyOpenCashRegister)
final anyOpenCashRegisterProvider = AnyOpenCashRegisterProvider._();

/// El turno abierto más antiguo para la empresa, sin importar la fecha
/// (si hay uno de un día anterior sin cerrar, este es el que hay que cerrar primero).

final class AnyOpenCashRegisterProvider
    extends
        $FunctionalProvider<
          AsyncValue<CashRegisterEntity?>,
          CashRegisterEntity?,
          FutureOr<CashRegisterEntity?>
        >
    with
        $FutureModifier<CashRegisterEntity?>,
        $FutureProvider<CashRegisterEntity?> {
  /// El turno abierto más antiguo para la empresa, sin importar la fecha
  /// (si hay uno de un día anterior sin cerrar, este es el que hay que cerrar primero).
  AnyOpenCashRegisterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'anyOpenCashRegisterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$anyOpenCashRegisterHash();

  @$internal
  @override
  $FutureProviderElement<CashRegisterEntity?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CashRegisterEntity?> create(Ref ref) {
    return anyOpenCashRegister(ref);
  }
}

String _$anyOpenCashRegisterHash() =>
    r'e796fefc556f2549fc72cef58be8ab221f0ebb14';

/// El turno de HOY ya abierto (null si no hay ninguno, o si el abierto es de un día anterior).

@ProviderFor(openCashRegisterToday)
final openCashRegisterTodayProvider = OpenCashRegisterTodayProvider._();

/// El turno de HOY ya abierto (null si no hay ninguno, o si el abierto es de un día anterior).

final class OpenCashRegisterTodayProvider
    extends
        $FunctionalProvider<
          AsyncValue<CashRegisterEntity?>,
          CashRegisterEntity?,
          FutureOr<CashRegisterEntity?>
        >
    with
        $FutureModifier<CashRegisterEntity?>,
        $FutureProvider<CashRegisterEntity?> {
  /// El turno de HOY ya abierto (null si no hay ninguno, o si el abierto es de un día anterior).
  OpenCashRegisterTodayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openCashRegisterTodayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openCashRegisterTodayHash();

  @$internal
  @override
  $FutureProviderElement<CashRegisterEntity?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CashRegisterEntity?> create(Ref ref) {
    return openCashRegisterToday(ref);
  }
}

String _$openCashRegisterTodayHash() =>
    r'adeb51aaab5239cac8a05d3d2b95ba12943d3914';

@ProviderFor(cashPaymentsTotal)
final cashPaymentsTotalProvider = CashPaymentsTotalFamily._();

final class CashPaymentsTotalProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
  CashPaymentsTotalProvider._({
    required CashPaymentsTotalFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'cashPaymentsTotalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cashPaymentsTotalHash();

  @override
  String toString() {
    return r'cashPaymentsTotalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<double> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double> create(Ref ref) {
    final argument = this.argument as String;
    return cashPaymentsTotal(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CashPaymentsTotalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cashPaymentsTotalHash() => r'3fa99082377682c7f1566e10797edb3b761fbdf3';

final class CashPaymentsTotalFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<double>, String> {
  CashPaymentsTotalFamily._()
    : super(
        retry: null,
        name: r'cashPaymentsTotalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CashPaymentsTotalProvider call(String cashRegisterId) =>
      CashPaymentsTotalProvider._(argument: cashRegisterId, from: this);

  @override
  String toString() => r'cashPaymentsTotalProvider';
}

/// Desglose de dinero recibido en el turno por método de pago, para Caja.

@ProviderFor(paymentMethodTotals)
final paymentMethodTotalsProvider = PaymentMethodTotalsFamily._();

/// Desglose de dinero recibido en el turno por método de pago, para Caja.

final class PaymentMethodTotalsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PaymentMethodTotal>>,
          List<PaymentMethodTotal>,
          FutureOr<List<PaymentMethodTotal>>
        >
    with
        $FutureModifier<List<PaymentMethodTotal>>,
        $FutureProvider<List<PaymentMethodTotal>> {
  /// Desglose de dinero recibido en el turno por método de pago, para Caja.
  PaymentMethodTotalsProvider._({
    required PaymentMethodTotalsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'paymentMethodTotalsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$paymentMethodTotalsHash();

  @override
  String toString() {
    return r'paymentMethodTotalsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PaymentMethodTotal>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PaymentMethodTotal>> create(Ref ref) {
    final argument = this.argument as String;
    return paymentMethodTotals(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PaymentMethodTotalsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$paymentMethodTotalsHash() =>
    r'9a9f59fb54f43ee9a2a7607936fba06056c7fc96';

/// Desglose de dinero recibido en el turno por método de pago, para Caja.

final class PaymentMethodTotalsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PaymentMethodTotal>>, String> {
  PaymentMethodTotalsFamily._()
    : super(
        retry: null,
        name: r'paymentMethodTotalsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Desglose de dinero recibido en el turno por método de pago, para Caja.

  PaymentMethodTotalsProvider call(String cashRegisterId) =>
      PaymentMethodTotalsProvider._(argument: cashRegisterId, from: this);

  @override
  String toString() => r'paymentMethodTotalsProvider';
}

/// Cuántos servicios se hicieron en el turno y su valor sumado, para Caja.

@ProviderFor(servicesSummary)
final servicesSummaryProvider = ServicesSummaryFamily._();

/// Cuántos servicios se hicieron en el turno y su valor sumado, para Caja.

final class ServicesSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ServicesSummaryEntity>,
          ServicesSummaryEntity,
          FutureOr<ServicesSummaryEntity>
        >
    with
        $FutureModifier<ServicesSummaryEntity>,
        $FutureProvider<ServicesSummaryEntity> {
  /// Cuántos servicios se hicieron en el turno y su valor sumado, para Caja.
  ServicesSummaryProvider._({
    required ServicesSummaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'servicesSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$servicesSummaryHash();

  @override
  String toString() {
    return r'servicesSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ServicesSummaryEntity> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ServicesSummaryEntity> create(Ref ref) {
    final argument = this.argument as String;
    return servicesSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ServicesSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$servicesSummaryHash() => r'102b11938a2c57da360f335ece2a757305a40625';

/// Cuántos servicios se hicieron en el turno y su valor sumado, para Caja.

final class ServicesSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ServicesSummaryEntity>, String> {
  ServicesSummaryFamily._()
    : super(
        retry: null,
        name: r'servicesSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Cuántos servicios se hicieron en el turno y su valor sumado, para Caja.

  ServicesSummaryProvider call(String cashRegisterId) =>
      ServicesSummaryProvider._(argument: cashRegisterId, from: this);

  @override
  String toString() => r'servicesSummaryProvider';
}

/// Turnos cerrados de la empresa, para la pantalla de historial.

@ProviderFor(closedCashRegisters)
final closedCashRegistersProvider = ClosedCashRegistersProvider._();

/// Turnos cerrados de la empresa, para la pantalla de historial.

final class ClosedCashRegistersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CashRegisterEntity>>,
          List<CashRegisterEntity>,
          FutureOr<List<CashRegisterEntity>>
        >
    with
        $FutureModifier<List<CashRegisterEntity>>,
        $FutureProvider<List<CashRegisterEntity>> {
  /// Turnos cerrados de la empresa, para la pantalla de historial.
  ClosedCashRegistersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'closedCashRegistersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$closedCashRegistersHash();

  @$internal
  @override
  $FutureProviderElement<List<CashRegisterEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CashRegisterEntity>> create(Ref ref) {
    return closedCashRegisters(ref);
  }
}

String _$closedCashRegistersHash() =>
    r'7dc995e6baff032e766de739edd5472839d38108';
