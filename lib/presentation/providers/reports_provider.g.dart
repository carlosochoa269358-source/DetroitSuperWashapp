// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reportsDataSource)
final reportsDataSourceProvider = ReportsDataSourceProvider._();

final class ReportsDataSourceProvider
    extends
        $FunctionalProvider<
          ReportsDataSource,
          ReportsDataSource,
          ReportsDataSource
        >
    with $Provider<ReportsDataSource> {
  ReportsDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportsDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportsDataSourceHash();

  @$internal
  @override
  $ProviderElement<ReportsDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReportsDataSource create(Ref ref) {
    return reportsDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReportsDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReportsDataSource>(value),
    );
  }
}

String _$reportsDataSourceHash() => r'4aebed032c98405105a586cda645ab5af157c453';

@ProviderFor(reportsRepository)
final reportsRepositoryProvider = ReportsRepositoryProvider._();

final class ReportsRepositoryProvider
    extends
        $FunctionalProvider<
          ReportsRepositoryImpl,
          ReportsRepositoryImpl,
          ReportsRepositoryImpl
        >
    with $Provider<ReportsRepositoryImpl> {
  ReportsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReportsRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReportsRepositoryImpl create(Ref ref) {
    return reportsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReportsRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReportsRepositoryImpl>(value),
    );
  }
}

String _$reportsRepositoryHash() => r'e7c3d923b429c6f7585415b69c4007f7b9847516';

@ProviderFor(profitReport)
final profitReportProvider = ProfitReportFamily._();

final class ProfitReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProfitReportEntity>,
          ProfitReportEntity,
          FutureOr<ProfitReportEntity>
        >
    with
        $FutureModifier<ProfitReportEntity>,
        $FutureProvider<ProfitReportEntity> {
  ProfitReportProvider._({
    required ProfitReportFamily super.from,
    required (DateTime, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'profitReportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profitReportHash();

  @override
  String toString() {
    return r'profitReportProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ProfitReportEntity> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProfitReportEntity> create(Ref ref) {
    final argument = this.argument as (DateTime, DateTime);
    return profitReport(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfitReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profitReportHash() => r'a78ea180835adabba697af170285858e00bc1167';

final class ProfitReportFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ProfitReportEntity>,
          (DateTime, DateTime)
        > {
  ProfitReportFamily._()
    : super(
        retry: null,
        name: r'profitReportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProfitReportProvider call(DateTime fromDate, DateTime toDate) =>
      ProfitReportProvider._(argument: (fromDate, toDate), from: this);

  @override
  String toString() => r'profitReportProvider';
}
