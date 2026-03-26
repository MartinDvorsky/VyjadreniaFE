// filepath: lib/utils/permission_helper.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/permission_denied_dialog.dart';

/// Zjednodušený helper pre prácu s oprávneniami
class PermissionHelper {
  static final _firebaseAuth = FirebaseAuth.instance;

  /// Kontrola či je user prihlásený (základná ochrana)
  static bool isUserLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  /// Zobraz permission denied dialog s detailmi
  static Future<void> showPermissionDenied(
      BuildContext context, {
        required String action,
        String? details,
      }) async {
    // Extrahuj zmysluplnú chybovú správu
    String message = 'Nemáte oprávnenie na vykonanie tejto akcie.';

    if (details != null) {
      if (details.contains('admin') || details.contains('superuser')) {
        message = 'Táto akcia vyžaduje administrátorské oprávnenia.';
      } else if (details.contains('401') || details.contains('unauthorized')) {
        message = 'Vaša relácia vypršala. Prihláste sa prosím znova.';
      } else if (details.contains('403') || details.contains('forbidden')) {
        message = 'Nemáte dostatočné oprávnenia na túto akciu.';
      }
    }

    await PermissionDeniedDialog.show(
      context,
      title: 'Nedostatočné oprávnenia',
      message: message,
      actionName: action,
    );
  }

  /// Spracuj exception z API volania
  static Future<bool> handleApiException(
      BuildContext context,
      dynamic error, {
        required String action,
        VoidCallback? onAuthError,
      }) async {
    final errorMsg = error.toString().toLowerCase();

    // Je to permission error?
    final isPermissionError = errorMsg.contains('401') ||
        errorMsg.contains('403') ||
        errorMsg.contains('unauthorized') ||
        errorMsg.contains('forbidden') ||
        errorMsg.contains('neoprávnen') ||
        errorMsg.contains('nedostatočn');

    if (isPermissionError) {
      await showPermissionDenied(
        context,
        action: action,
        details: error.toString(),
      );

      // Ak je to 401 (unauthorized), user by sa mal znova prihlásiť
      if (errorMsg.contains('401') && onAuthError != null) {
        onAuthError();
      }

      return true; // Spracovali sme error
    }

    return false; // Nie je to permission error
  }

  /// 🆕 Zobraz permission error iba ak je to skutočne permission error
  static Future<void> showPermissionErrorIfNeeded(
      BuildContext context,
      dynamic error, {
        required String actionName,
      }) async {
    final errorMsg = error.toString().toLowerCase();

    // Detekuj permission error
    final isPermissionError = errorMsg.contains('401') ||
        errorMsg.contains('403') ||
        errorMsg.contains('unauthorized') ||
        errorMsg.contains('forbidden') ||
        errorMsg.contains('neoprávnen') ||
        errorMsg.contains('nedostatočn');

    if (isPermissionError) {
      await showPermissionDenied(
        context,
        action: actionName,
        details: error.toString(),
      );
    }
  }
}

/// Extension na BuildContext pre jednoduchší prístup
extension PermissionContextExtension on BuildContext {
  /// Zobraz permission denied dialog
  Future<void> showPermissionDenied({
    required String action,
    String? details,
  }) async {
    await PermissionHelper.showPermissionDenied(
      this,
      action: action,
      details: details,
    );
  }

  /// Spracuj API exception a zobraz dialog ak je to permission error
  Future<bool> handleApiException(
      dynamic error, {
        required String action,
        VoidCallback? onAuthError,
      }) async {
    return PermissionHelper.handleApiException(
      this,
      error,
      action: action,
      onAuthError: onAuthError,
    );
  }

  /// 🆕 Zobraz permission error iba ak je potrebné
  Future<void> showPermissionErrorIfNeeded(
      dynamic error, {
        required String actionName,
      }) async {
    await PermissionHelper.showPermissionErrorIfNeeded(
      this,
      error,
      actionName: actionName,
    );
  }
}
