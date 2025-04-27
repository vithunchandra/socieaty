import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:socieaty/app_theme_provider.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/theme/theme.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/admin/viewmodel/livestream_configuration_card_view_model.dart';
import 'package:socieaty/features/livestream/model/live_room.dart';
import 'package:socieaty/shared/view_state.dart';

class LivestreamCardWidget extends ConsumerWidget {
  final LiveRoom liveRoom;
  final Function(LiveRoom) onDeleteSuccess;

  const LivestreamCardWidget({
    super.key,
    required this.liveRoom,
    required this.onDeleteSuccess,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(livestreamConfigurationCardViewModelProvider(liveRoom.roomName), (_, next) {
      switch (next.isDeletedState) {
        case SuccessState<bool>():
          onDeleteSuccess(liveRoom);
          showSnackbar(context, 'Livestream "${liveRoom.metadata.roomTitle}" has been deleted.');
        case ErrorState(message: final message):
          showSnackbar(context, message);
        default:
          break;
      }
    });

    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () async {
        ref.read(appThemeProvider.notifier).setTheme(SocieatyAppTheme.darkTheme);
        await context.push("/admin/configure-content/livestream/detail", extra: liveRoom);
        ref.read(appThemeProvider.notifier).setTheme(SocieatyAppTheme.lightTheme);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppPallete.neutralColor.shade200.withAlpha(120),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, textTheme),
            _buildBody(context, textTheme),
            _buildFooter(context, ref, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: liveRoom.owner.profilePictureUrl != null
                ? NetworkImage(liveRoom.owner.profilePictureUrl!)
                : null,
            child: liveRoom.owner.profilePictureUrl == null
                ? Text(
                    liveRoom.owner.name[0].toUpperCase(),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  liveRoom.owner.name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Role: ${liveRoom.owner.role.name[0].toUpperCase()}${liveRoom.owner.role.name.substring(1)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppPallete.neutralColor.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            DateFormat('MMM d, yyyy').format(liveRoom.createdAt),
            style: textTheme.bodySmall?.copyWith(
              color: AppPallete.neutralColor.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            liveRoom.metadata.roomTitle,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            'Room ID: ${liveRoom.roomName}',
            style: textTheme.bodyMedium?.copyWith(
              color: AppPallete.neutralColor.shade700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref, TextTheme textTheme) {
    final isDeleteLoading = ref.watch(
      livestreamConfigurationCardViewModelProvider(liveRoom.roomName)
          .select((value) => value.isDeletedState is LoadingState),
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppPallete.neutralColor.shade100,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildStat(Icons.remove_red_eye_outlined, liveRoom.views.toString(), textTheme),
          const SizedBox(width: 16),
          _buildStat(Icons.favorite_border, liveRoom.likesCount.toString(), textTheme),
          const SizedBox(width: 16),
          _buildStat(Icons.comment_outlined, liveRoom.commentsCount.toString(), textTheme),
          const Spacer(),
          IconButton(
            onPressed: () {
              _showDeleteConfirmationDialog(context, ref);
            },
            icon: isDeleteLoading
                ? const CircularProgressIndicator()
                : const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String count, TextTheme textTheme) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppPallete.neutralColor.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          count,
          style: textTheme.bodyMedium?.copyWith(
            color: AppPallete.neutralColor.shade700,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Livestream'),
        content: Text('Are you sure you want to delete "${liveRoom.metadata.roomTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppPallete.neutralColor.shade700),
            ),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(livestreamConfigurationCardViewModelProvider(liveRoom.roomName).notifier)
                  .deleteLivestreamRoom(liveRoom.roomName);
              context.pop();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppPallete.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
