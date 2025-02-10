import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String title;
  final String contentType;
  final VoidCallback onDelete;

  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.contentType,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppPallete.errorColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.warning_rounded,
          color: AppPallete.errorColor,
          size: 32,
        ),
      ),
      title: Text(
        'Delete $contentType',
        style: TextStyle(
          color: AppPallete.errorColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to delete "$title"?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'This action cannot be undone and will permanently remove this $contentType.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppPallete.neutralColor.shade600,
                ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      actionsPadding: const EdgeInsets.all(16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
          ),
        ),
        FilledButton(
          onPressed: onDelete,
          style: Theme.of(context)
              .filledButtonTheme
              .style
              ?.copyWith(backgroundColor: WidgetStateProperty.all(AppPallete.errorColor)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.delete_outline,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                'Delete',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
