// core/config.freezed.dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RuntimeConfig _$RuntimeConfigFromJson(Map<String, dynamic> json) {
  return _RuntimeConfig.fromJson(json);
}

/// @nodoc
mixin _$RuntimeConfig {
  BackendConfig get backend => throw _privateConstructorUsedError;
  bool get showAds => throw _privateConstructorUsedError;
  String? get enterpriseName => throw _privateConstructorUsedError;
  String? get enterpriseLogo => throw _privateConstructorUsedError;

  /// Serializes this RuntimeConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RuntimeConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RuntimeConfigCopyWith<RuntimeConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RuntimeConfigCopyWith<$Res> {
  factory $RuntimeConfigCopyWith(
          RuntimeConfig value, $Res Function(RuntimeConfig) then) =
      _$RuntimeConfigCopyWithImpl<$Res, RuntimeConfig>;
  @useResult
  $Res call(
      {BackendConfig backend,
      bool showAds,
      String? enterpriseName,
      String? enterpriseLogo});

  $BackendConfigCopyWith<$Res> get backend;
}

/// @nodoc
class _$RuntimeConfigCopyWithImpl<$Res, $Val extends RuntimeConfig>
    implements $RuntimeConfigCopyWith<$Res> {
  _$RuntimeConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RuntimeConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? backend = null,
    Object? showAds = null,
    Object? enterpriseName = freezed,
    Object? enterpriseLogo = freezed,
  }) {
    return _then(_value.copyWith(
      backend: null == backend
          ? _value.backend
          : backend // ignore: cast_nullable_to_non_nullable
              as BackendConfig,
      showAds: null == showAds
          ? _value.showAds
          : showAds // ignore: cast_nullable_to_non_nullable
              as bool,
      enterpriseName: freezed == enterpriseName
          ? _value.enterpriseName
          : enterpriseName // ignore: cast_nullable_to_non_nullable
              as String?,
      enterpriseLogo: freezed == enterpriseLogo
          ? _value.enterpriseLogo
          : enterpriseLogo // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of RuntimeConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BackendConfigCopyWith<$Res> get backend {
    return $BackendConfigCopyWith<$Res>(_value.backend, (value) {
      return _then(_value.copyWith(backend: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RuntimeConfigImplCopyWith<$Res>
    implements $RuntimeConfigCopyWith<$Res> {
  factory _$$RuntimeConfigImplCopyWith(
          _$RuntimeConfigImpl value, $Res Function(_$RuntimeConfigImpl) then) =
      __$$RuntimeConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {BackendConfig backend,
      bool showAds,
      String? enterpriseName,
      String? enterpriseLogo});

  @override
  $BackendConfigCopyWith<$Res> get backend;
}

/// @nodoc
class __$$RuntimeConfigImplCopyWithImpl<$Res>
    extends _$RuntimeConfigCopyWithImpl<$Res, _$RuntimeConfigImpl>
    implements _$$RuntimeConfigImplCopyWith<$Res> {
  __$$RuntimeConfigImplCopyWithImpl(
      _$RuntimeConfigImpl _value, $Res Function(_$RuntimeConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of RuntimeConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? backend = null,
    Object? showAds = null,
    Object? enterpriseName = freezed,
    Object? enterpriseLogo = freezed,
  }) {
    return _then(_$RuntimeConfigImpl(
      backend: null == backend
          ? _value.backend
          : backend // ignore: cast_nullable_to_non_nullable
              as BackendConfig,
      showAds: null == showAds
          ? _value.showAds
          : showAds // ignore: cast_nullable_to_non_nullable
              as bool,
      enterpriseName: freezed == enterpriseName
          ? _value.enterpriseName
          : enterpriseName // ignore: cast_nullable_to_non_nullable
              as String?,
      enterpriseLogo: freezed == enterpriseLogo
          ? _value.enterpriseLogo
          : enterpriseLogo // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RuntimeConfigImpl implements _RuntimeConfig {
  const _$RuntimeConfigImpl(
      {required this.backend,
      this.showAds = true,
      this.enterpriseName,
      this.enterpriseLogo});

  factory _$RuntimeConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$RuntimeConfigImplFromJson(json);

  @override
  final BackendConfig backend;
  @override
  @JsonKey()
  final bool showAds;
  @override
  final String? enterpriseName;
  @override
  final String? enterpriseLogo;

  @override
  String toString() {
    return 'RuntimeConfig(backend: $backend, showAds: $showAds, enterpriseName: $enterpriseName, enterpriseLogo: $enterpriseLogo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RuntimeConfigImpl &&
            (identical(other.backend, backend) || other.backend == backend) &&
            (identical(other.showAds, showAds) || other.showAds == showAds) &&
            (identical(other.enterpriseName, enterpriseName) ||
                other.enterpriseName == enterpriseName) &&
            (identical(other.enterpriseLogo, enterpriseLogo) ||
                other.enterpriseLogo == enterpriseLogo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, backend, showAds, enterpriseName, enterpriseLogo);

  /// Create a copy of RuntimeConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RuntimeConfigImplCopyWith<_$RuntimeConfigImpl> get copyWith =>
      __$$RuntimeConfigImplCopyWithImpl<_$RuntimeConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RuntimeConfigImplToJson(
      this,
    );
  }
}

abstract class _RuntimeConfig implements RuntimeConfig {
  const factory _RuntimeConfig(
      {required final BackendConfig backend,
      final bool showAds,
      final String? enterpriseName,
      final String? enterpriseLogo}) = _$RuntimeConfigImpl;

  factory _RuntimeConfig.fromJson(Map<String, dynamic> json) =
      _$RuntimeConfigImpl.fromJson;

  @override
  BackendConfig get backend;
  @override
  bool get showAds;
  @override
  String? get enterpriseName;
  @override
  String? get enterpriseLogo;

  /// Create a copy of RuntimeConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RuntimeConfigImplCopyWith<_$RuntimeConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BackendConfig _$BackendConfigFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'local':
      return LocalBackend.fromJson(json);
    case 'supabase':
      return SupabaseBackend.fromJson(json);
    case 'pocketbase':
      return PocketbaseBackend.fromJson(json);
    case 'appwrite':
      return AppwriteBackend.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'BackendConfig',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$BackendConfig {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() local,
    required TResult Function(String url, String anonKey) supabase,
    required TResult Function(String url) pocketbase,
    required TResult Function(String endpoint, String projectId) appwrite,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? local,
    TResult? Function(String url, String anonKey)? supabase,
    TResult? Function(String url)? pocketbase,
    TResult? Function(String endpoint, String projectId)? appwrite,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? local,
    TResult Function(String url, String anonKey)? supabase,
    TResult Function(String url)? pocketbase,
    TResult Function(String endpoint, String projectId)? appwrite,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LocalBackend value) local,
    required TResult Function(SupabaseBackend value) supabase,
    required TResult Function(PocketbaseBackend value) pocketbase,
    required TResult Function(AppwriteBackend value) appwrite,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LocalBackend value)? local,
    TResult? Function(SupabaseBackend value)? supabase,
    TResult? Function(PocketbaseBackend value)? pocketbase,
    TResult? Function(AppwriteBackend value)? appwrite,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LocalBackend value)? local,
    TResult Function(SupabaseBackend value)? supabase,
    TResult Function(PocketbaseBackend value)? pocketbase,
    TResult Function(AppwriteBackend value)? appwrite,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this BackendConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackendConfigCopyWith<$Res> {
  factory $BackendConfigCopyWith(
          BackendConfig value, $Res Function(BackendConfig) then) =
      _$BackendConfigCopyWithImpl<$Res, BackendConfig>;
}

/// @nodoc
class _$BackendConfigCopyWithImpl<$Res, $Val extends BackendConfig>
    implements $BackendConfigCopyWith<$Res> {
  _$BackendConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BackendConfig
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LocalBackendImplCopyWith<$Res> {
  factory _$$LocalBackendImplCopyWith(
          _$LocalBackendImpl value, $Res Function(_$LocalBackendImpl) then) =
      __$$LocalBackendImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LocalBackendImplCopyWithImpl<$Res>
    extends _$BackendConfigCopyWithImpl<$Res, _$LocalBackendImpl>
    implements _$$LocalBackendImplCopyWith<$Res> {
  __$$LocalBackendImplCopyWithImpl(
      _$LocalBackendImpl _value, $Res Function(_$LocalBackendImpl) _then)
      : super(_value, _then);

  /// Create a copy of BackendConfig
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
@JsonSerializable()
class _$LocalBackendImpl implements LocalBackend {
  const _$LocalBackendImpl({final String? $type}) : $type = $type ?? 'local';

  factory _$LocalBackendImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocalBackendImplFromJson(json);

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'BackendConfig.local()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LocalBackendImpl);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() local,
    required TResult Function(String url, String anonKey) supabase,
    required TResult Function(String url) pocketbase,
    required TResult Function(String endpoint, String projectId) appwrite,
  }) {
    return local();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? local,
    TResult? Function(String url, String anonKey)? supabase,
    TResult? Function(String url)? pocketbase,
    TResult? Function(String endpoint, String projectId)? appwrite,
  }) {
    return local?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? local,
    TResult Function(String url, String anonKey)? supabase,
    TResult Function(String url)? pocketbase,
    TResult Function(String endpoint, String projectId)? appwrite,
    required TResult orElse(),
  }) {
    if (local != null) {
      return local();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LocalBackend value) local,
    required TResult Function(SupabaseBackend value) supabase,
    required TResult Function(PocketbaseBackend value) pocketbase,
    required TResult Function(AppwriteBackend value) appwrite,
  }) {
    return local(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LocalBackend value)? local,
    TResult? Function(SupabaseBackend value)? supabase,
    TResult? Function(PocketbaseBackend value)? pocketbase,
    TResult? Function(AppwriteBackend value)? appwrite,
  }) {
    return local?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LocalBackend value)? local,
    TResult Function(SupabaseBackend value)? supabase,
    TResult Function(PocketbaseBackend value)? pocketbase,
    TResult Function(AppwriteBackend value)? appwrite,
    required TResult orElse(),
  }) {
    if (local != null) {
      return local(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$LocalBackendImplToJson(
      this,
    );
  }
}

abstract class LocalBackend implements BackendConfig {
  const factory LocalBackend() = _$LocalBackendImpl;

  factory LocalBackend.fromJson(Map<String, dynamic> json) =
      _$LocalBackendImpl.fromJson;
}

/// @nodoc
abstract class _$$SupabaseBackendImplCopyWith<$Res> {
  factory _$$SupabaseBackendImplCopyWith(_$SupabaseBackendImpl value,
          $Res Function(_$SupabaseBackendImpl) then) =
      __$$SupabaseBackendImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String url, String anonKey});
}

/// @nodoc
class __$$SupabaseBackendImplCopyWithImpl<$Res>
    extends _$BackendConfigCopyWithImpl<$Res, _$SupabaseBackendImpl>
    implements _$$SupabaseBackendImplCopyWith<$Res> {
  __$$SupabaseBackendImplCopyWithImpl(
      _$SupabaseBackendImpl _value, $Res Function(_$SupabaseBackendImpl) _then)
      : super(_value, _then);

  /// Create a copy of BackendConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? anonKey = null,
  }) {
    return _then(_$SupabaseBackendImpl(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      anonKey: null == anonKey
          ? _value.anonKey
          : anonKey // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SupabaseBackendImpl implements SupabaseBackend {
  const _$SupabaseBackendImpl(
      {required this.url, required this.anonKey, final String? $type})
      : $type = $type ?? 'supabase';

  factory _$SupabaseBackendImpl.fromJson(Map<String, dynamic> json) =>
      _$$SupabaseBackendImplFromJson(json);

  @override
  final String url;
  @override
  final String anonKey;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'BackendConfig.supabase(url: $url, anonKey: $anonKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SupabaseBackendImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.anonKey, anonKey) || other.anonKey == anonKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, url, anonKey);

  /// Create a copy of BackendConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SupabaseBackendImplCopyWith<_$SupabaseBackendImpl> get copyWith =>
      __$$SupabaseBackendImplCopyWithImpl<_$SupabaseBackendImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() local,
    required TResult Function(String url, String anonKey) supabase,
    required TResult Function(String url) pocketbase,
    required TResult Function(String endpoint, String projectId) appwrite,
  }) {
    return supabase(url, anonKey);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? local,
    TResult? Function(String url, String anonKey)? supabase,
    TResult? Function(String url)? pocketbase,
    TResult? Function(String endpoint, String projectId)? appwrite,
  }) {
    return supabase?.call(url, anonKey);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? local,
    TResult Function(String url, String anonKey)? supabase,
    TResult Function(String url)? pocketbase,
    TResult Function(String endpoint, String projectId)? appwrite,
    required TResult orElse(),
  }) {
    if (supabase != null) {
      return supabase(url, anonKey);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LocalBackend value) local,
    required TResult Function(SupabaseBackend value) supabase,
    required TResult Function(PocketbaseBackend value) pocketbase,
    required TResult Function(AppwriteBackend value) appwrite,
  }) {
    return supabase(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LocalBackend value)? local,
    TResult? Function(SupabaseBackend value)? supabase,
    TResult? Function(PocketbaseBackend value)? pocketbase,
    TResult? Function(AppwriteBackend value)? appwrite,
  }) {
    return supabase?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LocalBackend value)? local,
    TResult Function(SupabaseBackend value)? supabase,
    TResult Function(PocketbaseBackend value)? pocketbase,
    TResult Function(AppwriteBackend value)? appwrite,
    required TResult orElse(),
  }) {
    if (supabase != null) {
      return supabase(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$SupabaseBackendImplToJson(
      this,
    );
  }
}

abstract class SupabaseBackend implements BackendConfig {
  const factory SupabaseBackend(
      {required final String url,
      required final String anonKey}) = _$SupabaseBackendImpl;

  factory SupabaseBackend.fromJson(Map<String, dynamic> json) =
      _$SupabaseBackendImpl.fromJson;

  String get url;
  String get anonKey;

  /// Create a copy of BackendConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SupabaseBackendImplCopyWith<_$SupabaseBackendImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PocketbaseBackendImplCopyWith<$Res> {
  factory _$$PocketbaseBackendImplCopyWith(_$PocketbaseBackendImpl value,
          $Res Function(_$PocketbaseBackendImpl) then) =
      __$$PocketbaseBackendImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String url});
}

/// @nodoc
class __$$PocketbaseBackendImplCopyWithImpl<$Res>
    extends _$BackendConfigCopyWithImpl<$Res, _$PocketbaseBackendImpl>
    implements _$$PocketbaseBackendImplCopyWith<$Res> {
  __$$PocketbaseBackendImplCopyWithImpl(_$PocketbaseBackendImpl _value,
      $Res Function(_$PocketbaseBackendImpl) _then)
      : super(_value, _then);

  /// Create a copy of BackendConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
  }) {
    return _then(_$PocketbaseBackendImpl(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PocketbaseBackendImpl implements PocketbaseBackend {
  const _$PocketbaseBackendImpl({required this.url, final String? $type})
      : $type = $type ?? 'pocketbase';

  factory _$PocketbaseBackendImpl.fromJson(Map<String, dynamic> json) =>
      _$$PocketbaseBackendImplFromJson(json);

  @override
  final String url;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'BackendConfig.pocketbase(url: $url)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PocketbaseBackendImpl &&
            (identical(other.url, url) || other.url == url));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, url);

  /// Create a copy of BackendConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PocketbaseBackendImplCopyWith<_$PocketbaseBackendImpl> get copyWith =>
      __$$PocketbaseBackendImplCopyWithImpl<_$PocketbaseBackendImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() local,
    required TResult Function(String url, String anonKey) supabase,
    required TResult Function(String url) pocketbase,
    required TResult Function(String endpoint, String projectId) appwrite,
  }) {
    return pocketbase(url);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? local,
    TResult? Function(String url, String anonKey)? supabase,
    TResult? Function(String url)? pocketbase,
    TResult? Function(String endpoint, String projectId)? appwrite,
  }) {
    return pocketbase?.call(url);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? local,
    TResult Function(String url, String anonKey)? supabase,
    TResult Function(String url)? pocketbase,
    TResult Function(String endpoint, String projectId)? appwrite,
    required TResult orElse(),
  }) {
    if (pocketbase != null) {
      return pocketbase(url);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LocalBackend value) local,
    required TResult Function(SupabaseBackend value) supabase,
    required TResult Function(PocketbaseBackend value) pocketbase,
    required TResult Function(AppwriteBackend value) appwrite,
  }) {
    return pocketbase(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LocalBackend value)? local,
    TResult? Function(SupabaseBackend value)? supabase,
    TResult? Function(PocketbaseBackend value)? pocketbase,
    TResult? Function(AppwriteBackend value)? appwrite,
  }) {
    return pocketbase?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LocalBackend value)? local,
    TResult Function(SupabaseBackend value)? supabase,
    TResult Function(PocketbaseBackend value)? pocketbase,
    TResult Function(AppwriteBackend value)? appwrite,
    required TResult orElse(),
  }) {
    if (pocketbase != null) {
      return pocketbase(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$PocketbaseBackendImplToJson(
      this,
    );
  }
}

abstract class PocketbaseBackend implements BackendConfig {
  const factory PocketbaseBackend({required final String url}) =
      _$PocketbaseBackendImpl;

  factory PocketbaseBackend.fromJson(Map<String, dynamic> json) =
      _$PocketbaseBackendImpl.fromJson;

  String get url;

  /// Create a copy of BackendConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PocketbaseBackendImplCopyWith<_$PocketbaseBackendImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AppwriteBackendImplCopyWith<$Res> {
  factory _$$AppwriteBackendImplCopyWith(_$AppwriteBackendImpl value,
          $Res Function(_$AppwriteBackendImpl) then) =
      __$$AppwriteBackendImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String endpoint, String projectId});
}

/// @nodoc
class __$$AppwriteBackendImplCopyWithImpl<$Res>
    extends _$BackendConfigCopyWithImpl<$Res, _$AppwriteBackendImpl>
    implements _$$AppwriteBackendImplCopyWith<$Res> {
  __$$AppwriteBackendImplCopyWithImpl(
      _$AppwriteBackendImpl _value, $Res Function(_$AppwriteBackendImpl) _then)
      : super(_value, _then);

  /// Create a copy of BackendConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? endpoint = null,
    Object? projectId = null,
  }) {
    return _then(_$AppwriteBackendImpl(
      endpoint: null == endpoint
          ? _value.endpoint
          : endpoint // ignore: cast_nullable_to_non_nullable
              as String,
      projectId: null == projectId
          ? _value.projectId
          : projectId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppwriteBackendImpl implements AppwriteBackend {
  const _$AppwriteBackendImpl(
      {required this.endpoint, required this.projectId, final String? $type})
      : $type = $type ?? 'appwrite';

  factory _$AppwriteBackendImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppwriteBackendImplFromJson(json);

  @override
  final String endpoint;
  @override
  final String projectId;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'BackendConfig.appwrite(endpoint: $endpoint, projectId: $projectId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppwriteBackendImpl &&
            (identical(other.endpoint, endpoint) ||
                other.endpoint == endpoint) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, endpoint, projectId);

  /// Create a copy of BackendConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppwriteBackendImplCopyWith<_$AppwriteBackendImpl> get copyWith =>
      __$$AppwriteBackendImplCopyWithImpl<_$AppwriteBackendImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() local,
    required TResult Function(String url, String anonKey) supabase,
    required TResult Function(String url) pocketbase,
    required TResult Function(String endpoint, String projectId) appwrite,
  }) {
    return appwrite(endpoint, projectId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? local,
    TResult? Function(String url, String anonKey)? supabase,
    TResult? Function(String url)? pocketbase,
    TResult? Function(String endpoint, String projectId)? appwrite,
  }) {
    return appwrite?.call(endpoint, projectId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? local,
    TResult Function(String url, String anonKey)? supabase,
    TResult Function(String url)? pocketbase,
    TResult Function(String endpoint, String projectId)? appwrite,
    required TResult orElse(),
  }) {
    if (appwrite != null) {
      return appwrite(endpoint, projectId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LocalBackend value) local,
    required TResult Function(SupabaseBackend value) supabase,
    required TResult Function(PocketbaseBackend value) pocketbase,
    required TResult Function(AppwriteBackend value) appwrite,
  }) {
    return appwrite(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LocalBackend value)? local,
    TResult? Function(SupabaseBackend value)? supabase,
    TResult? Function(PocketbaseBackend value)? pocketbase,
    TResult? Function(AppwriteBackend value)? appwrite,
  }) {
    return appwrite?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LocalBackend value)? local,
    TResult Function(SupabaseBackend value)? supabase,
    TResult Function(PocketbaseBackend value)? pocketbase,
    TResult Function(AppwriteBackend value)? appwrite,
    required TResult orElse(),
  }) {
    if (appwrite != null) {
      return appwrite(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$AppwriteBackendImplToJson(
      this,
    );
  }
}

abstract class AppwriteBackend implements BackendConfig {
  const factory AppwriteBackend(
      {required final String endpoint,
      required final String projectId}) = _$AppwriteBackendImpl;

  factory AppwriteBackend.fromJson(Map<String, dynamic> json) =
      _$AppwriteBackendImpl.fromJson;

  String get endpoint;
  String get projectId;

  /// Create a copy of BackendConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppwriteBackendImplCopyWith<_$AppwriteBackendImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
