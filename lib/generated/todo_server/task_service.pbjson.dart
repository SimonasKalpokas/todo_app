// This is a generated file - do not edit.
//
// Generated from todo_server/task_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use taskTypeDescriptor instead')
const TaskType$json = {
  '1': 'TaskType',
  '2': [
    {'1': 'TASK_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'TASK_TYPE_CHECKED', '2': 1},
    {'1': 'TASK_TYPE_TIMED', '2': 2},
    {'1': 'TASK_TYPE_PARENT', '2': 3},
  ],
};

/// Descriptor for `TaskType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List taskTypeDescriptor = $convert.base64Decode(
    'CghUYXNrVHlwZRIZChVUQVNLX1RZUEVfVU5TUEVDSUZJRUQQABIVChFUQVNLX1RZUEVfQ0hFQ0'
    'tFRBABEhMKD1RBU0tfVFlQRV9USU1FRBACEhQKEFRBU0tfVFlQRV9QQVJFTlQQAw==');

@$core.Deprecated('Use reoccurrenceDescriptor instead')
const Reoccurrence$json = {
  '1': 'Reoccurrence',
  '2': [
    {'1': 'REOCCURRENCE_UNSPECIFIED', '2': 0},
    {'1': 'REOCCURRENCE_NOT_REPEATING', '2': 1},
    {'1': 'REOCCURRENCE_DAILY', '2': 2},
    {'1': 'REOCCURRENCE_WEEKLY', '2': 3},
  ],
};

/// Descriptor for `Reoccurrence`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List reoccurrenceDescriptor = $convert.base64Decode(
    'CgxSZW9jY3VycmVuY2USHAoYUkVPQ0NVUlJFTkNFX1VOU1BFQ0lGSUVEEAASHgoaUkVPQ0NVUl'
    'JFTkNFX05PVF9SRVBFQVRJTkcQARIWChJSRU9DQ1VSUkVOQ0VfREFJTFkQAhIXChNSRU9DQ1VS'
    'UkVOQ0VfV0VFS0xZEAM=');

@$core.Deprecated('Use createTaskRequestDescriptor instead')
const CreateTaskRequest$json = {
  '1': 'CreateTaskRequest',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.TaskType', '10': 'type'},
    {
      '1': 'parent_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'parentId',
      '17': true
    },
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'reoccurrence',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.Reoccurrence',
      '10': 'reoccurrence'
    },
  ],
  '8': [
    {'1': '_parent_id'},
  ],
};

/// Descriptor for `CreateTaskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createTaskRequestDescriptor = $convert.base64Decode(
    'ChFDcmVhdGVUYXNrUmVxdWVzdBIdCgR0eXBlGAEgASgOMgkuVGFza1R5cGVSBHR5cGUSIAoJcG'
    'FyZW50X2lkGAIgASgJSABSCHBhcmVudElkiAEBEhIKBG5hbWUYAyABKAlSBG5hbWUSIAoLZGVz'
    'Y3JpcHRpb24YBCABKAlSC2Rlc2NyaXB0aW9uEjEKDHJlb2NjdXJyZW5jZRgFIAEoDjINLlJlb2'
    'NjdXJyZW5jZVIMcmVvY2N1cnJlbmNlQgwKCl9wYXJlbnRfaWQ=');

@$core.Deprecated('Use createTaskResponseDescriptor instead')
const CreateTaskResponse$json = {
  '1': 'CreateTaskResponse',
};

/// Descriptor for `CreateTaskResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createTaskResponseDescriptor =
    $convert.base64Decode('ChJDcmVhdGVUYXNrUmVzcG9uc2U=');

@$core.Deprecated('Use completeTaskRequestDescriptor instead')
const CompleteTaskRequest$json = {
  '1': 'CompleteTaskRequest',
  '2': [
    {'1': 'task_id', '3': 1, '4': 1, '5': 9, '10': 'taskId'},
  ],
};

/// Descriptor for `CompleteTaskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List completeTaskRequestDescriptor =
    $convert.base64Decode(
        'ChNDb21wbGV0ZVRhc2tSZXF1ZXN0EhcKB3Rhc2tfaWQYASABKAlSBnRhc2tJZA==');

@$core.Deprecated('Use completeTaskResponseDescriptor instead')
const CompleteTaskResponse$json = {
  '1': 'CompleteTaskResponse',
};

/// Descriptor for `CompleteTaskResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List completeTaskResponseDescriptor =
    $convert.base64Decode('ChRDb21wbGV0ZVRhc2tSZXNwb25zZQ==');
