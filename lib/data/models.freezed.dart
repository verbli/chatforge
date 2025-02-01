// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProviderConfig _$ProviderConfigFromJson(Map<String, dynamic> json) {
  return _ProviderConfig.fromJson(json);
}

/// @nodoc
mixin _$ProviderConfig {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  ProviderType get type => throw _privateConstructorUsedError;
  String get baseUrl => throw _privateConstructorUsedError;
  String get apiKey => throw _privateConstructorUsedError;
  List<ModelConfig> get models => throw _privateConstructorUsedError;
  String? get organization => throw _privateConstructorUsedError;
  bool? get allowFallback => throw _privateConstructorUsedError;

  /// Serializes this ProviderConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProviderConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProviderConfigCopyWith<ProviderConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProviderConfigCopyWith<$Res> {
  factory $ProviderConfigCopyWith(
          ProviderConfig value, $Res Function(ProviderConfig) then) =
      _$ProviderConfigCopyWithImpl<$Res, ProviderConfig>;
  @useResult
  $Res call(
      {String id,
      String name,
      ProviderType type,
      String baseUrl,
      String apiKey,
      List<ModelConfig> models,
      String? organization,
      bool? allowFallback});
}

/// @nodoc
class _$ProviderConfigCopyWithImpl<$Res, $Val extends ProviderConfig>
    implements $ProviderConfigCopyWith<$Res> {
  _$ProviderConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProviderConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? baseUrl = null,
    Object? apiKey = null,
    Object? models = null,
    Object? organization = freezed,
    Object? allowFallback = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProviderType,
      baseUrl: null == baseUrl
          ? _value.baseUrl
          : baseUrl // ignore: cast_nullable_to_non_nullable
              as String,
      apiKey: null == apiKey
          ? _value.apiKey
          : apiKey // ignore: cast_nullable_to_non_nullable
              as String,
      models: null == models
          ? _value.models
          : models // ignore: cast_nullable_to_non_nullable
              as List<ModelConfig>,
      organization: freezed == organization
          ? _value.organization
          : organization // ignore: cast_nullable_to_non_nullable
              as String?,
      allowFallback: freezed == allowFallback
          ? _value.allowFallback
          : allowFallback // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProviderConfigImplCopyWith<$Res>
    implements $ProviderConfigCopyWith<$Res> {
  factory _$$ProviderConfigImplCopyWith(_$ProviderConfigImpl value,
          $Res Function(_$ProviderConfigImpl) then) =
      __$$ProviderConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      ProviderType type,
      String baseUrl,
      String apiKey,
      List<ModelConfig> models,
      String? organization,
      bool? allowFallback});
}

/// @nodoc
class __$$ProviderConfigImplCopyWithImpl<$Res>
    extends _$ProviderConfigCopyWithImpl<$Res, _$ProviderConfigImpl>
    implements _$$ProviderConfigImplCopyWith<$Res> {
  __$$ProviderConfigImplCopyWithImpl(
      _$ProviderConfigImpl _value, $Res Function(_$ProviderConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProviderConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? baseUrl = null,
    Object? apiKey = null,
    Object? models = null,
    Object? organization = freezed,
    Object? allowFallback = freezed,
  }) {
    return _then(_$ProviderConfigImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProviderType,
      baseUrl: null == baseUrl
          ? _value.baseUrl
          : baseUrl // ignore: cast_nullable_to_non_nullable
              as String,
      apiKey: null == apiKey
          ? _value.apiKey
          : apiKey // ignore: cast_nullable_to_non_nullable
              as String,
      models: null == models
          ? _value._models
          : models // ignore: cast_nullable_to_non_nullable
              as List<ModelConfig>,
      organization: freezed == organization
          ? _value.organization
          : organization // ignore: cast_nullable_to_non_nullable
              as String?,
      allowFallback: freezed == allowFallback
          ? _value.allowFallback
          : allowFallback // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProviderConfigImpl
    with DiagnosticableTreeMixin
    implements _ProviderConfig {
  const _$ProviderConfigImpl(
      {required this.id,
      required this.name,
      required this.type,
      required this.baseUrl,
      required this.apiKey,
      required final List<ModelConfig> models,
      this.organization,
      this.allowFallback})
      : _models = models;

  factory _$ProviderConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProviderConfigImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final ProviderType type;
  @override
  final String baseUrl;
  @override
  final String apiKey;
  final List<ModelConfig> _models;
  @override
  List<ModelConfig> get models {
    if (_models is EqualUnmodifiableListView) return _models;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_models);
  }

  @override
  final String? organization;
  @override
  final bool? allowFallback;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ProviderConfig(id: $id, name: $name, type: $type, baseUrl: $baseUrl, apiKey: $apiKey, models: $models, organization: $organization, allowFallback: $allowFallback)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ProviderConfig'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('baseUrl', baseUrl))
      ..add(DiagnosticsProperty('apiKey', apiKey))
      ..add(DiagnosticsProperty('models', models))
      ..add(DiagnosticsProperty('organization', organization))
      ..add(DiagnosticsProperty('allowFallback', allowFallback));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProviderConfigImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl) &&
            (identical(other.apiKey, apiKey) || other.apiKey == apiKey) &&
            const DeepCollectionEquality().equals(other._models, _models) &&
            (identical(other.organization, organization) ||
                other.organization == organization) &&
            (identical(other.allowFallback, allowFallback) ||
                other.allowFallback == allowFallback));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      type,
      baseUrl,
      apiKey,
      const DeepCollectionEquality().hash(_models),
      organization,
      allowFallback);

  /// Create a copy of ProviderConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProviderConfigImplCopyWith<_$ProviderConfigImpl> get copyWith =>
      __$$ProviderConfigImplCopyWithImpl<_$ProviderConfigImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProviderConfigImplToJson(
      this,
    );
  }
}

abstract class _ProviderConfig implements ProviderConfig {
  const factory _ProviderConfig(
      {required final String id,
      required final String name,
      required final ProviderType type,
      required final String baseUrl,
      required final String apiKey,
      required final List<ModelConfig> models,
      final String? organization,
      final bool? allowFallback}) = _$ProviderConfigImpl;

  factory _ProviderConfig.fromJson(Map<String, dynamic> json) =
      _$ProviderConfigImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  ProviderType get type;
  @override
  String get baseUrl;
  @override
  String get apiKey;
  @override
  List<ModelConfig> get models;
  @override
  String? get organization;
  @override
  bool? get allowFallback;

  /// Create a copy of ProviderConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProviderConfigImplCopyWith<_$ProviderConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ModelConfig _$ModelConfigFromJson(Map<String, dynamic> json) {
  return _ModelConfig.fromJson(json);
}

/// @nodoc
mixin _$ModelConfig {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  ModelCapabilities get capabilities => throw _privateConstructorUsedError;
  ModelSettings get settings => throw _privateConstructorUsedError;
  bool get isEnabled => throw _privateConstructorUsedError;
  ModelPricing? get pricing => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;

  /// Serializes this ModelConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModelConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModelConfigCopyWith<ModelConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModelConfigCopyWith<$Res> {
  factory $ModelConfigCopyWith(
          ModelConfig value, $Res Function(ModelConfig) then) =
      _$ModelConfigCopyWithImpl<$Res, ModelConfig>;
  @useResult
  $Res call(
      {String id,
      String name,
      ModelCapabilities capabilities,
      ModelSettings settings,
      bool isEnabled,
      ModelPricing? pricing,
      String? type});

  $ModelCapabilitiesCopyWith<$Res> get capabilities;
  $ModelSettingsCopyWith<$Res> get settings;
  $ModelPricingCopyWith<$Res>? get pricing;
}

/// @nodoc
class _$ModelConfigCopyWithImpl<$Res, $Val extends ModelConfig>
    implements $ModelConfigCopyWith<$Res> {
  _$ModelConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModelConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? capabilities = null,
    Object? settings = null,
    Object? isEnabled = null,
    Object? pricing = freezed,
    Object? type = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      capabilities: null == capabilities
          ? _value.capabilities
          : capabilities // ignore: cast_nullable_to_non_nullable
              as ModelCapabilities,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as ModelSettings,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      pricing: freezed == pricing
          ? _value.pricing
          : pricing // ignore: cast_nullable_to_non_nullable
              as ModelPricing?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of ModelConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ModelCapabilitiesCopyWith<$Res> get capabilities {
    return $ModelCapabilitiesCopyWith<$Res>(_value.capabilities, (value) {
      return _then(_value.copyWith(capabilities: value) as $Val);
    });
  }

  /// Create a copy of ModelConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ModelSettingsCopyWith<$Res> get settings {
    return $ModelSettingsCopyWith<$Res>(_value.settings, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
  }

  /// Create a copy of ModelConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ModelPricingCopyWith<$Res>? get pricing {
    if (_value.pricing == null) {
      return null;
    }

    return $ModelPricingCopyWith<$Res>(_value.pricing!, (value) {
      return _then(_value.copyWith(pricing: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ModelConfigImplCopyWith<$Res>
    implements $ModelConfigCopyWith<$Res> {
  factory _$$ModelConfigImplCopyWith(
          _$ModelConfigImpl value, $Res Function(_$ModelConfigImpl) then) =
      __$$ModelConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      ModelCapabilities capabilities,
      ModelSettings settings,
      bool isEnabled,
      ModelPricing? pricing,
      String? type});

  @override
  $ModelCapabilitiesCopyWith<$Res> get capabilities;
  @override
  $ModelSettingsCopyWith<$Res> get settings;
  @override
  $ModelPricingCopyWith<$Res>? get pricing;
}

/// @nodoc
class __$$ModelConfigImplCopyWithImpl<$Res>
    extends _$ModelConfigCopyWithImpl<$Res, _$ModelConfigImpl>
    implements _$$ModelConfigImplCopyWith<$Res> {
  __$$ModelConfigImplCopyWithImpl(
      _$ModelConfigImpl _value, $Res Function(_$ModelConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of ModelConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? capabilities = null,
    Object? settings = null,
    Object? isEnabled = null,
    Object? pricing = freezed,
    Object? type = freezed,
  }) {
    return _then(_$ModelConfigImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      capabilities: null == capabilities
          ? _value.capabilities
          : capabilities // ignore: cast_nullable_to_non_nullable
              as ModelCapabilities,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as ModelSettings,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      pricing: freezed == pricing
          ? _value.pricing
          : pricing // ignore: cast_nullable_to_non_nullable
              as ModelPricing?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModelConfigImpl with DiagnosticableTreeMixin implements _ModelConfig {
  const _$ModelConfigImpl(
      {required this.id,
      required this.name,
      required this.capabilities,
      required this.settings,
      this.isEnabled = false,
      this.pricing,
      this.type});

  factory _$ModelConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModelConfigImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final ModelCapabilities capabilities;
  @override
  final ModelSettings settings;
  @override
  @JsonKey()
  final bool isEnabled;
  @override
  final ModelPricing? pricing;
  @override
  final String? type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ModelConfig(id: $id, name: $name, capabilities: $capabilities, settings: $settings, isEnabled: $isEnabled, pricing: $pricing, type: $type)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ModelConfig'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('capabilities', capabilities))
      ..add(DiagnosticsProperty('settings', settings))
      ..add(DiagnosticsProperty('isEnabled', isEnabled))
      ..add(DiagnosticsProperty('pricing', pricing))
      ..add(DiagnosticsProperty('type', type));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModelConfigImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.capabilities, capabilities) ||
                other.capabilities == capabilities) &&
            (identical(other.settings, settings) ||
                other.settings == settings) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.pricing, pricing) || other.pricing == pricing) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, capabilities, settings, isEnabled, pricing, type);

  /// Create a copy of ModelConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModelConfigImplCopyWith<_$ModelConfigImpl> get copyWith =>
      __$$ModelConfigImplCopyWithImpl<_$ModelConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModelConfigImplToJson(
      this,
    );
  }
}

abstract class _ModelConfig implements ModelConfig {
  const factory _ModelConfig(
      {required final String id,
      required final String name,
      required final ModelCapabilities capabilities,
      required final ModelSettings settings,
      final bool isEnabled,
      final ModelPricing? pricing,
      final String? type}) = _$ModelConfigImpl;

  factory _ModelConfig.fromJson(Map<String, dynamic> json) =
      _$ModelConfigImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  ModelCapabilities get capabilities;
  @override
  ModelSettings get settings;
  @override
  bool get isEnabled;
  @override
  ModelPricing? get pricing;
  @override
  String? get type;

  /// Create a copy of ModelConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModelConfigImplCopyWith<_$ModelConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ModelCapabilities _$ModelCapabilitiesFromJson(Map<String, dynamic> json) {
  return _ModelCapabilities.fromJson(json);
}

/// @nodoc
mixin _$ModelCapabilities {
  int get maxContextTokens => throw _privateConstructorUsedError;
  int get maxResponseTokens => throw _privateConstructorUsedError;
  bool get supportsStreaming => throw _privateConstructorUsedError;
  bool get supportsFunctions => throw _privateConstructorUsedError;
  bool get supportsSystemPrompt => throw _privateConstructorUsedError;

  /// Serializes this ModelCapabilities to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModelCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModelCapabilitiesCopyWith<ModelCapabilities> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModelCapabilitiesCopyWith<$Res> {
  factory $ModelCapabilitiesCopyWith(
          ModelCapabilities value, $Res Function(ModelCapabilities) then) =
      _$ModelCapabilitiesCopyWithImpl<$Res, ModelCapabilities>;
  @useResult
  $Res call(
      {int maxContextTokens,
      int maxResponseTokens,
      bool supportsStreaming,
      bool supportsFunctions,
      bool supportsSystemPrompt});
}

/// @nodoc
class _$ModelCapabilitiesCopyWithImpl<$Res, $Val extends ModelCapabilities>
    implements $ModelCapabilitiesCopyWith<$Res> {
  _$ModelCapabilitiesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModelCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxContextTokens = null,
    Object? maxResponseTokens = null,
    Object? supportsStreaming = null,
    Object? supportsFunctions = null,
    Object? supportsSystemPrompt = null,
  }) {
    return _then(_value.copyWith(
      maxContextTokens: null == maxContextTokens
          ? _value.maxContextTokens
          : maxContextTokens // ignore: cast_nullable_to_non_nullable
              as int,
      maxResponseTokens: null == maxResponseTokens
          ? _value.maxResponseTokens
          : maxResponseTokens // ignore: cast_nullable_to_non_nullable
              as int,
      supportsStreaming: null == supportsStreaming
          ? _value.supportsStreaming
          : supportsStreaming // ignore: cast_nullable_to_non_nullable
              as bool,
      supportsFunctions: null == supportsFunctions
          ? _value.supportsFunctions
          : supportsFunctions // ignore: cast_nullable_to_non_nullable
              as bool,
      supportsSystemPrompt: null == supportsSystemPrompt
          ? _value.supportsSystemPrompt
          : supportsSystemPrompt // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModelCapabilitiesImplCopyWith<$Res>
    implements $ModelCapabilitiesCopyWith<$Res> {
  factory _$$ModelCapabilitiesImplCopyWith(_$ModelCapabilitiesImpl value,
          $Res Function(_$ModelCapabilitiesImpl) then) =
      __$$ModelCapabilitiesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int maxContextTokens,
      int maxResponseTokens,
      bool supportsStreaming,
      bool supportsFunctions,
      bool supportsSystemPrompt});
}

/// @nodoc
class __$$ModelCapabilitiesImplCopyWithImpl<$Res>
    extends _$ModelCapabilitiesCopyWithImpl<$Res, _$ModelCapabilitiesImpl>
    implements _$$ModelCapabilitiesImplCopyWith<$Res> {
  __$$ModelCapabilitiesImplCopyWithImpl(_$ModelCapabilitiesImpl _value,
      $Res Function(_$ModelCapabilitiesImpl) _then)
      : super(_value, _then);

  /// Create a copy of ModelCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxContextTokens = null,
    Object? maxResponseTokens = null,
    Object? supportsStreaming = null,
    Object? supportsFunctions = null,
    Object? supportsSystemPrompt = null,
  }) {
    return _then(_$ModelCapabilitiesImpl(
      maxContextTokens: null == maxContextTokens
          ? _value.maxContextTokens
          : maxContextTokens // ignore: cast_nullable_to_non_nullable
              as int,
      maxResponseTokens: null == maxResponseTokens
          ? _value.maxResponseTokens
          : maxResponseTokens // ignore: cast_nullable_to_non_nullable
              as int,
      supportsStreaming: null == supportsStreaming
          ? _value.supportsStreaming
          : supportsStreaming // ignore: cast_nullable_to_non_nullable
              as bool,
      supportsFunctions: null == supportsFunctions
          ? _value.supportsFunctions
          : supportsFunctions // ignore: cast_nullable_to_non_nullable
              as bool,
      supportsSystemPrompt: null == supportsSystemPrompt
          ? _value.supportsSystemPrompt
          : supportsSystemPrompt // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModelCapabilitiesImpl
    with DiagnosticableTreeMixin
    implements _ModelCapabilities {
  const _$ModelCapabilitiesImpl(
      {required this.maxContextTokens,
      required this.maxResponseTokens,
      this.supportsStreaming = true,
      this.supportsFunctions = false,
      this.supportsSystemPrompt = true});

  factory _$ModelCapabilitiesImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModelCapabilitiesImplFromJson(json);

  @override
  final int maxContextTokens;
  @override
  final int maxResponseTokens;
  @override
  @JsonKey()
  final bool supportsStreaming;
  @override
  @JsonKey()
  final bool supportsFunctions;
  @override
  @JsonKey()
  final bool supportsSystemPrompt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ModelCapabilities(maxContextTokens: $maxContextTokens, maxResponseTokens: $maxResponseTokens, supportsStreaming: $supportsStreaming, supportsFunctions: $supportsFunctions, supportsSystemPrompt: $supportsSystemPrompt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ModelCapabilities'))
      ..add(DiagnosticsProperty('maxContextTokens', maxContextTokens))
      ..add(DiagnosticsProperty('maxResponseTokens', maxResponseTokens))
      ..add(DiagnosticsProperty('supportsStreaming', supportsStreaming))
      ..add(DiagnosticsProperty('supportsFunctions', supportsFunctions))
      ..add(DiagnosticsProperty('supportsSystemPrompt', supportsSystemPrompt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModelCapabilitiesImpl &&
            (identical(other.maxContextTokens, maxContextTokens) ||
                other.maxContextTokens == maxContextTokens) &&
            (identical(other.maxResponseTokens, maxResponseTokens) ||
                other.maxResponseTokens == maxResponseTokens) &&
            (identical(other.supportsStreaming, supportsStreaming) ||
                other.supportsStreaming == supportsStreaming) &&
            (identical(other.supportsFunctions, supportsFunctions) ||
                other.supportsFunctions == supportsFunctions) &&
            (identical(other.supportsSystemPrompt, supportsSystemPrompt) ||
                other.supportsSystemPrompt == supportsSystemPrompt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      maxContextTokens,
      maxResponseTokens,
      supportsStreaming,
      supportsFunctions,
      supportsSystemPrompt);

  /// Create a copy of ModelCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModelCapabilitiesImplCopyWith<_$ModelCapabilitiesImpl> get copyWith =>
      __$$ModelCapabilitiesImplCopyWithImpl<_$ModelCapabilitiesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModelCapabilitiesImplToJson(
      this,
    );
  }
}

abstract class _ModelCapabilities implements ModelCapabilities {
  const factory _ModelCapabilities(
      {required final int maxContextTokens,
      required final int maxResponseTokens,
      final bool supportsStreaming,
      final bool supportsFunctions,
      final bool supportsSystemPrompt}) = _$ModelCapabilitiesImpl;

  factory _ModelCapabilities.fromJson(Map<String, dynamic> json) =
      _$ModelCapabilitiesImpl.fromJson;

  @override
  int get maxContextTokens;
  @override
  int get maxResponseTokens;
  @override
  bool get supportsStreaming;
  @override
  bool get supportsFunctions;
  @override
  bool get supportsSystemPrompt;

  /// Create a copy of ModelCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModelCapabilitiesImplCopyWith<_$ModelCapabilitiesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ModelSettings _$ModelSettingsFromJson(Map<String, dynamic> json) {
  return _ModelSettings.fromJson(json);
}

/// @nodoc
mixin _$ModelSettings {
  double get temperature => throw _privateConstructorUsedError;
  double get topP => throw _privateConstructorUsedError;
  double get presencePenalty => throw _privateConstructorUsedError;
  double get frequencyPenalty => throw _privateConstructorUsedError;
  String get systemPrompt => throw _privateConstructorUsedError;
  int get maxContextTokens => throw _privateConstructorUsedError;
  TruncationStrategy get truncationStrategy =>
      throw _privateConstructorUsedError;
  int get maxResponseTokens => throw _privateConstructorUsedError;
  bool get alwaysKeepSystemPrompt => throw _privateConstructorUsedError;
  bool get keepFirstMessage => throw _privateConstructorUsedError;
  bool get renderMarkdown => throw _privateConstructorUsedError;
  bool get enableWordByWordStreaming => throw _privateConstructorUsedError;
  int get streamingWordDelay => throw _privateConstructorUsedError;

  /// Serializes this ModelSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModelSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModelSettingsCopyWith<ModelSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModelSettingsCopyWith<$Res> {
  factory $ModelSettingsCopyWith(
          ModelSettings value, $Res Function(ModelSettings) then) =
      _$ModelSettingsCopyWithImpl<$Res, ModelSettings>;
  @useResult
  $Res call(
      {double temperature,
      double topP,
      double presencePenalty,
      double frequencyPenalty,
      String systemPrompt,
      int maxContextTokens,
      TruncationStrategy truncationStrategy,
      int maxResponseTokens,
      bool alwaysKeepSystemPrompt,
      bool keepFirstMessage,
      bool renderMarkdown,
      bool enableWordByWordStreaming,
      int streamingWordDelay});
}

/// @nodoc
class _$ModelSettingsCopyWithImpl<$Res, $Val extends ModelSettings>
    implements $ModelSettingsCopyWith<$Res> {
  _$ModelSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModelSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? temperature = null,
    Object? topP = null,
    Object? presencePenalty = null,
    Object? frequencyPenalty = null,
    Object? systemPrompt = null,
    Object? maxContextTokens = null,
    Object? truncationStrategy = null,
    Object? maxResponseTokens = null,
    Object? alwaysKeepSystemPrompt = null,
    Object? keepFirstMessage = null,
    Object? renderMarkdown = null,
    Object? enableWordByWordStreaming = null,
    Object? streamingWordDelay = null,
  }) {
    return _then(_value.copyWith(
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      topP: null == topP
          ? _value.topP
          : topP // ignore: cast_nullable_to_non_nullable
              as double,
      presencePenalty: null == presencePenalty
          ? _value.presencePenalty
          : presencePenalty // ignore: cast_nullable_to_non_nullable
              as double,
      frequencyPenalty: null == frequencyPenalty
          ? _value.frequencyPenalty
          : frequencyPenalty // ignore: cast_nullable_to_non_nullable
              as double,
      systemPrompt: null == systemPrompt
          ? _value.systemPrompt
          : systemPrompt // ignore: cast_nullable_to_non_nullable
              as String,
      maxContextTokens: null == maxContextTokens
          ? _value.maxContextTokens
          : maxContextTokens // ignore: cast_nullable_to_non_nullable
              as int,
      truncationStrategy: null == truncationStrategy
          ? _value.truncationStrategy
          : truncationStrategy // ignore: cast_nullable_to_non_nullable
              as TruncationStrategy,
      maxResponseTokens: null == maxResponseTokens
          ? _value.maxResponseTokens
          : maxResponseTokens // ignore: cast_nullable_to_non_nullable
              as int,
      alwaysKeepSystemPrompt: null == alwaysKeepSystemPrompt
          ? _value.alwaysKeepSystemPrompt
          : alwaysKeepSystemPrompt // ignore: cast_nullable_to_non_nullable
              as bool,
      keepFirstMessage: null == keepFirstMessage
          ? _value.keepFirstMessage
          : keepFirstMessage // ignore: cast_nullable_to_non_nullable
              as bool,
      renderMarkdown: null == renderMarkdown
          ? _value.renderMarkdown
          : renderMarkdown // ignore: cast_nullable_to_non_nullable
              as bool,
      enableWordByWordStreaming: null == enableWordByWordStreaming
          ? _value.enableWordByWordStreaming
          : enableWordByWordStreaming // ignore: cast_nullable_to_non_nullable
              as bool,
      streamingWordDelay: null == streamingWordDelay
          ? _value.streamingWordDelay
          : streamingWordDelay // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModelSettingsImplCopyWith<$Res>
    implements $ModelSettingsCopyWith<$Res> {
  factory _$$ModelSettingsImplCopyWith(
          _$ModelSettingsImpl value, $Res Function(_$ModelSettingsImpl) then) =
      __$$ModelSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double temperature,
      double topP,
      double presencePenalty,
      double frequencyPenalty,
      String systemPrompt,
      int maxContextTokens,
      TruncationStrategy truncationStrategy,
      int maxResponseTokens,
      bool alwaysKeepSystemPrompt,
      bool keepFirstMessage,
      bool renderMarkdown,
      bool enableWordByWordStreaming,
      int streamingWordDelay});
}

/// @nodoc
class __$$ModelSettingsImplCopyWithImpl<$Res>
    extends _$ModelSettingsCopyWithImpl<$Res, _$ModelSettingsImpl>
    implements _$$ModelSettingsImplCopyWith<$Res> {
  __$$ModelSettingsImplCopyWithImpl(
      _$ModelSettingsImpl _value, $Res Function(_$ModelSettingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ModelSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? temperature = null,
    Object? topP = null,
    Object? presencePenalty = null,
    Object? frequencyPenalty = null,
    Object? systemPrompt = null,
    Object? maxContextTokens = null,
    Object? truncationStrategy = null,
    Object? maxResponseTokens = null,
    Object? alwaysKeepSystemPrompt = null,
    Object? keepFirstMessage = null,
    Object? renderMarkdown = null,
    Object? enableWordByWordStreaming = null,
    Object? streamingWordDelay = null,
  }) {
    return _then(_$ModelSettingsImpl(
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      topP: null == topP
          ? _value.topP
          : topP // ignore: cast_nullable_to_non_nullable
              as double,
      presencePenalty: null == presencePenalty
          ? _value.presencePenalty
          : presencePenalty // ignore: cast_nullable_to_non_nullable
              as double,
      frequencyPenalty: null == frequencyPenalty
          ? _value.frequencyPenalty
          : frequencyPenalty // ignore: cast_nullable_to_non_nullable
              as double,
      systemPrompt: null == systemPrompt
          ? _value.systemPrompt
          : systemPrompt // ignore: cast_nullable_to_non_nullable
              as String,
      maxContextTokens: null == maxContextTokens
          ? _value.maxContextTokens
          : maxContextTokens // ignore: cast_nullable_to_non_nullable
              as int,
      truncationStrategy: null == truncationStrategy
          ? _value.truncationStrategy
          : truncationStrategy // ignore: cast_nullable_to_non_nullable
              as TruncationStrategy,
      maxResponseTokens: null == maxResponseTokens
          ? _value.maxResponseTokens
          : maxResponseTokens // ignore: cast_nullable_to_non_nullable
              as int,
      alwaysKeepSystemPrompt: null == alwaysKeepSystemPrompt
          ? _value.alwaysKeepSystemPrompt
          : alwaysKeepSystemPrompt // ignore: cast_nullable_to_non_nullable
              as bool,
      keepFirstMessage: null == keepFirstMessage
          ? _value.keepFirstMessage
          : keepFirstMessage // ignore: cast_nullable_to_non_nullable
              as bool,
      renderMarkdown: null == renderMarkdown
          ? _value.renderMarkdown
          : renderMarkdown // ignore: cast_nullable_to_non_nullable
              as bool,
      enableWordByWordStreaming: null == enableWordByWordStreaming
          ? _value.enableWordByWordStreaming
          : enableWordByWordStreaming // ignore: cast_nullable_to_non_nullable
              as bool,
      streamingWordDelay: null == streamingWordDelay
          ? _value.streamingWordDelay
          : streamingWordDelay // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModelSettingsImpl
    with DiagnosticableTreeMixin
    implements _ModelSettings {
  const _$ModelSettingsImpl(
      {this.temperature = 0.7,
      this.topP = 0.9,
      this.presencePenalty = 0.0,
      this.frequencyPenalty = 0.0,
      this.systemPrompt = "You are a helpful AI assistant.",
      required this.maxContextTokens,
      this.truncationStrategy = TruncationStrategy.keepSystemPrompt,
      this.maxResponseTokens = 4096,
      this.alwaysKeepSystemPrompt = true,
      this.keepFirstMessage = false,
      this.renderMarkdown = true,
      this.enableWordByWordStreaming = true,
      this.streamingWordDelay = 10});

  factory _$ModelSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModelSettingsImplFromJson(json);

  @override
  @JsonKey()
  final double temperature;
  @override
  @JsonKey()
  final double topP;
  @override
  @JsonKey()
  final double presencePenalty;
  @override
  @JsonKey()
  final double frequencyPenalty;
  @override
  @JsonKey()
  final String systemPrompt;
  @override
  final int maxContextTokens;
  @override
  @JsonKey()
  final TruncationStrategy truncationStrategy;
  @override
  @JsonKey()
  final int maxResponseTokens;
  @override
  @JsonKey()
  final bool alwaysKeepSystemPrompt;
  @override
  @JsonKey()
  final bool keepFirstMessage;
  @override
  @JsonKey()
  final bool renderMarkdown;
  @override
  @JsonKey()
  final bool enableWordByWordStreaming;
  @override
  @JsonKey()
  final int streamingWordDelay;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ModelSettings(temperature: $temperature, topP: $topP, presencePenalty: $presencePenalty, frequencyPenalty: $frequencyPenalty, systemPrompt: $systemPrompt, maxContextTokens: $maxContextTokens, truncationStrategy: $truncationStrategy, maxResponseTokens: $maxResponseTokens, alwaysKeepSystemPrompt: $alwaysKeepSystemPrompt, keepFirstMessage: $keepFirstMessage, renderMarkdown: $renderMarkdown, enableWordByWordStreaming: $enableWordByWordStreaming, streamingWordDelay: $streamingWordDelay)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ModelSettings'))
      ..add(DiagnosticsProperty('temperature', temperature))
      ..add(DiagnosticsProperty('topP', topP))
      ..add(DiagnosticsProperty('presencePenalty', presencePenalty))
      ..add(DiagnosticsProperty('frequencyPenalty', frequencyPenalty))
      ..add(DiagnosticsProperty('systemPrompt', systemPrompt))
      ..add(DiagnosticsProperty('maxContextTokens', maxContextTokens))
      ..add(DiagnosticsProperty('truncationStrategy', truncationStrategy))
      ..add(DiagnosticsProperty('maxResponseTokens', maxResponseTokens))
      ..add(
          DiagnosticsProperty('alwaysKeepSystemPrompt', alwaysKeepSystemPrompt))
      ..add(DiagnosticsProperty('keepFirstMessage', keepFirstMessage))
      ..add(DiagnosticsProperty('renderMarkdown', renderMarkdown))
      ..add(DiagnosticsProperty(
          'enableWordByWordStreaming', enableWordByWordStreaming))
      ..add(DiagnosticsProperty('streamingWordDelay', streamingWordDelay));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModelSettingsImpl &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.topP, topP) || other.topP == topP) &&
            (identical(other.presencePenalty, presencePenalty) ||
                other.presencePenalty == presencePenalty) &&
            (identical(other.frequencyPenalty, frequencyPenalty) ||
                other.frequencyPenalty == frequencyPenalty) &&
            (identical(other.systemPrompt, systemPrompt) ||
                other.systemPrompt == systemPrompt) &&
            (identical(other.maxContextTokens, maxContextTokens) ||
                other.maxContextTokens == maxContextTokens) &&
            (identical(other.truncationStrategy, truncationStrategy) ||
                other.truncationStrategy == truncationStrategy) &&
            (identical(other.maxResponseTokens, maxResponseTokens) ||
                other.maxResponseTokens == maxResponseTokens) &&
            (identical(other.alwaysKeepSystemPrompt, alwaysKeepSystemPrompt) ||
                other.alwaysKeepSystemPrompt == alwaysKeepSystemPrompt) &&
            (identical(other.keepFirstMessage, keepFirstMessage) ||
                other.keepFirstMessage == keepFirstMessage) &&
            (identical(other.renderMarkdown, renderMarkdown) ||
                other.renderMarkdown == renderMarkdown) &&
            (identical(other.enableWordByWordStreaming,
                    enableWordByWordStreaming) ||
                other.enableWordByWordStreaming == enableWordByWordStreaming) &&
            (identical(other.streamingWordDelay, streamingWordDelay) ||
                other.streamingWordDelay == streamingWordDelay));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      temperature,
      topP,
      presencePenalty,
      frequencyPenalty,
      systemPrompt,
      maxContextTokens,
      truncationStrategy,
      maxResponseTokens,
      alwaysKeepSystemPrompt,
      keepFirstMessage,
      renderMarkdown,
      enableWordByWordStreaming,
      streamingWordDelay);

  /// Create a copy of ModelSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModelSettingsImplCopyWith<_$ModelSettingsImpl> get copyWith =>
      __$$ModelSettingsImplCopyWithImpl<_$ModelSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModelSettingsImplToJson(
      this,
    );
  }
}

abstract class _ModelSettings implements ModelSettings {
  const factory _ModelSettings(
      {final double temperature,
      final double topP,
      final double presencePenalty,
      final double frequencyPenalty,
      final String systemPrompt,
      required final int maxContextTokens,
      final TruncationStrategy truncationStrategy,
      final int maxResponseTokens,
      final bool alwaysKeepSystemPrompt,
      final bool keepFirstMessage,
      final bool renderMarkdown,
      final bool enableWordByWordStreaming,
      final int streamingWordDelay}) = _$ModelSettingsImpl;

  factory _ModelSettings.fromJson(Map<String, dynamic> json) =
      _$ModelSettingsImpl.fromJson;

  @override
  double get temperature;
  @override
  double get topP;
  @override
  double get presencePenalty;
  @override
  double get frequencyPenalty;
  @override
  String get systemPrompt;
  @override
  int get maxContextTokens;
  @override
  TruncationStrategy get truncationStrategy;
  @override
  int get maxResponseTokens;
  @override
  bool get alwaysKeepSystemPrompt;
  @override
  bool get keepFirstMessage;
  @override
  bool get renderMarkdown;
  @override
  bool get enableWordByWordStreaming;
  @override
  int get streamingWordDelay;

  /// Create a copy of ModelSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModelSettingsImplCopyWith<_$ModelSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Conversation _$ConversationFromJson(Map<String, dynamic> json) {
  return _Conversation.fromJson(json);
}

/// @nodoc
mixin _$Conversation {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get providerId => throw _privateConstructorUsedError;
  String get modelId => throw _privateConstructorUsedError;
  ModelSettings get settings => throw _privateConstructorUsedError;
  int get totalTokens => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isTemporary => throw _privateConstructorUsedError;

  /// Serializes this Conversation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversationCopyWith<Conversation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationCopyWith<$Res> {
  factory $ConversationCopyWith(
          Conversation value, $Res Function(Conversation) then) =
      _$ConversationCopyWithImpl<$Res, Conversation>;
  @useResult
  $Res call(
      {String id,
      String title,
      DateTime createdAt,
      DateTime updatedAt,
      String providerId,
      String modelId,
      ModelSettings settings,
      int totalTokens,
      int sortOrder,
      bool isTemporary});

  $ModelSettingsCopyWith<$Res> get settings;
}

/// @nodoc
class _$ConversationCopyWithImpl<$Res, $Val extends Conversation>
    implements $ConversationCopyWith<$Res> {
  _$ConversationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? providerId = null,
    Object? modelId = null,
    Object? settings = null,
    Object? totalTokens = null,
    Object? sortOrder = null,
    Object? isTemporary = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      providerId: null == providerId
          ? _value.providerId
          : providerId // ignore: cast_nullable_to_non_nullable
              as String,
      modelId: null == modelId
          ? _value.modelId
          : modelId // ignore: cast_nullable_to_non_nullable
              as String,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as ModelSettings,
      totalTokens: null == totalTokens
          ? _value.totalTokens
          : totalTokens // ignore: cast_nullable_to_non_nullable
              as int,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isTemporary: null == isTemporary
          ? _value.isTemporary
          : isTemporary // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ModelSettingsCopyWith<$Res> get settings {
    return $ModelSettingsCopyWith<$Res>(_value.settings, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ConversationImplCopyWith<$Res>
    implements $ConversationCopyWith<$Res> {
  factory _$$ConversationImplCopyWith(
          _$ConversationImpl value, $Res Function(_$ConversationImpl) then) =
      __$$ConversationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      DateTime createdAt,
      DateTime updatedAt,
      String providerId,
      String modelId,
      ModelSettings settings,
      int totalTokens,
      int sortOrder,
      bool isTemporary});

  @override
  $ModelSettingsCopyWith<$Res> get settings;
}

/// @nodoc
class __$$ConversationImplCopyWithImpl<$Res>
    extends _$ConversationCopyWithImpl<$Res, _$ConversationImpl>
    implements _$$ConversationImplCopyWith<$Res> {
  __$$ConversationImplCopyWithImpl(
      _$ConversationImpl _value, $Res Function(_$ConversationImpl) _then)
      : super(_value, _then);

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? providerId = null,
    Object? modelId = null,
    Object? settings = null,
    Object? totalTokens = null,
    Object? sortOrder = null,
    Object? isTemporary = null,
  }) {
    return _then(_$ConversationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      providerId: null == providerId
          ? _value.providerId
          : providerId // ignore: cast_nullable_to_non_nullable
              as String,
      modelId: null == modelId
          ? _value.modelId
          : modelId // ignore: cast_nullable_to_non_nullable
              as String,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as ModelSettings,
      totalTokens: null == totalTokens
          ? _value.totalTokens
          : totalTokens // ignore: cast_nullable_to_non_nullable
              as int,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isTemporary: null == isTemporary
          ? _value.isTemporary
          : isTemporary // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConversationImpl with DiagnosticableTreeMixin implements _Conversation {
  const _$ConversationImpl(
      {required this.id,
      required this.title,
      required this.createdAt,
      required this.updatedAt,
      required this.providerId,
      required this.modelId,
      required this.settings,
      this.totalTokens = 0,
      this.sortOrder = 0,
      this.isTemporary = false});

  factory _$ConversationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConversationImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String providerId;
  @override
  final String modelId;
  @override
  final ModelSettings settings;
  @override
  @JsonKey()
  final int totalTokens;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  @JsonKey()
  final bool isTemporary;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Conversation(id: $id, title: $title, createdAt: $createdAt, updatedAt: $updatedAt, providerId: $providerId, modelId: $modelId, settings: $settings, totalTokens: $totalTokens, sortOrder: $sortOrder, isTemporary: $isTemporary)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Conversation'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('providerId', providerId))
      ..add(DiagnosticsProperty('modelId', modelId))
      ..add(DiagnosticsProperty('settings', settings))
      ..add(DiagnosticsProperty('totalTokens', totalTokens))
      ..add(DiagnosticsProperty('sortOrder', sortOrder))
      ..add(DiagnosticsProperty('isTemporary', isTemporary));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.providerId, providerId) ||
                other.providerId == providerId) &&
            (identical(other.modelId, modelId) || other.modelId == modelId) &&
            (identical(other.settings, settings) ||
                other.settings == settings) &&
            (identical(other.totalTokens, totalTokens) ||
                other.totalTokens == totalTokens) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isTemporary, isTemporary) ||
                other.isTemporary == isTemporary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, createdAt, updatedAt,
      providerId, modelId, settings, totalTokens, sortOrder, isTemporary);

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationImplCopyWith<_$ConversationImpl> get copyWith =>
      __$$ConversationImplCopyWithImpl<_$ConversationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConversationImplToJson(
      this,
    );
  }
}

abstract class _Conversation implements Conversation {
  const factory _Conversation(
      {required final String id,
      required final String title,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final String providerId,
      required final String modelId,
      required final ModelSettings settings,
      final int totalTokens,
      final int sortOrder,
      final bool isTemporary}) = _$ConversationImpl;

  factory _Conversation.fromJson(Map<String, dynamic> json) =
      _$ConversationImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String get providerId;
  @override
  String get modelId;
  @override
  ModelSettings get settings;
  @override
  int get totalTokens;
  @override
  int get sortOrder;
  @override
  bool get isTemporary;

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversationImplCopyWith<_$ConversationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Message _$MessageFromJson(Map<String, dynamic> json) {
  return _Message.fromJson(json);
}

/// @nodoc
mixin _$Message {
  String get id => throw _privateConstructorUsedError;
  String get conversationId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  Role get role => throw _privateConstructorUsedError;
  String get timestamp => throw _privateConstructorUsedError;
  int get tokenCount => throw _privateConstructorUsedError;
  bool get isPlaceholder => throw _privateConstructorUsedError;

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageCopyWith<Message> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageCopyWith<$Res> {
  factory $MessageCopyWith(Message value, $Res Function(Message) then) =
      _$MessageCopyWithImpl<$Res, Message>;
  @useResult
  $Res call(
      {String id,
      String conversationId,
      String content,
      Role role,
      String timestamp,
      int tokenCount,
      bool isPlaceholder});
}

/// @nodoc
class _$MessageCopyWithImpl<$Res, $Val extends Message>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? content = null,
    Object? role = null,
    Object? timestamp = null,
    Object? tokenCount = null,
    Object? isPlaceholder = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as Role,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String,
      tokenCount: null == tokenCount
          ? _value.tokenCount
          : tokenCount // ignore: cast_nullable_to_non_nullable
              as int,
      isPlaceholder: null == isPlaceholder
          ? _value.isPlaceholder
          : isPlaceholder // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageImplCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$$MessageImplCopyWith(
          _$MessageImpl value, $Res Function(_$MessageImpl) then) =
      __$$MessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String conversationId,
      String content,
      Role role,
      String timestamp,
      int tokenCount,
      bool isPlaceholder});
}

/// @nodoc
class __$$MessageImplCopyWithImpl<$Res>
    extends _$MessageCopyWithImpl<$Res, _$MessageImpl>
    implements _$$MessageImplCopyWith<$Res> {
  __$$MessageImplCopyWithImpl(
      _$MessageImpl _value, $Res Function(_$MessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? content = null,
    Object? role = null,
    Object? timestamp = null,
    Object? tokenCount = null,
    Object? isPlaceholder = null,
  }) {
    return _then(_$MessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as Role,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String,
      tokenCount: null == tokenCount
          ? _value.tokenCount
          : tokenCount // ignore: cast_nullable_to_non_nullable
              as int,
      isPlaceholder: null == isPlaceholder
          ? _value.isPlaceholder
          : isPlaceholder // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageImpl with DiagnosticableTreeMixin implements _Message {
  const _$MessageImpl(
      {required this.id,
      required this.conversationId,
      required this.content,
      required this.role,
      required this.timestamp,
      this.tokenCount = 0,
      this.isPlaceholder = false});

  factory _$MessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageImplFromJson(json);

  @override
  final String id;
  @override
  final String conversationId;
  @override
  final String content;
  @override
  final Role role;
  @override
  final String timestamp;
  @override
  @JsonKey()
  final int tokenCount;
  @override
  @JsonKey()
  final bool isPlaceholder;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Message(id: $id, conversationId: $conversationId, content: $content, role: $role, timestamp: $timestamp, tokenCount: $tokenCount, isPlaceholder: $isPlaceholder)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Message'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('conversationId', conversationId))
      ..add(DiagnosticsProperty('content', content))
      ..add(DiagnosticsProperty('role', role))
      ..add(DiagnosticsProperty('timestamp', timestamp))
      ..add(DiagnosticsProperty('tokenCount', tokenCount))
      ..add(DiagnosticsProperty('isPlaceholder', isPlaceholder));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.tokenCount, tokenCount) ||
                other.tokenCount == tokenCount) &&
            (identical(other.isPlaceholder, isPlaceholder) ||
                other.isPlaceholder == isPlaceholder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, conversationId, content,
      role, timestamp, tokenCount, isPlaceholder);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      __$$MessageImplCopyWithImpl<_$MessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageImplToJson(
      this,
    );
  }
}

abstract class _Message implements Message {
  const factory _Message(
      {required final String id,
      required final String conversationId,
      required final String content,
      required final Role role,
      required final String timestamp,
      final int tokenCount,
      final bool isPlaceholder}) = _$MessageImpl;

  factory _Message.fromJson(Map<String, dynamic> json) = _$MessageImpl.fromJson;

  @override
  String get id;
  @override
  String get conversationId;
  @override
  String get content;
  @override
  Role get role;
  @override
  String get timestamp;
  @override
  int get tokenCount;
  @override
  bool get isPlaceholder;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TokenPrice _$TokenPriceFromJson(Map<String, dynamic> json) {
  return _TokenPrice.fromJson(json);
}

/// @nodoc
mixin _$TokenPrice {
  double get price => throw _privateConstructorUsedError;
  int? get minTokens => throw _privateConstructorUsedError;
  int? get maxTokens => throw _privateConstructorUsedError;

  /// Serializes this TokenPrice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TokenPrice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TokenPriceCopyWith<TokenPrice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenPriceCopyWith<$Res> {
  factory $TokenPriceCopyWith(
          TokenPrice value, $Res Function(TokenPrice) then) =
      _$TokenPriceCopyWithImpl<$Res, TokenPrice>;
  @useResult
  $Res call({double price, int? minTokens, int? maxTokens});
}

/// @nodoc
class _$TokenPriceCopyWithImpl<$Res, $Val extends TokenPrice>
    implements $TokenPriceCopyWith<$Res> {
  _$TokenPriceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TokenPrice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? price = null,
    Object? minTokens = freezed,
    Object? maxTokens = freezed,
  }) {
    return _then(_value.copyWith(
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      minTokens: freezed == minTokens
          ? _value.minTokens
          : minTokens // ignore: cast_nullable_to_non_nullable
              as int?,
      maxTokens: freezed == maxTokens
          ? _value.maxTokens
          : maxTokens // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TokenPriceImplCopyWith<$Res>
    implements $TokenPriceCopyWith<$Res> {
  factory _$$TokenPriceImplCopyWith(
          _$TokenPriceImpl value, $Res Function(_$TokenPriceImpl) then) =
      __$$TokenPriceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double price, int? minTokens, int? maxTokens});
}

/// @nodoc
class __$$TokenPriceImplCopyWithImpl<$Res>
    extends _$TokenPriceCopyWithImpl<$Res, _$TokenPriceImpl>
    implements _$$TokenPriceImplCopyWith<$Res> {
  __$$TokenPriceImplCopyWithImpl(
      _$TokenPriceImpl _value, $Res Function(_$TokenPriceImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenPrice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? price = null,
    Object? minTokens = freezed,
    Object? maxTokens = freezed,
  }) {
    return _then(_$TokenPriceImpl(
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      minTokens: freezed == minTokens
          ? _value.minTokens
          : minTokens // ignore: cast_nullable_to_non_nullable
              as int?,
      maxTokens: freezed == maxTokens
          ? _value.maxTokens
          : maxTokens // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenPriceImpl with DiagnosticableTreeMixin implements _TokenPrice {
  const _$TokenPriceImpl({required this.price, this.minTokens, this.maxTokens});

  factory _$TokenPriceImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenPriceImplFromJson(json);

  @override
  final double price;
  @override
  final int? minTokens;
  @override
  final int? maxTokens;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TokenPrice(price: $price, minTokens: $minTokens, maxTokens: $maxTokens)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TokenPrice'))
      ..add(DiagnosticsProperty('price', price))
      ..add(DiagnosticsProperty('minTokens', minTokens))
      ..add(DiagnosticsProperty('maxTokens', maxTokens));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenPriceImpl &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.minTokens, minTokens) ||
                other.minTokens == minTokens) &&
            (identical(other.maxTokens, maxTokens) ||
                other.maxTokens == maxTokens));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, price, minTokens, maxTokens);

  /// Create a copy of TokenPrice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenPriceImplCopyWith<_$TokenPriceImpl> get copyWith =>
      __$$TokenPriceImplCopyWithImpl<_$TokenPriceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenPriceImplToJson(
      this,
    );
  }
}

abstract class _TokenPrice implements TokenPrice {
  const factory _TokenPrice(
      {required final double price,
      final int? minTokens,
      final int? maxTokens}) = _$TokenPriceImpl;

  factory _TokenPrice.fromJson(Map<String, dynamic> json) =
      _$TokenPriceImpl.fromJson;

  @override
  double get price;
  @override
  int? get minTokens;
  @override
  int? get maxTokens;

  /// Create a copy of TokenPrice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenPriceImplCopyWith<_$TokenPriceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ModelPricing _$ModelPricingFromJson(Map<String, dynamic> json) {
  return _ModelPricing.fromJson(json);
}

/// @nodoc
mixin _$ModelPricing {
  List<TokenPrice> get input => throw _privateConstructorUsedError;
  List<TokenPrice> get output => throw _privateConstructorUsedError;
  List<TokenPrice>? get batchInput => throw _privateConstructorUsedError;
  List<TokenPrice>? get batchOutput => throw _privateConstructorUsedError;
  List<TokenPrice>? get cacheRead => throw _privateConstructorUsedError;
  double? get cacheWrite => throw _privateConstructorUsedError;

  /// Serializes this ModelPricing to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModelPricing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModelPricingCopyWith<ModelPricing> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModelPricingCopyWith<$Res> {
  factory $ModelPricingCopyWith(
          ModelPricing value, $Res Function(ModelPricing) then) =
      _$ModelPricingCopyWithImpl<$Res, ModelPricing>;
  @useResult
  $Res call(
      {List<TokenPrice> input,
      List<TokenPrice> output,
      List<TokenPrice>? batchInput,
      List<TokenPrice>? batchOutput,
      List<TokenPrice>? cacheRead,
      double? cacheWrite});
}

/// @nodoc
class _$ModelPricingCopyWithImpl<$Res, $Val extends ModelPricing>
    implements $ModelPricingCopyWith<$Res> {
  _$ModelPricingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModelPricing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? input = null,
    Object? output = null,
    Object? batchInput = freezed,
    Object? batchOutput = freezed,
    Object? cacheRead = freezed,
    Object? cacheWrite = freezed,
  }) {
    return _then(_value.copyWith(
      input: null == input
          ? _value.input
          : input // ignore: cast_nullable_to_non_nullable
              as List<TokenPrice>,
      output: null == output
          ? _value.output
          : output // ignore: cast_nullable_to_non_nullable
              as List<TokenPrice>,
      batchInput: freezed == batchInput
          ? _value.batchInput
          : batchInput // ignore: cast_nullable_to_non_nullable
              as List<TokenPrice>?,
      batchOutput: freezed == batchOutput
          ? _value.batchOutput
          : batchOutput // ignore: cast_nullable_to_non_nullable
              as List<TokenPrice>?,
      cacheRead: freezed == cacheRead
          ? _value.cacheRead
          : cacheRead // ignore: cast_nullable_to_non_nullable
              as List<TokenPrice>?,
      cacheWrite: freezed == cacheWrite
          ? _value.cacheWrite
          : cacheWrite // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModelPricingImplCopyWith<$Res>
    implements $ModelPricingCopyWith<$Res> {
  factory _$$ModelPricingImplCopyWith(
          _$ModelPricingImpl value, $Res Function(_$ModelPricingImpl) then) =
      __$$ModelPricingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<TokenPrice> input,
      List<TokenPrice> output,
      List<TokenPrice>? batchInput,
      List<TokenPrice>? batchOutput,
      List<TokenPrice>? cacheRead,
      double? cacheWrite});
}

/// @nodoc
class __$$ModelPricingImplCopyWithImpl<$Res>
    extends _$ModelPricingCopyWithImpl<$Res, _$ModelPricingImpl>
    implements _$$ModelPricingImplCopyWith<$Res> {
  __$$ModelPricingImplCopyWithImpl(
      _$ModelPricingImpl _value, $Res Function(_$ModelPricingImpl) _then)
      : super(_value, _then);

  /// Create a copy of ModelPricing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? input = null,
    Object? output = null,
    Object? batchInput = freezed,
    Object? batchOutput = freezed,
    Object? cacheRead = freezed,
    Object? cacheWrite = freezed,
  }) {
    return _then(_$ModelPricingImpl(
      input: null == input
          ? _value._input
          : input // ignore: cast_nullable_to_non_nullable
              as List<TokenPrice>,
      output: null == output
          ? _value._output
          : output // ignore: cast_nullable_to_non_nullable
              as List<TokenPrice>,
      batchInput: freezed == batchInput
          ? _value._batchInput
          : batchInput // ignore: cast_nullable_to_non_nullable
              as List<TokenPrice>?,
      batchOutput: freezed == batchOutput
          ? _value._batchOutput
          : batchOutput // ignore: cast_nullable_to_non_nullable
              as List<TokenPrice>?,
      cacheRead: freezed == cacheRead
          ? _value._cacheRead
          : cacheRead // ignore: cast_nullable_to_non_nullable
              as List<TokenPrice>?,
      cacheWrite: freezed == cacheWrite
          ? _value.cacheWrite
          : cacheWrite // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModelPricingImpl with DiagnosticableTreeMixin implements _ModelPricing {
  const _$ModelPricingImpl(
      {required final List<TokenPrice> input,
      required final List<TokenPrice> output,
      final List<TokenPrice>? batchInput,
      final List<TokenPrice>? batchOutput,
      final List<TokenPrice>? cacheRead,
      this.cacheWrite})
      : _input = input,
        _output = output,
        _batchInput = batchInput,
        _batchOutput = batchOutput,
        _cacheRead = cacheRead;

  factory _$ModelPricingImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModelPricingImplFromJson(json);

  final List<TokenPrice> _input;
  @override
  List<TokenPrice> get input {
    if (_input is EqualUnmodifiableListView) return _input;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_input);
  }

  final List<TokenPrice> _output;
  @override
  List<TokenPrice> get output {
    if (_output is EqualUnmodifiableListView) return _output;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_output);
  }

  final List<TokenPrice>? _batchInput;
  @override
  List<TokenPrice>? get batchInput {
    final value = _batchInput;
    if (value == null) return null;
    if (_batchInput is EqualUnmodifiableListView) return _batchInput;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<TokenPrice>? _batchOutput;
  @override
  List<TokenPrice>? get batchOutput {
    final value = _batchOutput;
    if (value == null) return null;
    if (_batchOutput is EqualUnmodifiableListView) return _batchOutput;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<TokenPrice>? _cacheRead;
  @override
  List<TokenPrice>? get cacheRead {
    final value = _cacheRead;
    if (value == null) return null;
    if (_cacheRead is EqualUnmodifiableListView) return _cacheRead;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final double? cacheWrite;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ModelPricing(input: $input, output: $output, batchInput: $batchInput, batchOutput: $batchOutput, cacheRead: $cacheRead, cacheWrite: $cacheWrite)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ModelPricing'))
      ..add(DiagnosticsProperty('input', input))
      ..add(DiagnosticsProperty('output', output))
      ..add(DiagnosticsProperty('batchInput', batchInput))
      ..add(DiagnosticsProperty('batchOutput', batchOutput))
      ..add(DiagnosticsProperty('cacheRead', cacheRead))
      ..add(DiagnosticsProperty('cacheWrite', cacheWrite));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModelPricingImpl &&
            const DeepCollectionEquality().equals(other._input, _input) &&
            const DeepCollectionEquality().equals(other._output, _output) &&
            const DeepCollectionEquality()
                .equals(other._batchInput, _batchInput) &&
            const DeepCollectionEquality()
                .equals(other._batchOutput, _batchOutput) &&
            const DeepCollectionEquality()
                .equals(other._cacheRead, _cacheRead) &&
            (identical(other.cacheWrite, cacheWrite) ||
                other.cacheWrite == cacheWrite));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_input),
      const DeepCollectionEquality().hash(_output),
      const DeepCollectionEquality().hash(_batchInput),
      const DeepCollectionEquality().hash(_batchOutput),
      const DeepCollectionEquality().hash(_cacheRead),
      cacheWrite);

  /// Create a copy of ModelPricing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModelPricingImplCopyWith<_$ModelPricingImpl> get copyWith =>
      __$$ModelPricingImplCopyWithImpl<_$ModelPricingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModelPricingImplToJson(
      this,
    );
  }
}

abstract class _ModelPricing implements ModelPricing {
  const factory _ModelPricing(
      {required final List<TokenPrice> input,
      required final List<TokenPrice> output,
      final List<TokenPrice>? batchInput,
      final List<TokenPrice>? batchOutput,
      final List<TokenPrice>? cacheRead,
      final double? cacheWrite}) = _$ModelPricingImpl;

  factory _ModelPricing.fromJson(Map<String, dynamic> json) =
      _$ModelPricingImpl.fromJson;

  @override
  List<TokenPrice> get input;
  @override
  List<TokenPrice> get output;
  @override
  List<TokenPrice>? get batchInput;
  @override
  List<TokenPrice>? get batchOutput;
  @override
  List<TokenPrice>? get cacheRead;
  @override
  double? get cacheWrite;

  /// Create a copy of ModelPricing
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModelPricingImplCopyWith<_$ModelPricingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
