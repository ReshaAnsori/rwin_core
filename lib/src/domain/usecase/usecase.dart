// ignore_for_file: avoid_types_as_parameter_names
import 'package:rwin_core/src/domain/typedef.dart';

/// Use case that takes [Params] and returns [ResultFuture<Type>].
abstract class UsecaseWithParams<Type, Params> {
  const UsecaseWithParams();
  ResultFuture<Type> call(Params params);
}

/// Use case that takes [Params] and returns [VoidFuture].
abstract class UsecaseVoidWithParams<Params> {
  const UsecaseVoidWithParams();
  VoidFuture call(Params params);
}

/// Use case with no params that returns [ResultFuture<Type>].
abstract class UsecaseWithoutParams<Type> {
  const UsecaseWithoutParams();
  ResultFuture<Type> call();
}

/// Use case with no params that returns [VoidFuture].
abstract class UsecaseVoidWithoutParams {
  const UsecaseVoidWithoutParams();
  VoidFuture call();
}
