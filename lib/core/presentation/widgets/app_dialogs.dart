import 'package:flutter/material.dart';
import '../../../config/typography/app_text_styles.dart';

class AppDialogs {
  AppDialogs._();

  static Future<bool?> showDeleteConfirmation(
    BuildContext context, {
    required String title,
    required String content,
    String cancelLabel = 'Batal',
    String confirmLabel = 'Hapus',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: AppTextStyles.headlineSmall),
        content: Text(
          content,
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              cancelLabel,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              confirmLabel,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
