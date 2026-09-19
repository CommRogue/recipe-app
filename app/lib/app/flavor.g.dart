// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flavor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in [bootstrap] with the running flavor. Reading it without an
/// override is a programming error, so it throws rather than defaulting to dev.

@ProviderFor(flavorConfig)
final flavorConfigProvider = FlavorConfigProvider._();

/// Overridden in [bootstrap] with the running flavor. Reading it without an
/// override is a programming error, so it throws rather than defaulting to dev.

final class FlavorConfigProvider
    extends $FunctionalProvider<FlavorConfig, FlavorConfig, FlavorConfig>
    with $Provider<FlavorConfig> {
  /// Overridden in [bootstrap] with the running flavor. Reading it without an
  /// override is a programming error, so it throws rather than defaulting to dev.
  FlavorConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flavorConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$flavorConfigHash();

  @$internal
  @override
  $ProviderElement<FlavorConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FlavorConfig create(Ref ref) {
    return flavorConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlavorConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlavorConfig>(value),
    );
  }
}

String _$flavorConfigHash() => r'491a2c3b7051933579b72bf7607cee7295a48e92';
