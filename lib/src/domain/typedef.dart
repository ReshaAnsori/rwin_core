import 'package:dartz/dartz.dart';
import 'package:rwin_core/src/error/failure.dart';

/// A Future that resolves to either a [Failure] or a value of type [T].
typedef ResultFuture<T> = Future<Either<Failure, T>>;

/// A Future that resolves to either a [Failure] or void.
typedef VoidFuture = ResultFuture<void>;

/// Shorthand for untyped JSON maps.
typedef DataMap = Map<String, dynamic>;
