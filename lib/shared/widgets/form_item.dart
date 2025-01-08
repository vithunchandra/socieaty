import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class FormItem extends StatelessWidget {
  final IconData itemIcon;
  final String itemTitle;
  const FormItem({super.key, required this.itemIcon, required this.itemTitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      color: AppPallete.neutralColor.shade50,
      elevation: 1,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.fromBorderSide(
            BorderSide(width: 1, color: AppPallete.neutralColor.shade300),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(itemIcon, color: AppPallete.primaryColor),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                itemTitle,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Icon(Icons.chevron_right, color: AppPallete.primaryColor),
          ],
        ),
      ),
    );
  }
}
