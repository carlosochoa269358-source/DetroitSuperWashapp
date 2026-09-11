// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(expenseDataSource)
final expenseDataSourceProvider = ExpenseDataSourceProvider._();

final class ExpenseDataSourceProvider
    extends
        $FunctionalProvider<
          ExpenseDataSource,
          ExpenseDataSource,
          ExpenseDataSource
        >
    with $Provider<ExpenseDataSource> {
  ExpenseDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseDataSourceHash();

  @$internal
  @override
  $ProviderElement<ExpenseDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExpenseDataSource create(Ref ref) {
    return expenseDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExpenseDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExpenseDataSource>(value),
    );
  }
}

String _$expenseDataSourceHash() => r'482a86131a389619fb99ad9357b8a66df1234505';

@ProviderFor(expenseRepository)
final expenseRepositoryProvider = ExpenseRepositoryProvider._();

final class ExpenseRepositoryProvider
    extends
        $FunctionalProvider<
          ExpenseRepositoryImpl,
          ExpenseRepositoryImpl,
          ExpenseRepositoryImpl
        >
    with $Provider<ExpenseRepositoryImpl> {
  ExpenseRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseRepositoryHash();

  @$internal
  @override
  $ProviderElement<ExpenseRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExpenseRepositoryImpl create(Ref ref) {
    return expenseRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExpenseRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExpenseRepositoryImpl>(value),
    );
  }
}

String _$expenseRepositoryHash() => r'eb289a76960efe3b82d055246295d149dd57fe75';

@ProviderFor(expenseCategories)
final expenseCategoriesProvider = ExpenseCategoriesProvider._();

final class ExpenseCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExpenseCategoryEntity>>,
          List<ExpenseCategoryEntity>,
          FutureOr<List<ExpenseCategoryEntity>>
        >
    with
        $FutureModifier<List<ExpenseCategoryEntity>>,
        $FutureProvider<List<ExpenseCategoryEntity>> {
  ExpenseCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseCategoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<ExpenseCategoryEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ExpenseCategoryEntity>> create(Ref ref) {
    return expenseCategories(ref);
  }
}

String _$expenseCategoriesHash() => r'a44ce2dc0697a525062aa05a0c3f380d79e999fc';

@ProviderFor(expensesByRegister)
final expensesByRegisterProvider = ExpensesByRegisterFamily._();

final class ExpensesByRegisterProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExpenseEntity>>,
          List<ExpenseEntity>,
          FutureOr<List<ExpenseEntity>>
        >
    with
        $FutureModifier<List<ExpenseEntity>>,
        $FutureProvider<List<ExpenseEntity>> {
  ExpensesByRegisterProvider._({
    required ExpensesByRegisterFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'expensesByRegisterProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$expensesByRegisterHash();

  @override
  String toString() {
    return r'expensesByRegisterProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ExpenseEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ExpenseEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return expensesByRegister(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExpensesByRegisterProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$expensesByRegisterHash() =>
    r'cd3bf65b9afe048b2fb4060c0e4f5e8b99291ddb';

final class ExpensesByRegisterFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ExpenseEntity>>, String> {
  ExpensesByRegisterFamily._()
    : super(
        retry: null,
        name: r'expensesByRegisterProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExpensesByRegisterProvider call(String cashRegisterId) =>
      ExpensesByRegisterProvider._(argument: cashRegisterId, from: this);

  @override
  String toString() => r'expensesByRegisterProvider';
}
