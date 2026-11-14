import 'package:dartz/dartz.dart';
import 'package:rwin_core/src/error/failure.dart';

/// Mixin for Cubits that need to run multiple use cases concurrently.
///
/// Usage:
/// ```dart
/// class MyFormCubit extends Cubit<MyState> with CubitHelper {
///   Future<void> loadData() async {
///     final results = await fetchParallel([
///       () => _getUserUseCase(),
///       () => _getCompaniesUseCase(),
///     ]);
///
///     final failure = findFirstFailure(results);
///     if (failure != null) { emit(error); return; }
///
///     final user      = getResult<UserEntity>(results, 0);
///     final companies = getResult<List<Company>>(results, 1);
///   }
/// }
/// ```
mixin CubitHelper {
  /// Runs [useCases] concurrently via [Future.wait].
  Future<List<Either<Failure, dynamic>>> fetchParallel(
    List<Future<Either<Failure, dynamic>> Function()> useCases,
  ) =>
      Future.wait(useCases.map((fn) => fn()));

  /// Returns the first [Failure] found in [results], or `null` if all succeeded.
  Failure? findFirstFailure(List<Either<Failure, dynamic>> results) {
    for (final result in results) {
      final failure = result.fold<Failure?>((l) => l, (_) => null);
      if (failure != null) return failure;
    }
    return null;
  }

  /// Extracts the success value at [index] from [results].
  /// Returns `null` if the result at that index is a failure.
  T? getResult<T>(List<Either<Failure, dynamic>> results, int index) =>
      results[index].fold((_) => null, (r) => r as T?);
}
