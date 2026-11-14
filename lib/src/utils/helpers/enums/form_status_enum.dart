/// Lifecycle states for form Cubits.
enum FormStatus {
  /// Initial state before any data is loaded.
  initial,

  /// Fetching initial data (templates, dropdowns).
  loading,

  /// Data loaded, form is ready for input.
  ready,

  /// A cascading dropdown / secondary fetch is in progress.
  cascading,

  /// Form is submitting to the server.
  submitting,

  /// Submission completed successfully.
  submitted,

  /// An error occurred (load or submit).
  error,
}
