// What the export button needs from the platform: permission checks, the
// shop/user details, and the print, PDF and Excel paths. The real one is
// DefaultReportExportBackend (report_export_actions.dart); tests pass a
// fake so the button can be tested without printers or file dialogs.

import 'package:flutter/widgets.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';

/// A failure with a message fit to show the user as is.
class ReportExportException implements Exception {
  final String message;

  const ReportExportException(this.message);

  @override
  String toString() => 'ReportExportException: $message';
}

/// Result of a PDF or Excel save.
class ReportSaveResult {
  final String fileName;

  /// True where the file was saved without other feedback (desktop and
  /// web), so the button confirms it. False on mobile, where the share
  /// sheet already shows what happened.
  final bool showSaved;

  const ReportSaveResult({required this.fileName, required this.showSaved});
}

abstract class ReportExportBackend {
  /// Whether [gate] allows the action. Must not show any dialog.
  bool isAllowed(BuildContext context, ReportPrintGate gate);

  /// Shop and current user details, stamped with the current time.
  ExportContext exportContext();

  /// The paper width of the saved receipt printer setting, or null when
  /// none is saved. The menu marks that width " · your printer".
  RollPaper? savedPaper();

  /// Records a failure for debugging (the user sees a snackbar).
  void logError(String action, Object error, StackTrace stack);

  /// [beforeUi] closes the loading overlay. Call it right before showing
  /// any platform UI (device list, printer picker, print dialog, share
  /// sheet). Throws when the print fails; returns quietly when the user
  /// cancels.
  Future<void> printRoll(
    BuildContext context,
    ReportExportSpec spec,
    ExportContext ctx, {
    required RollPaper paper,
    required List<String?> groupings,
    required VoidCallback beforeUi,
  });

  Future<ReportSaveResult> downloadPdf(
    BuildContext context,
    ReportExportSpec spec,
    ExportContext ctx, {
    required VoidCallback beforeUi,
  });

  Future<ReportSaveResult> exportExcel(
    BuildContext context,
    ReportExportSpec spec,
    ExportContext ctx, {
    String? splitId,
    required VoidCallback beforeUi,
  });
}
