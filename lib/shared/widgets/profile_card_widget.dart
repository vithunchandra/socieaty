import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/features/authentication/provider/session_provider.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'package:socieaty/shared/widgets/profile_picture_widget.dart';

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
        return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ProfilePictureWidget(radius: 22.5, user: user),
                const SizedBox(width: 12),
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
        return const LoadingIndicatorWidget(size: 36);
      },
    );
  }
}
