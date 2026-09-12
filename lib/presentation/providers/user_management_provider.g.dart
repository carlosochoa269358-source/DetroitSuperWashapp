// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_management_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userManagementDataSource)
final userManagementDataSourceProvider = UserManagementDataSourceProvider._();

final class UserManagementDataSourceProvider
    extends
        $FunctionalProvider<
          UserManagementDataSource,
          UserManagementDataSource,
          UserManagementDataSource
        >
    with $Provider<UserManagementDataSource> {
  UserManagementDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userManagementDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userManagementDataSourceHash();

  @$internal
  @override
  $ProviderElement<UserManagementDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserManagementDataSource create(Ref ref) {
    return userManagementDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserManagementDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserManagementDataSource>(value),
    );
  }
}

String _$userManagementDataSourceHash() =>
    r'ac7ebac30e46f38027db599a8f4fe088f1f24054';

@ProviderFor(userManagementRepository)
final userManagementRepositoryProvider = UserManagementRepositoryProvider._();

final class UserManagementRepositoryProvider
    extends
        $FunctionalProvider<
          UserManagementRepositoryImpl,
          UserManagementRepositoryImpl,
          UserManagementRepositoryImpl
        >
    with $Provider<UserManagementRepositoryImpl> {
  UserManagementRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userManagementRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userManagementRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserManagementRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserManagementRepositoryImpl create(Ref ref) {
    return userManagementRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserManagementRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserManagementRepositoryImpl>(value),
    );
  }
}

String _$userManagementRepositoryHash() =>
    r'b6fea225390a7b3818ab71fb451b8e6b11494fde';

@ProviderFor(companyUsers)
final companyUsersProvider = CompanyUsersProvider._();

final class CompanyUsersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserEntity>>,
          List<UserEntity>,
          FutureOr<List<UserEntity>>
        >
    with $FutureModifier<List<UserEntity>>, $FutureProvider<List<UserEntity>> {
  CompanyUsersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'companyUsersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$companyUsersHash();

  @$internal
  @override
  $FutureProviderElement<List<UserEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UserEntity>> create(Ref ref) {
    return companyUsers(ref);
  }
}

String _$companyUsersHash() => r'07fcba3282649d1fff52bf23e4296f5939410845';

@ProviderFor(availableRoles)
final availableRolesProvider = AvailableRolesProvider._();

final class AvailableRolesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RoleEntity>>,
          List<RoleEntity>,
          FutureOr<List<RoleEntity>>
        >
    with $FutureModifier<List<RoleEntity>>, $FutureProvider<List<RoleEntity>> {
  AvailableRolesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableRolesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availableRolesHash();

  @$internal
  @override
  $FutureProviderElement<List<RoleEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RoleEntity>> create(Ref ref) {
    return availableRoles(ref);
  }
}

String _$availableRolesHash() => r'a59767045c8b102a88e3a87cce79bc91bef3ebc3';
