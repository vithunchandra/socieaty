import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/app_theme_provider.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/theme/theme.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/admin/viewmodel/post_configuration_card_view_model.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/post/post/model/post.dart';
import 'package:socieaty/features/post/post/view/post_detail_widget.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/image_error_widget.dart';
import 'package:socieaty/shared/widgets/image_loading_widget.dart';

class PostCardWidget extends ConsumerStatefulWidget {
  final Post post;
  final Function(Post) onDeleteSuccess;

  const PostCardWidget({
    super.key,
    required this.post,
    required this.onDeleteSuccess,
  });

  @override
  ConsumerState<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends ConsumerState<PostCardWidget> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(postConfigurationCardViewModelProvider(widget.post.id), (previous, next) {
      final deleteResponse = next.deleteResponse;

      switch (deleteResponse) {
        case LoadingState():
          setState(() {
            _isDeleting = true;
          });
        case SuccessState<String>():
          setState(() {
            _isDeleting = false;
          });
          showSnackbar(context, deleteResponse.data);
          widget.onDeleteSuccess(widget.post);
        case ErrorState():
          setState(() {
            _isDeleting = false;
          });
          showSnackbar(context, deleteResponse.message, state: SnackbarState.error);
        case IdleState():
        // Do nothing
      }
    });

    final userId = ref.watch(authLocalRepositoryProvider).getUserData()!.id;

    return InkWell(
      onTap: () async {
        ref.read(appThemeProvider.notifier).setTheme(SocieatyAppTheme.darkTheme);
        await context.push(
          "/admin/configure-content/detail",
          extra: PostDetailWidgetArgs(
            post: widget.post,
            userId: userId,
          ),
        );
        ref.read(appThemeProvider.notifier).setTheme(SocieatyAppTheme.lightTheme);
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostHeader(),
            if (widget.post.medias.isNotEmpty) _buildMediaPreview(),
            _buildPostDetails(),
            _buildActionButtons(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: AppPallete.primaryColor.withAlpha(30),
            child: Text(
              widget.post.authorName[0].toUpperCase(),
              style: TextStyle(
                color: AppPallete.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.authorName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppPallete.neutralColor.shade800,
                  ),
                ),
                Text(
                  'Author ID: ${widget.post.authorId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppPallete.neutralColor.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview() {
    final media = widget.post.medias.first;
    final imageUrl = media.type == "image" ? media.url : media.videoThumbnailUrl ?? "";

    if (imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 180,
      width: double.infinity,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            imageLoadingWidget(context, url, downloadProgress),
        errorWidget: (context, url, error) => imageErrorWidget(context, error, null),
      ),
    );
  }

  Widget _buildPostDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.post.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppPallete.neutralColor.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.post.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: AppPallete.neutralColor.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final hashtag in widget.post.hashtags)
                Chip(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    '#${hashtag.tag}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: AppPallete.primaryColor.withAlpha(20),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.favorite_outline,
                size: 16,
                color: AppPallete.neutralColor.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.post.likes.length} likes',
                style: TextStyle(
                  fontSize: 12,
                  color: AppPallete.neutralColor.shade600,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.chat_bubble_outline,
                size: 16,
                color: AppPallete.neutralColor.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.post.comments} comments',
                style: TextStyle(
                  fontSize: 12,
                  color: AppPallete.neutralColor.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: _isDeleting
                ? null
                : () {
                    _showDeleteDialog(context, ref);
                  },
            icon: _isDeleting
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppPallete.errorColor,
                    ),
                  )
                : Icon(
                    Icons.delete_outline,
                    color: AppPallete.errorColor,
                  ),
            label: const Text('Delete Post'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppPallete.errorColor,
              side: BorderSide(color: AppPallete.errorColor),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: Text('Are you sure you want to delete the post "${widget.post.title}"?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              ref
                  .read(postConfigurationCardViewModelProvider(widget.post.id).notifier)
                  .deletePost();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppPallete.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
