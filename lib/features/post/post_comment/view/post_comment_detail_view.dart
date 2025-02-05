import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/features/post/post_comment/model/like_post_comment_response.dart';
import 'package:socieaty/features/post/post_comment/model/post_comment.dart';
import 'package:socieaty/features/post/post_comment/viewmodel/post_comment_detail_view_model.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/custom_circle_avatar_widget.dart';

class PostCommentDetailView extends ConsumerStatefulWidget {
  final PostComment postComment;
  final String postId;
  final String userId;
  const PostCommentDetailView({super.key, required this.postComment, required this.postId, required this.userId});

  @override
  ConsumerState<PostCommentDetailView> createState() => _PostCommentDetailViewState();
}

class _PostCommentDetailViewState extends ConsumerState<PostCommentDetailView> {
  bool isLiked = false;
  int likeCount = 0;
  Timer? _debounce;
  final Duration _debounceDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    isLiked = widget.postComment.likes.any((user) => user.id == widget.userId); // Replace with actual user ID
    likeCount = widget.postComment.likes.length;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  _onLiked() {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }
    _debounce = Timer(_debounceDuration, () {
      debugPrint("isLiked: $isLiked");
      ref.read(postCommentDetailViewModelProvider(postId: widget.postId, commentId: widget.postComment.id).notifier).likePostComment(isLiked);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(postCommentDetailViewModelProvider(postId: widget.postId, commentId: widget.postComment.id), (_, next) {
      switch (next.likePostCommentState) {
        case SuccessState<LikePostCommentResponse>(data: final data):
          setState(() {
            isLiked = data.isLiked;
            likeCount = data.likes;
          });
        case ErrorState(message: final message):
          debugPrint("Error : $message");
        case LoadingState():
        case IdleState():
      }
    });

    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCircleAvatarWidget(radius: 20, imageUrl: 'assets/images/person_dummy.jpg'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    widget.postComment.userName,
                    // widget.postComment.userName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 2),
                  Text(
                    widget.postComment.text,
                    // widget.postComment.text,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isLiked = !isLiked;
              });
              _onLiked();
            },
            child: Column(
              children: [
                isLiked
                    ? Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                      )
                    : Icon(Icons.favorite_outline),
                SizedBox(
                  height: 4,
                ),
                Text(
                  likeCount.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
