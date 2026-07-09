import 'package:flutter/material.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import '../functions/messege.dart';

class MessageOverlay extends StatefulWidget {
  final Widget child;

  const MessageOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<MessageOverlay> createState() => _MessageOverlayState();
}

class _MessageOverlayState extends State<MessageOverlay> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: widget.child,
    );
  }
}


class GlobalMessage {
  static BuildContext? _context;

  static void initialize(BuildContext context) {
    _context = context;
  }

  static AppLocalizations get l10n => AppLocalizations.of(_context!);

  static void showSuccess(String message) {
    if (_context != null) {
      MotionSnackBarSuccess(_context!, message);
    }
  }

  static void showError(String message) {
    if (_context != null) {
      MotionSnackBarError(_context!, message);
    }
  }

  static void showWarning(String message) {
    if (_context != null) {
      MotionSnackBarWarning(_context!, message);
    }
  }

  static void showInfo(String message) {
    if (_context != null) {
      MotionSnackBarInfo(_context!, message);
    }
  }

  static void showLoading(String message) {
    if (_context != null) {
      MotionSnackBarInfo(_context!, message);
    }
  }

  // Predefined message helpers
  static void productAdded() => showSuccess(l10n.msgProductAdded);
  static void productUpdated() => showSuccess(l10n.msgProductUpdated);
  static void productDeleted() => showSuccess(l10n.msgProductDeleted);
  static void saleCompleted() => showSuccess(l10n.msgSaleCompleted);
  static void dataSaved() => showSuccess(l10n.msgDataSaved);
  static void reportGenerated() => showSuccess(l10n.msgReportGenerated);
  static void userCreated() => showSuccess(l10n.msgUserCreated);
  static void userUpdated() => showSuccess(l10n.msgUserUpdated);
  static void userDeleted() => showSuccess(l10n.msgUserDeleted);
  static void loginSuccess() => showSuccess(l10n.msgLoginSuccess);
  static void logoutSuccess() => showSuccess(l10n.msgLogoutSuccess);
  static void passwordChanged() => showSuccess(l10n.msgPasswordChanged);
  static void settingsSaved() => showSuccess(l10n.msgSettingsSaved);

  static void productNotFound() => showError(l10n.errProductNotFound);
  static void insufficientStock() => showError(l10n.errInsufficientStock);
  static void invalidInput() => showError(l10n.errInvalidInput);
  static void networkError() => showError(l10n.errNetworkError);
  static void serverError() => showError(l10n.errServerError);
  static void loginFailed() => showError(l10n.errLoginFailed);
  static void accessDenied() => showError(l10n.errAccessDenied);
  static void fileNotFound() => showError(l10n.errFileNotFound);
  static void saveFailed() => showError(l10n.errSaveFailed);
  static void deleteFailed() => showError(l10n.errDeleteFailed);
  static void updateFailed() => showError(l10n.errUpdateFailed);
  static void connectionTimeout() => showError(l10n.msgConnectionTimeout);
  static void invalidCredentials() => showError(l10n.msgInvalidCredentials);

  static void lowStock() => showWarning(l10n.warnLowStock);
  static void unsavedChanges() => showWarning(l10n.warnUnsavedChanges);
  static void confirmDelete() => showWarning(l10n.warnConfirmDelete);
  static void sessionExpired() => showWarning(l10n.warnSessionExpired);
  static void dataLoss() => showWarning(l10n.warnDataLoss);
  static void backupRequired() => showWarning(l10n.warnBackupRequired);
  static void systemMaintenance() => showWarning(l10n.warnSystemMaintenance);

  static void loadingData() => showInfo(l10n.infoLoadingData);
  static void processingRequest() => showInfo(l10n.infoProcessingRequest);
  static void generatingReport() => showInfo(l10n.infoGeneratingReport);
  static void savingData() => showInfo(l10n.infoSavingData);
  static void updatingData() => showInfo(l10n.infoUpdatingData);
  static void deletingData() => showInfo(l10n.infoDeletingData);
  static void exportingData() => showInfo(l10n.infoExportingData);
  static void importingData() => showInfo(l10n.infoImportingData);
  static void synchronizingData() => showInfo(l10n.infoSynchronizingData);
  static void systemReady() => showInfo(l10n.infoSystemReady);
  static void newUpdateAvailable() => showInfo(l10n.infoNewUpdateAvailable);
  static void maintenanceScheduled() => showInfo(l10n.infoMaintenanceScheduled);
}
