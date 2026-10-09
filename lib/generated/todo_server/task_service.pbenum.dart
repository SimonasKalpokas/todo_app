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

class TaskType extends $pb.ProtobufEnum {
  static const TaskType TASK_TYPE_UNSPECIFIED =
      TaskType._(0, _omitEnumNames ? '' : 'TASK_TYPE_UNSPECIFIED');
  static const TaskType TASK_TYPE_CHECKED =
      TaskType._(1, _omitEnumNames ? '' : 'TASK_TYPE_CHECKED');
  static const TaskType TASK_TYPE_TIMED =
      TaskType._(2, _omitEnumNames ? '' : 'TASK_TYPE_TIMED');
  static const TaskType TASK_TYPE_PARENT =
      TaskType._(3, _omitEnumNames ? '' : 'TASK_TYPE_PARENT');

  static const $core.List<TaskType> values = <TaskType>[
    TASK_TYPE_UNSPECIFIED,
    TASK_TYPE_CHECKED,
    TASK_TYPE_TIMED,
    TASK_TYPE_PARENT,
  ];

  static final $core.List<TaskType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static TaskType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TaskType._(super.value, super.name);
}

class Reoccurrence extends $pb.ProtobufEnum {
  static const Reoccurrence REOCCURRENCE_UNSPECIFIED =
      Reoccurrence._(0, _omitEnumNames ? '' : 'REOCCURRENCE_UNSPECIFIED');
  static const Reoccurrence REOCCURRENCE_NOT_REPEATING =
      Reoccurrence._(1, _omitEnumNames ? '' : 'REOCCURRENCE_NOT_REPEATING');
  static const Reoccurrence REOCCURRENCE_DAILY =
      Reoccurrence._(2, _omitEnumNames ? '' : 'REOCCURRENCE_DAILY');
  static const Reoccurrence REOCCURRENCE_WEEKLY =
      Reoccurrence._(3, _omitEnumNames ? '' : 'REOCCURRENCE_WEEKLY');

  static const $core.List<Reoccurrence> values = <Reoccurrence>[
    REOCCURRENCE_UNSPECIFIED,
    REOCCURRENCE_NOT_REPEATING,
    REOCCURRENCE_DAILY,
    REOCCURRENCE_WEEKLY,
  ];

  static final $core.List<Reoccurrence?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static Reoccurrence? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Reoccurrence._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
