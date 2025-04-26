import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/admin/viewmodel/user_configuration_card_view_model.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class UserCardWidget extends ConsumerWidget {
  final SocieatyUser user;
  final void Function(SocieatyUser) onDeleteSuccess;

  const UserCardWidget({
    super.key,
    required this.user,
    required this.onDeleteSuccess,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelState = ref.watch(userConfigurationCardViewModelProvider(user.id));
    final isDeleting = viewModelState.userData is LoadingState;

    ref.listen(userConfigurationCardViewModelProvider(user.id), (previous, next) {
      switch (next.userData) {
        case SuccessState(data: final deletedUser):
          debugPrint('deletedUser: $deletedUser');
          onDeleteSuccess(deletedUser);
        case ErrorState(message: final message):
          showSnackbar(context, message);
        default:
          break;
      }
    });

    return InkWell(
      onTap: () {
        debugPrint("user: $user");
        context.push('/${user.id}');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppPallete.neutralColor.withAlpha(100),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppPallete.neutralColor.shade100,
                    backgroundImage: user.profilePictureUrl != null
                        ? NetworkImage(user.profilePictureUrl!) as ImageProvider
                        : const AssetImage('assets/images/default_avatar.png'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (user.isDeleted)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withAlpha(30),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Deleted',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: AppPallete.neutralColor.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getRoleColor(user.role).withAlpha(30),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                user.role.name[0].toUpperCase() + user.role.name.substring(1),
                                style: TextStyle(
                                  color: _getRoleColor(user.role),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              color: AppPallete.primaryColor,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton.icon(
                    onPressed: isDeleting
                        ? null
                        : () {
                            FocusScope.of(context).focusedChild?.unfocus();
                            _showActionConfirmation(
                                context, user, user.isDeleted ? _undeleteUser : _deleteUser, ref);
                          },
                    style: Theme.of(context).filledButtonTheme.style?.copyWith(
                          backgroundColor:
                              WidgetStateProperty.all(user.isDeleted ? Colors.blue : Colors.red),
                          foregroundColor: WidgetStateProperty.all(Colors.white),
                        ),
                    icon: isDeleting
                        ? LoadingIndicatorWidget(size: 16)
                        : Icon(
                            user.isDeleted ? Icons.restore : Icons.delete_outline,
                            size: 16,
                          ),
                    label: Text(user.isDeleted ? 'Restore' : 'Delete'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionConfirmation(
      BuildContext context, SocieatyUser user, Function(WidgetRef) action, WidgetRef ref) {
    final isDeleted = user.isDeleted;

    final actionText = isDeleted ? 'Restore' : 'Delete';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$actionText User'),
        content: Text(isDeleted
            ? 'Are you sure you want to restore ${user.name}?.'
            : 'Are you sure you want to delete ${user.name}?.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppPallete.neutralColor.shade600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              context.pop();
              action(ref);
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(isDeleted ? Colors.blue : Colors.red),
              foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  void _deleteUser(WidgetRef ref) {
    ref.read(userConfigurationCardViewModelProvider(user.id).notifier).deleteUser();
  }

  void _undeleteUser(WidgetRef ref) {
    ref.read(userConfigurationCardViewModelProvider(user.id).notifier).undeleteUser();
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.purple;
      case UserRole.restaurant:
        return Colors.blue;
      case UserRole.customer:
        return Colors.green;
    }
  }
}
