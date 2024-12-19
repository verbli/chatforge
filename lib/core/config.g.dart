// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RuntimeConfigImpl _$$RuntimeConfigImplFromJson(Map<String, dynamic> json) =>
    _$RuntimeConfigImpl(
      backend: BackendConfig.fromJson(json['backend'] as Map<String, dynamic>),
      showAds: json['showAds'] as bool? ?? true,
      enterpriseName: json['enterpriseName'] as String?,
      enterpriseLogo: json['enterpriseLogo'] as String?,
    );

Map<String, dynamic> _$$RuntimeConfigImplToJson(_$RuntimeConfigImpl instance) =>
    <String, dynamic>{
      'backend': instance.backend,
      'showAds': instance.showAds,
      'enterpriseName': instance.enterpriseName,
      'enterpriseLogo': instance.enterpriseLogo,
    };

_$LocalBackendImpl _$$LocalBackendImplFromJson(Map<String, dynamic> json) =>
    _$LocalBackendImpl(
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$LocalBackendImplToJson(_$LocalBackendImpl instance) =>
    <String, dynamic>{
      'runtimeType': instance.$type,
    };

_$SupabaseBackendImpl _$$SupabaseBackendImplFromJson(
        Map<String, dynamic> json) =>
    _$SupabaseBackendImpl(
      url: json['url'] as String,
      anonKey: json['anonKey'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$SupabaseBackendImplToJson(
        _$SupabaseBackendImpl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'anonKey': instance.anonKey,
      'runtimeType': instance.$type,
    };

_$PocketbaseBackendImpl _$$PocketbaseBackendImplFromJson(
        Map<String, dynamic> json) =>
    _$PocketbaseBackendImpl(
      url: json['url'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$PocketbaseBackendImplToJson(
        _$PocketbaseBackendImpl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'runtimeType': instance.$type,
    };

_$AppwriteBackendImpl _$$AppwriteBackendImplFromJson(
        Map<String, dynamic> json) =>
    _$AppwriteBackendImpl(
      endpoint: json['endpoint'] as String,
      projectId: json['projectId'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$AppwriteBackendImplToJson(
        _$AppwriteBackendImpl instance) =>
    <String, dynamic>{
      'endpoint': instance.endpoint,
      'projectId': instance.projectId,
      'runtimeType': instance.$type,
    };
