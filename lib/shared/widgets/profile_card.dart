import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/features/authentication/provider/session_provider.dart';
import 'package:socieaty/shared/widgets/custom_circle_avatar.dart';
import 'package:socieaty/shared/widgets/loading_indicator.dart';

class ProfileCard extends ConsumerStatefulWidget {
  const ProfileCard({super.key});

  @override
  ConsumerState<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends ConsumerState<ProfileCard> {
  @override
  Widget build(BuildContext context) {
    return ref.watch(getSessionDataProvider).when(
      data: (user) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CustomCircleAvatar(radius: 22.5, imageUrl: "assets/images/person_dummy.jpg"),
            SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.labelMedium,
                )
              ],
            )
          ],
        );
      },
      error: (error, stack) {
        return Text(error.toString());
      },
      loading: () {
        return LoadingIndicator();
      },
    );
  }
}
