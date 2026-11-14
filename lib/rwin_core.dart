/// rwin_core — Clean Architecture foundation for Flutter apps.
///
/// Import this single file to access all public APIs:
/// ```dart
/// import 'package:rwin_core/rwin_core.dart';
/// ```
library;

// ─── Error ────────────────────────────────────────────────────────────────────
export 'src/error/exceptions.dart';
export 'src/error/failure.dart';

// ─── Domain ───────────────────────────────────────────────────────────────────
export 'src/domain/typedef.dart';
export 'src/domain/usecase/usecase.dart';

// ─── Network ──────────────────────────────────────────────────────────────────
export 'src/network/remote_handler.dart';
export 'src/network/remote_handler_config.dart';

// ─── Theme ────────────────────────────────────────────────────────────────────
export 'src/theme/app_colors.dart';
export 'src/theme/app_typography.dart';
export 'src/theme/app_theme.dart';

// ─── Extensions ───────────────────────────────────────────────────────────────
export 'src/utils/extensions/string_ex.dart';
export 'src/utils/extensions/datetime_ex.dart';
export 'src/utils/extensions/context_ex.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────
export 'src/utils/helpers/cubit_helper.dart';
export 'src/utils/helpers/storage_handler.dart';
export 'src/utils/helpers/enums/form_status_enum.dart';
