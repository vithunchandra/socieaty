import 'package:flutter/material.dart';

Widget imageErrorWidget(BuildContext context, Object error, StackTrace? stackTrace) {
  return Container(
    color: Colors.grey[200],
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.grey[400], size: 24),
          SizedBox(height: 4),
          Text(
            'Image not found',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}