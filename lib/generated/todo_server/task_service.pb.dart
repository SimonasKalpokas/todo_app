// This is a generated file - do not edit.
//
// Generated from todo_server/task_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'task_service.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'task_service.pbenum.dart';

class CreateTaskRequest extends $pb.GeneratedMessage {
  factory CreateTaskRequest({
    TaskType? type,
    $core.String? parentId,
    $core.String? name,
    $core.String? description,
    Reoccurrence? reoccurrence,
  }) {
    final result = CreateTaskRequest._();
    if (type != null) result.type = type;
    if (parentId != null) result.parentId = parentId;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (reoccurrence != null) result.reoccurrence = reoccurrence;
    return result;
  }

  CreateTaskRequest._();

  factory CreateTaskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateTaskRequest()..mergeFromBuffer(data, registry);
  factory CreateTaskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateTaskRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateTaskRequest',
      createEmptyInstance: CreateTaskRequest.$_createMessage)
    ..aE<TaskType>(1, _omitFieldNames ? '' : 'type',
        enumValues: TaskType.values)
    ..aOS(2, _omitFieldNames ? '' : 'parentId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aE<Reoccurrence>(5, _omitFieldNames ? '' : 'reoccurrence',
        enumValues: Reoccurrence.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTaskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTaskRequest copyWith(void Function(CreateTaskRequest) updates) =>
      super.copyWith((message) => updates(message as CreateTaskRequest))
          as CreateTaskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateTaskRequest() / CreateTaskRequest.new instead')
  static CreateTaskRequest create() => CreateTaskRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateTaskRequest._();
  @$core.override
  CreateTaskRequest createEmptyInstance() => CreateTaskRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateTaskRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateTaskRequest>(
          CreateTaskRequest.$_createMessage);
  static CreateTaskRequest? _defaultInstance;

  @$pb.TagNumber(1)
  TaskType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(TaskType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get parentId => $_getSZ(1);
  @$pb.TagNumber(2)
  set parentId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasParentId() => $_has(1);
  @$pb.TagNumber(2)
  void clearParentId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  Reoccurrence get reoccurrence => $_getN(4);
  @$pb.TagNumber(5)
  set reoccurrence(Reoccurrence value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasReoccurrence() => $_has(4);
  @$pb.TagNumber(5)
  void clearReoccurrence() => $_clearField(5);
}

class CreateTaskResponse extends $pb.GeneratedMessage {
  factory CreateTaskResponse() => CreateTaskResponse._();

  CreateTaskResponse._();

  factory CreateTaskResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateTaskResponse()..mergeFromBuffer(data, registry);
  factory CreateTaskResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateTaskResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateTaskResponse',
      createEmptyInstance: CreateTaskResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTaskResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTaskResponse copyWith(void Function(CreateTaskResponse) updates) =>
      super.copyWith((message) => updates(message as CreateTaskResponse))
          as CreateTaskResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateTaskResponse() / CreateTaskResponse.new instead')
  static CreateTaskResponse create() => CreateTaskResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateTaskResponse._();
  @$core.override
  CreateTaskResponse createEmptyInstance() => CreateTaskResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateTaskResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateTaskResponse>(
          CreateTaskResponse.$_createMessage);
  static CreateTaskResponse? _defaultInstance;
}

class CompleteTaskRequest extends $pb.GeneratedMessage {
  factory CompleteTaskRequest({
    $core.String? taskId,
  }) {
    final result = CompleteTaskRequest._();
    if (taskId != null) result.taskId = taskId;
    return result;
  }

  CompleteTaskRequest._();

  factory CompleteTaskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CompleteTaskRequest()..mergeFromBuffer(data, registry);
  factory CompleteTaskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CompleteTaskRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CompleteTaskRequest',
      createEmptyInstance: CompleteTaskRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'taskId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CompleteTaskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CompleteTaskRequest copyWith(void Function(CompleteTaskRequest) updates) =>
      super.copyWith((message) => updates(message as CompleteTaskRequest))
          as CompleteTaskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use CompleteTaskRequest() / CompleteTaskRequest.new instead')
  static CompleteTaskRequest create() => CompleteTaskRequest._();
  static $pb.GeneratedMessage $_createMessage() => CompleteTaskRequest._();
  @$core.override
  CompleteTaskRequest createEmptyInstance() => CompleteTaskRequest._();
  @$core.pragma('dart2js:noInline')
  static CompleteTaskRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CompleteTaskRequest>(
          CompleteTaskRequest.$_createMessage);
  static CompleteTaskRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get taskId => $_getSZ(0);
  @$pb.TagNumber(1)
  set taskId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTaskId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTaskId() => $_clearField(1);
}

class CompleteTaskResponse extends $pb.GeneratedMessage {
  factory CompleteTaskResponse() => CompleteTaskResponse._();

  CompleteTaskResponse._();

  factory CompleteTaskResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CompleteTaskResponse()..mergeFromBuffer(data, registry);
  factory CompleteTaskResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CompleteTaskResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CompleteTaskResponse',
      createEmptyInstance: CompleteTaskResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CompleteTaskResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CompleteTaskResponse copyWith(void Function(CompleteTaskResponse) updates) =>
      super.copyWith((message) => updates(message as CompleteTaskResponse))
          as CompleteTaskResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CompleteTaskResponse() / CompleteTaskResponse.new instead')
  static CompleteTaskResponse create() => CompleteTaskResponse._();
  static $pb.GeneratedMessage $_createMessage() => CompleteTaskResponse._();
  @$core.override
  CompleteTaskResponse createEmptyInstance() => CompleteTaskResponse._();
  @$core.pragma('dart2js:noInline')
  static CompleteTaskResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CompleteTaskResponse>(
          CompleteTaskResponse.$_createMessage);
  static CompleteTaskResponse? _defaultInstance;
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
