// This is a generated file - do not edit.
//
// Generated from todo_server/task_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'task_service.pb.dart' as $0;

export 'task_service.pb.dart';

@$pb.GrpcServiceName('TaskService')
class TaskServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  TaskServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.CreateTaskResponse> createTask(
    $0.CreateTaskRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createTask, request, options: options);
  }

  /// rpc GetTasks(GetTasksRequest) returns (GetTasksResponse) {}
  $grpc.ResponseFuture<$0.CompleteTaskResponse> completeTask(
    $0.CompleteTaskRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$completeTask, request, options: options);
  }

  // method descriptors

  static final _$createTask =
      $grpc.ClientMethod<$0.CreateTaskRequest, $0.CreateTaskResponse>(
          '/TaskService/CreateTask',
          ($0.CreateTaskRequest value) => value.writeToBuffer(),
          $0.CreateTaskResponse.fromBuffer);
  static final _$completeTask =
      $grpc.ClientMethod<$0.CompleteTaskRequest, $0.CompleteTaskResponse>(
          '/TaskService/CompleteTask',
          ($0.CompleteTaskRequest value) => value.writeToBuffer(),
          $0.CompleteTaskResponse.fromBuffer);
}

@$pb.GrpcServiceName('TaskService')
abstract class TaskServiceBase extends $grpc.Service {
  $core.String get $name => 'TaskService';

  TaskServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.CreateTaskRequest, $0.CreateTaskResponse>(
        'CreateTask',
        createTask_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CreateTaskRequest.fromBuffer(value),
        ($0.CreateTaskResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.CompleteTaskRequest, $0.CompleteTaskResponse>(
            'CompleteTask',
            completeTask_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.CompleteTaskRequest.fromBuffer(value),
            ($0.CompleteTaskResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.CreateTaskResponse> createTask_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreateTaskRequest> $request) async {
    return createTask($call, await $request);
  }

  $async.Future<$0.CreateTaskResponse> createTask(
      $grpc.ServiceCall call, $0.CreateTaskRequest request);

  $async.Future<$0.CompleteTaskResponse> completeTask_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CompleteTaskRequest> $request) async {
    return completeTask($call, await $request);
  }

  $async.Future<$0.CompleteTaskResponse> completeTask(
      $grpc.ServiceCall call, $0.CompleteTaskRequest request);
}
