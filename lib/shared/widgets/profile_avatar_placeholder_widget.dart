import 'package:flutter/material.dart';

class ProfileAvatarPlaceholderWidget extends StatelessWidget {
  final String name;
  const ProfileAvatarPlaceholderWidget({super.key, required this.name});

  Color _getColorFromName() {
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];

    // Get the ASCII value of the first letter and use it to pick a color
    final int index = name.toUpperCase().codeUnitAt(0) % colors.length;
    return colors[index];
  }

  Color _getTextColor(Color backgroundColor) {
    // Calculate the relative luminance of the background color
    // If it's dark, return white. If it's light, return black.
    return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getColorFromName();

    return CircleAvatar(
      radius: 40,
      backgroundColor: backgroundColor,
      child: Text(
        name.substring(0, 1).toUpperCase(),
        style: TextStyle(
          fontSize: 32,
          color: _getTextColor(backgroundColor),
        ),
      ),
    );
  }
}
