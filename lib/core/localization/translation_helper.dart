import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class TranslationHelper {
  static String translate(BuildContext context, String key, {List<String>? args}) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return key;

    switch (key) {
      // Success Messages
      case 'msgUserDeleted':
        return l10n.msgUserDeleted;
      case 'msgUserCreated':
        return l10n.msgUserCreated;
      case 'msgUserUpdated':
        return l10n.msgUserUpdated;
      case 'msgLoginSuccess':
        return l10n.msgLoginSuccess;
      case 'msgLogoutSuccess':
        return l10n.msgLogoutSuccess;
      case 'msgPasswordChanged':
        return l10n.msgPasswordChanged;
      case 'msgSettingsSaved':
        return l10n.msgSettingsSaved;
      case 'msgProductAdded':
        return l10n.msgProductAdded;
      case 'msgProductUpdated':
        return l10n.msgProductUpdated;
      case 'msgProductDeleted':
        return l10n.msgProductDeleted;
      case 'msgSaleCompleted':
        return l10n.msgSaleCompleted;
      case 'msgDataSaved':
        return l10n.msgDataSaved;
      case 'msgReportGenerated':
        return l10n.msgReportGenerated;

      // Errors
      case 'errProductNotFound':
        return l10n.errProductNotFound;
      case 'errInsufficientStock':
        return l10n.errInsufficientStock;
      case 'errInvalidInput':
        return l10n.errInvalidInput;
      case 'errNetworkError':
        return l10n.errNetworkError;
      case 'errServerError':
        return l10n.errServerError;
      case 'errLoginFailed':
        return l10n.errLoginFailed;
      case 'errAccessDenied':
        return l10n.errAccessDenied;
      case 'errFileNotFound':
        return l10n.errFileNotFound;
      case 'errSaveFailed':
        return l10n.errSaveFailed;
      case 'errDeleteFailed':
        return l10n.errDeleteFailed;
      case 'errUpdateFailed':
        return l10n.errUpdateFailed;

      // Other custom/features specific
      case 'productNotFoundCubit':
        return l10n.productNotFoundCubit;
      case 'productUnavailable':
        return l10n.productUnavailable;
      case 'cartIsEmpty':
        return l10n.cartIsEmpty;
      case 'priceBelowMin':
        return args != null && args.isNotEmpty ? l10n.priceBelowMin(args[0]) : l10n.priceBelowMin('0');
      case 'failedOpenSession':
        return args != null && args.isNotEmpty ? l10n.failedOpenSession(args[0]) : l10n.failedOpenSession('');
      case 'saleSuccess':
        return l10n.saleSuccess;
      case 'dbError':
        return l10n.dbError;
      case 'fileSystemError':
        return l10n.fileSystemError;
      case 'unexpectedErrorGeneric':
        return l10n.unexpectedErrorGeneric;
      case 'cantAddMoreStock':
        return args != null && args.isNotEmpty ? l10n.cantAddMoreStock(args[0]) : l10n.cantAddMoreStock('0');
      case 'outOfStock':
        return l10n.outOfStock;
      case 'maxQtyReached':
        return args != null && args.isNotEmpty ? l10n.maxQtyReached(args[0]) : l10n.maxQtyReached('0');
      case 'cartEmpty':
        return l10n.cartEmpty;
      
      // Session/Shift specific
      case 'sessionOpenWarning':
        return l10n.sessionOpenWarning;
      case 'sessionCloseSuccess':
        return l10n.sessionDeletedSuccess; // or custom
      
      default:
        // Try parsing prefix-based dynamic errors (e.g. Price below minimum check, or generic error message)
        if (key.startsWith('priceBelowMin:')) {
          final val = key.substring('priceBelowMin:'.length);
          return l10n.priceBelowMin(val);
        }
        if (key.startsWith('failedOpenSession:')) {
          final val = key.substring('failedOpenSession:'.length);
          return l10n.failedOpenSession(val);
        }
        if (key.startsWith('cantAddMoreStock:')) {
          final val = key.substring('cantAddMoreStock:'.length);
          return l10n.cantAddMoreStock(val);
        }
        if (key.startsWith('maxQtyReached:')) {
          final val = key.substring('maxQtyReached:'.length);
          return l10n.maxQtyReached(val);
        }
        
        return key;
    }
  }
}
