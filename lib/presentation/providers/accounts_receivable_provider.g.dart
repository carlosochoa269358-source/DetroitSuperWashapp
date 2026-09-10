// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounts_receivable_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(accountsReceivableDataSource)
final accountsReceivableDataSourceProvider =
    AccountsReceivableDataSourceProvider._();

final class AccountsReceivableDataSourceProvider
    extends
        $FunctionalProvider<
          AccountsReceivableDataSource,
          AccountsReceivableDataSource,
          AccountsReceivableDataSource
        >
    with $Provider<AccountsReceivableDataSource> {
  AccountsReceivableDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountsReceivableDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountsReceivableDataSourceHash();

  @$internal
  @override
  $ProviderElement<AccountsReceivableDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccountsReceivableDataSource create(Ref ref) {
    return accountsReceivableDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountsReceivableDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountsReceivableDataSource>(value),
    );
  }
}

String _$accountsReceivableDataSourceHash() =>
    r'ded04e62c076ce511027af3a520ab67390fed2ca';

@ProviderFor(accountsReceivableRepository)
final accountsReceivableRepositoryProvider =
    AccountsReceivableRepositoryProvider._();

final class AccountsReceivableRepositoryProvider
    extends
        $FunctionalProvider<
          AccountsReceivableRepositoryImpl,
          AccountsReceivableRepositoryImpl,
          AccountsReceivableRepositoryImpl
        >
    with $Provider<AccountsReceivableRepositoryImpl> {
  AccountsReceivableRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountsReceivableRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountsReceivableRepositoryHash();

  @$internal
  @override
  $ProviderElement<AccountsReceivableRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccountsReceivableRepositoryImpl create(Ref ref) {
    return accountsReceivableRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountsReceivableRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountsReceivableRepositoryImpl>(
        value,
      ),
    );
  }
}

String _$accountsReceivableRepositoryHash() =>
    r'ab5580a2300f46761d2be66bb3b4f6b3f6e28984';

@ProviderFor(openAccountsReceivable)
final openAccountsReceivableProvider = OpenAccountsReceivableProvider._();

final class OpenAccountsReceivableProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AccountsReceivableEntity>>,
          List<AccountsReceivableEntity>,
          FutureOr<List<AccountsReceivableEntity>>
        >
    with
        $FutureModifier<List<AccountsReceivableEntity>>,
        $FutureProvider<List<AccountsReceivableEntity>> {
  OpenAccountsReceivableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openAccountsReceivableProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openAccountsReceivableHash();

  @$internal
  @override
  $FutureProviderElement<List<AccountsReceivableEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AccountsReceivableEntity>> create(Ref ref) {
    return openAccountsReceivable(ref);
  }
}

String _$openAccountsReceivableHash() =>
    r'07a999228d672563f2b1ee8f57a667ed061f3393';
