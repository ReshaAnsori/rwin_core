import 'package:equatable/equatable.dart';
import 'package:rwin_core/src/error/exceptions.dart';

/// Base class for domain-layer failures.
/// Never throw this — return it as the Left side of an Either.
abstract class Failure extends Equatable {
  const Failure({
    required this.message,
    required this.statusCode,
    this.treatment = MessageTreatment.error,
  });

  final String message;
  final int statusCode;
  final MessageTreatment treatment;

  String get errorMessage => '$statusCode Error: $message';

  @override
  List<Object> get props => [message, statusCode, treatment];
}

/// Concrete failure produced by [APIException].
class APIFailure extends Failure {
  const APIFailure({
    required super.message,
    required super.statusCode,
    super.treatment = MessageTreatment.error,
  });

  factory APIFailure.fromException(APIException e) => APIFailure(
        statusCode: e.statusCode,
        message: e.message,
        treatment: e.treatment,
      );
}
