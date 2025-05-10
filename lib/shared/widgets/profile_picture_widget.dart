import 'package:flutter/material.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';

class ProfilePictureWidget extends StatelessWidget {
  final SocieatyUser user;
  final double radius;
  const ProfilePictureWidget({super.key, required this.user, required this.radius});

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

    final int index = user.name.toUpperCase().codeUnitAt(0) % colors.length;
    return colors[index];
  }

  Color _getTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getColorFromName();

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      foregroundImage:
          user.profilePictureUrl != null ? NetworkImage(user.profilePictureUrl!) : null,
      child: Text(
        user.name.substring(0, 1).toUpperCase(),
        style: TextStyle(
          fontSize: radius,
          color: _getTextColor(backgroundColor),
        ),
      ),
    );
  }
}
