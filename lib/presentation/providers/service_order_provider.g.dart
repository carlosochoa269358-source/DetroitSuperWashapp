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

@ProviderFor(serviceOrdersByStatus)
final serviceOrdersByStatusProvider = ServiceOrdersByStatusFamily._();

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
    r'c7885fb2ccf23dd62286fbf3f28e36c7b58560a7';

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

  ServiceOrdersByStatusProvider call(String status) =>
      ServiceOrdersByStatusProvider._(argument: status, from: this);

  @override
  String toString() => r'serviceOrdersByStatusProvider';
}
