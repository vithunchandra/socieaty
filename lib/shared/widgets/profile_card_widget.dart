import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/authentication/provider/session_provider.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';
import 'package:socieaty/shared/widgets/custom_circle_avatar_widget.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class ProfileCardWidget extends ConsumerStatefulWidget {
  const ProfileCardWidget({super.key});

  @override
  ConsumerState<ProfileCardWidget> createState() => _ProfileCardState();
}

class _ProfileCardState extends ConsumerState<ProfileCardWidget> {
  @override
  Widget build(BuildContext context) {
    return ref.watch(getSessionDataProvider).when(
      data: (user) {
        switch (user) {
          case Success<SocieatyUser>(data: final user):
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomCircleAvatarWidget(radius: 22.5, imageUrl: "assets/images/person_dummy.jpg"),
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
          case Error(message: final message):
            return Text(message);
        }
      },
      error: (error, stack) {
        return Text(error.toString());
      },
      loading: () {
        return LoadingIndicatorWidget();
      },
    );
  }
}
