// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_order_item_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(serviceOrderItemDataSource)
final serviceOrderItemDataSourceProvider =
    ServiceOrderItemDataSourceProvider._();

final class ServiceOrderItemDataSourceProvider
    extends
        $FunctionalProvider<
          ServiceOrderItemDataSource,
          ServiceOrderItemDataSource,
          ServiceOrderItemDataSource
        >
    with $Provider<ServiceOrderItemDataSource> {
  ServiceOrderItemDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceOrderItemDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceOrderItemDataSourceHash();

  @$internal
  @override
  $ProviderElement<ServiceOrderItemDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ServiceOrderItemDataSource create(Ref ref) {
    return serviceOrderItemDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServiceOrderItemDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServiceOrderItemDataSource>(value),
    );
  }
}

String _$serviceOrderItemDataSourceHash() =>
    r'0e2cb415dc08a259adb85c2e15449eecfe39b094';

@ProviderFor(serviceOrderItemRepository)
final serviceOrderItemRepositoryProvider =
    ServiceOrderItemRepositoryProvider._();

final class ServiceOrderItemRepositoryProvider
    extends
        $FunctionalProvider<
          ServiceOrderItemRepositoryImpl,
          ServiceOrderItemRepositoryImpl,
          ServiceOrderItemRepositoryImpl
        >
    with $Provider<ServiceOrderItemRepositoryImpl> {
  ServiceOrderItemRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceOrderItemRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceOrderItemRepositoryHash();

  @$internal
  @override
  $ProviderElement<ServiceOrderItemRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ServiceOrderItemRepositoryImpl create(Ref ref) {
    return serviceOrderItemRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServiceOrderItemRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServiceOrderItemRepositoryImpl>(
        value,
      ),
    );
  }
}

String _$serviceOrderItemRepositoryHash() =>
    r'ecc2262cdec4b24ec8c84c864f4a74524d41f57d';

@ProviderFor(serviceOrderItems)
final serviceOrderItemsProvider = ServiceOrderItemsFamily._();

final class ServiceOrderItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ServiceOrderItemEntity>>,
          List<ServiceOrderItemEntity>,
          FutureOr<List<ServiceOrderItemEntity>>
        >
    with
        $FutureModifier<List<ServiceOrderItemEntity>>,
        $FutureProvider<List<ServiceOrderItemEntity>> {
  ServiceOrderItemsProvider._({
    required ServiceOrderItemsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'serviceOrderItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$serviceOrderItemsHash();

  @override
  String toString() {
    return r'serviceOrderItemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ServiceOrderItemEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ServiceOrderItemEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return serviceOrderItems(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ServiceOrderItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$serviceOrderItemsHash() => r'783d1e198c9c84c3ae13fd1df7d53a5725f35fc4';

final class ServiceOrderItemsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<ServiceOrderItemEntity>>,
          String
        > {
  ServiceOrderItemsFamily._()
    : super(
        retry: null,
        name: r'serviceOrderItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ServiceOrderItemsProvider call(String serviceOrderId) =>
      ServiceOrderItemsProvider._(argument: serviceOrderId, from: this);

  @override
  String toString() => r'serviceOrderItemsProvider';
}
