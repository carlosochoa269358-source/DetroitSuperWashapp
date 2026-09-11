// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_order_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(serviceOrderDataSource)
final serviceOrderDataSourceProvider = ServiceOrderDataSourceProvider._();

final class ServiceOrderDataSourceProvider
    extends
        $FunctionalProvider<
          ServiceOrderDataSource,
          ServiceOrderDataSource,
          ServiceOrderDataSource
        >
    with $Provider<ServiceOrderDataSource> {
  ServiceOrderDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceOrderDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceOrderDataSourceHash();

  @$internal
  @override
  $ProviderElement<ServiceOrderDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ServiceOrderDataSource create(Ref ref) {
    return serviceOrderDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServiceOrderDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServiceOrderDataSource>(value),
    );
  }
}

String _$serviceOrderDataSourceHash() =>
    r'235b947812e449fdaab1ddd07bc0245176212545';

@ProviderFor(serviceOrderRepository)
final serviceOrderRepositoryProvider = ServiceOrderRepositoryProvider._();

final class ServiceOrderRepositoryProvider
    extends
        $FunctionalProvider<
          ServiceOrderRepositoryImpl,
          ServiceOrderRepositoryImpl,
          ServiceOrderRepositoryImpl
        >
    with $Provider<ServiceOrderRepositoryImpl> {
  ServiceOrderRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceOrderRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceOrderRepositoryHash();

  @$internal
  @override
  $ProviderElement<ServiceOrderRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ServiceOrderRepositoryImpl create(Ref ref) {
    return serviceOrderRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServiceOrderRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServiceOrderRepositoryImpl>(value),
    );
  }
}

String _$serviceOrderRepositoryHash() =>
    r'a817b742d3c60dad207424d17bb4c8e21717a6a6';

/// Nuevas/Finalizadas/Pagadas solo muestran lo del turno abierto actual — al
/// cerrar el turno, esas listas se vacían (el dato queda archivado bajo ese
/// turno, ver [ordersCreatedInRegisterProvider]/[ordersPaidInRegisterProvider]).
/// "Por Cobrar" (fiados) no pasa por aquí — no se escopa por turno.

@ProviderFor(serviceOrdersByStatus)
final serviceOrdersByStatusProvider = ServiceOrdersByStatusFamily._();

/// Nuevas/Finalizadas/Pagadas solo muestran lo del turno abierto actual — al
/// cerrar el turno, esas listas se vacían (el dato queda archivado bajo ese
/// turno, ver [ordersCreatedInRegisterProvider]/[ordersPaidInRegisterProvider]).
/// "Por Cobrar" (fiados) no pasa por aquí — no se escopa por turno.

final class ServiceOrdersByStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ServiceOrderEntity>>,
          List<ServiceOrderEntity>,
          FutureOr<List<ServiceOrderEntity>>
        >
    with
        $FutureModifier<List<ServiceOrderEntity>>,
        $FutureProvider<List<ServiceOrderEntity>> {
  /// Nuevas/Finalizadas/Pagadas solo muestran lo del turno abierto actual — al
  /// cerrar el turno, esas listas se vacían (el dato queda archivado bajo ese
  /// turno, ver [ordersCreatedInRegisterProvider]/[ordersPaidInRegisterProvider]).
  /// "Por Cobrar" (fiados) no pasa por aquí — no se escopa por turno.
  ServiceOrdersByStatusProvider._({
    required ServiceOrdersByStatusFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'serviceOrdersByStatusProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$serviceOrdersByStatusHash();

  @override
  String toString() {
    return r'serviceOrdersByStatusProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ServiceOrderEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ServiceOrderEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return serviceOrdersByStatus(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ServiceOrdersByStatusProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$serviceOrdersByStatusHash() =>
    r'86bec9bb8e451ccc9abcce99e0ad80ccf92089e2';

/// Nuevas/Finalizadas/Pagadas solo muestran lo del turno abierto actual — al
/// cerrar el turno, esas listas se vacían (el dato queda archivado bajo ese
/// turno, ver [ordersCreatedInRegisterProvider]/[ordersPaidInRegisterProvider]).
/// "Por Cobrar" (fiados) no pasa por aquí — no se escopa por turno.

final class ServiceOrdersByStatusFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ServiceOrderEntity>>, String> {
  ServiceOrdersByStatusFamily._()
    : super(
        retry: null,
        name: r'serviceOrdersByStatusProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Nuevas/Finalizadas/Pagadas solo muestran lo del turno abierto actual — al
  /// cerrar el turno, esas listas se vacían (el dato queda archivado bajo ese
  /// turno, ver [ordersCreatedInRegisterProvider]/[ordersPaidInRegisterProvider]).
  /// "Por Cobrar" (fiados) no pasa por aquí — no se escopa por turno.

  ServiceOrdersByStatusProvider call(String status) =>
      ServiceOrdersByStatusProvider._(argument: status, from: this);

  @override
  String toString() => r'serviceOrdersByStatusProvider';
}

/// Órdenes creadas durante un turno (historial: "qué se atendió").

@ProviderFor(ordersCreatedInRegister)
final ordersCreatedInRegisterProvider = OrdersCreatedInRegisterFamily._();

/// Órdenes creadas durante un turno (historial: "qué se atendió").

final class OrdersCreatedInRegisterProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ServiceOrderEntity>>,
          List<ServiceOrderEntity>,
          FutureOr<List<ServiceOrderEntity>>
        >
    with
        $FutureModifier<List<ServiceOrderEntity>>,
        $FutureProvider<List<ServiceOrderEntity>> {
  /// Órdenes creadas durante un turno (historial: "qué se atendió").
  OrdersCreatedInRegisterProvider._({
    required OrdersCreatedInRegisterFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'ordersCreatedInRegisterProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ordersCreatedInRegisterHash();

  @override
  String toString() {
    return r'ordersCreatedInRegisterProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ServiceOrderEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ServiceOrderEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return ordersCreatedInRegister(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OrdersCreatedInRegisterProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ordersCreatedInRegisterHash() =>
    r'861afc89de55ceaf13f59627c3dee6384e778800';

/// Órdenes creadas durante un turno (historial: "qué se atendió").

final class OrdersCreatedInRegisterFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ServiceOrderEntity>>, String> {
  OrdersCreatedInRegisterFamily._()
    : super(
        retry: null,
        name: r'ordersCreatedInRegisterProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Órdenes creadas durante un turno (historial: "qué se atendió").

  OrdersCreatedInRegisterProvider call(String cashRegisterId) =>
      OrdersCreatedInRegisterProvider._(argument: cashRegisterId, from: this);

  @override
  String toString() => r'ordersCreatedInRegisterProvider';
}

/// Órdenes que terminaron de pagarse durante un turno (historial: "qué se cobró").

@ProviderFor(ordersPaidInRegister)
final ordersPaidInRegisterProvider = OrdersPaidInRegisterFamily._();

/// Órdenes que terminaron de pagarse durante un turno (historial: "qué se cobró").

final class OrdersPaidInRegisterProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ServiceOrderEntity>>,
          List<ServiceOrderEntity>,
          FutureOr<List<ServiceOrderEntity>>
        >
    with
        $FutureModifier<List<ServiceOrderEntity>>,
        $FutureProvider<List<ServiceOrderEntity>> {
  /// Órdenes que terminaron de pagarse durante un turno (historial: "qué se cobró").
  OrdersPaidInRegisterProvider._({
    required OrdersPaidInRegisterFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'ordersPaidInRegisterProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ordersPaidInRegisterHash();

  @override
  String toString() {
    return r'ordersPaidInRegisterProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ServiceOrderEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ServiceOrderEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return ordersPaidInRegister(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OrdersPaidInRegisterProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ordersPaidInRegisterHash() =>
    r'2a05dc8d03acf5c59d96c16f7fe30f22fe63103e';

/// Órdenes que terminaron de pagarse durante un turno (historial: "qué se cobró").

final class OrdersPaidInRegisterFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ServiceOrderEntity>>, String> {
  OrdersPaidInRegisterFamily._()
    : super(
        retry: null,
        name: r'ordersPaidInRegisterProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Órdenes que terminaron de pagarse durante un turno (historial: "qué se cobró").

  OrdersPaidInRegisterProvider call(String cashRegisterId) =>
      OrdersPaidInRegisterProvider._(argument: cashRegisterId, from: this);

  @override
  String toString() => r'ordersPaidInRegisterProvider';
}

@ProviderFor(serviceOrderById)
final serviceOrderByIdProvider = ServiceOrderByIdFamily._();

final class ServiceOrderByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<ServiceOrderEntity>,
          ServiceOrderEntity,
          FutureOr<ServiceOrderEntity>
        >
    with
        $FutureModifier<ServiceOrderEntity>,
        $FutureProvider<ServiceOrderEntity> {
  ServiceOrderByIdProvider._({
    required ServiceOrderByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'serviceOrderByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$serviceOrderByIdHash();

  @override
  String toString() {
    return r'serviceOrderByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ServiceOrderEntity> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ServiceOrderEntity> create(Ref ref) {
    final argument = this.argument as String;
    return serviceOrderById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ServiceOrderByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$serviceOrderByIdHash() => r'57f2fbb5d3882a7207165d660fd58626c262a8eb';

final class ServiceOrderByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ServiceOrderEntity>, String> {
  ServiceOrderByIdFamily._()
    : super(
        retry: null,
        name: r'serviceOrderByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ServiceOrderByIdProvider call(String id) =>
      ServiceOrderByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'serviceOrderByIdProvider';
}
