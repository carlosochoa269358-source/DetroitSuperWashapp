// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(customerDataSource)
final customerDataSourceProvider = CustomerDataSourceProvider._();

final class CustomerDataSourceProvider
    extends
        $FunctionalProvider<
          CustomerDataSource,
          CustomerDataSource,
          CustomerDataSource
        >
    with $Provider<CustomerDataSource> {
  CustomerDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customerDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customerDataSourceHash();

  @$internal
  @override
  $ProviderElement<CustomerDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CustomerDataSource create(Ref ref) {
    return customerDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CustomerDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CustomerDataSource>(value),
    );
  }
}

String _$customerDataSourceHash() =>
    r'93268342421254b650b2eb418c40e22d5b957ff3';

@ProviderFor(customerRepository)
final customerRepositoryProvider = CustomerRepositoryProvider._();

final class CustomerRepositoryProvider
    extends
        $FunctionalProvider<
          CustomerRepositoryImpl,
          CustomerRepositoryImpl,
          CustomerRepositoryImpl
        >
    with $Provider<CustomerRepositoryImpl> {
  CustomerRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customerRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customerRepositoryHash();

  @$internal
  @override
  $ProviderElement<CustomerRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CustomerRepositoryImpl create(Ref ref) {
    return customerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CustomerRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CustomerRepositoryImpl>(value),
    );
  }
}

String _$customerRepositoryHash() =>
    r'e4dc2ad72fc99307084638ed652d56be3a35fce9';

@ProviderFor(customerSearch)
final customerSearchProvider = CustomerSearchFamily._();

final class CustomerSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CustomerEntity>>,
          List<CustomerEntity>,
          FutureOr<List<CustomerEntity>>
        >
    with
        $FutureModifier<List<CustomerEntity>>,
        $FutureProvider<List<CustomerEntity>> {
  CustomerSearchProvider._({
    required CustomerSearchFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'customerSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customerSearchHash();

  @override
  String toString() {
    return r'customerSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CustomerEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CustomerEntity>> create(Ref ref) {
    final argument = this.argument as String?;
    return customerSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customerSearchHash() => r'4b66218a84a319bceb83f7e045e7d6e95a55cf9d';

final class CustomerSearchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CustomerEntity>>, String?> {
  CustomerSearchFamily._()
    : super(
        retry: null,
        name: r'customerSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomerSearchProvider call(String? query) =>
      CustomerSearchProvider._(argument: query, from: this);

  @override
  String toString() => r'customerSearchProvider';
}

@ProviderFor(customerById)
final customerByIdProvider = CustomerByIdFamily._();

final class CustomerByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<CustomerEntity>,
          CustomerEntity,
          FutureOr<CustomerEntity>
        >
    with $FutureModifier<CustomerEntity>, $FutureProvider<CustomerEntity> {
  CustomerByIdProvider._({
    required CustomerByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'customerByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customerByIdHash();

  @override
  String toString() {
    return r'customerByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CustomerEntity> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CustomerEntity> create(Ref ref) {
    final argument = this.argument as String;
    return customerById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customerByIdHash() => r'2a9e364802be4b07957ba7d87d7e488d79628d88';

final class CustomerByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CustomerEntity>, String> {
  CustomerByIdFamily._()
    : super(
        retry: null,
        name: r'customerByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomerByIdProvider call(String id) =>
      CustomerByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'customerByIdProvider';
}
