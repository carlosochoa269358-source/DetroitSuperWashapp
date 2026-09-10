// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(employeeDataSource)
final employeeDataSourceProvider = EmployeeDataSourceProvider._();

final class EmployeeDataSourceProvider
    extends
        $FunctionalProvider<
          EmployeeDataSource,
          EmployeeDataSource,
          EmployeeDataSource
        >
    with $Provider<EmployeeDataSource> {
  EmployeeDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'employeeDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$employeeDataSourceHash();

  @$internal
  @override
  $ProviderElement<EmployeeDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EmployeeDataSource create(Ref ref) {
    return employeeDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EmployeeDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EmployeeDataSource>(value),
    );
  }
}

String _$employeeDataSourceHash() =>
    r'9915ddafd3029a54cf99f16751d6f2efbcc2df51';

@ProviderFor(employeeRepository)
final employeeRepositoryProvider = EmployeeRepositoryProvider._();

final class EmployeeRepositoryProvider
    extends
        $FunctionalProvider<
          EmployeeRepositoryImpl,
          EmployeeRepositoryImpl,
          EmployeeRepositoryImpl
        >
    with $Provider<EmployeeRepositoryImpl> {
  EmployeeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'employeeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$employeeRepositoryHash();

  @$internal
  @override
  $ProviderElement<EmployeeRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EmployeeRepositoryImpl create(Ref ref) {
    return employeeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EmployeeRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EmployeeRepositoryImpl>(value),
    );
  }
}

String _$employeeRepositoryHash() =>
    r'0f317ec480cc85e894a1e367e1509290df24bfa2';

@ProviderFor(employees)
final employeesProvider = EmployeesProvider._();

final class EmployeesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EmployeeEntity>>,
          List<EmployeeEntity>,
          FutureOr<List<EmployeeEntity>>
        >
    with
        $FutureModifier<List<EmployeeEntity>>,
        $FutureProvider<List<EmployeeEntity>> {
  EmployeesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'employeesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$employeesHash();

  @$internal
  @override
  $FutureProviderElement<List<EmployeeEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<EmployeeEntity>> create(Ref ref) {
    return employees(ref);
  }
}

String _$employeesHash() => r'0edfd16dc1aaeb07fe6ad2f26178fbddf8c9fd8a';
