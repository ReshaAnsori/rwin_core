import 'package:equatable/equatable.dart';

/// Severity hint for how the UI should surface this error.
enum MessageTreatment { error, warning, info, success }

/// Thrown by the network layer when the server returns a non-2xx response
/// or the request cannot be completed.
class APIException extends Equatable implements Exception {
  const APIException({
    required this.statusCode,
    required this.message,
    this.treatment = MessageTreatment.error,
  });

  final int statusCode;
  final String message;
  final MessageTreatment treatment;

  @override
  List<Object?> get props => [statusCode, message, treatment];

  @override
  String toString() => 'APIException($statusCode): $message';
}
