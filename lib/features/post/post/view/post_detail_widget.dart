import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/core/utils/location_handler.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/post/post/model/like_post_response.dart';
import 'package:socieaty/features/post/post/model/post.dart';
import 'package:socieaty/features/post/post/viewmodel/post_detail_view_model.dart';
import 'package:socieaty/features/post/post_comment/view/post_comments_widget.dart';
import 'package:socieaty/features/post/post_media/model/post_media.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/video_player_widget.dart';

class PostDetailWidget extends ConsumerStatefulWidget {
  final Post post;
  final String userId;
  const PostDetailWidget({super.key, required this.post, required this.userId});
  @override
  ConsumerState<PostDetailWidget> createState() => _PostDetailWidgetState();
}

class _PostDetailWidgetState extends ConsumerState<PostDetailWidget> {
  late PageController _pageController;
  String locationName = "";
  String hashtags = "";
  bool isLiked = false;
  int likes = 0;
  int comments = 0;
  List<PostMedia> postMedia = [];
  Timer? _debounce;
  final Duration _debounceDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.post.location != null) {
      getLocationName();
    }
    isLiked = widget.post.likes.any((like) => like.id == widget.userId);
    likes = widget.post.likes.length;
    hashtags = widget.post.hashtags.map((hashtag) => hashtag.tag).toList().toHashtags();
    postMedia = widget.post.medias;
  }

  @override
  void didUpdateWidget(covariant PostDetailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    ref.invalidate(postDetailViewModelProvider(postId: oldWidget.post.id));
    _pageController = PageController();
    if (widget.post.location != null) {
      getLocationName();
    }
    if (oldWidget.post.likes.any((like) => like.id == widget.userId) !=
        widget.post.likes.any((like) => like.id == widget.userId)) {
      isLiked = widget.post.likes.any((like) => like.id == widget.userId);
    }
    if (oldWidget.post.likes.length != widget.post.likes.length) {
      likes = widget.post.likes.length;
    }
    hashtags = widget.post.hashtags.map((hashtag) => hashtag.tag).toList().toHashtags();
    postMedia = widget.post.medias;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  _onLiked() {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }
    _debounce = Timer(_debounceDuration, () {
      ref.read(postDetailViewModelProvider(postId: widget.post.id).notifier).likePost(isLiked);
    });
  }

  void getLocationName() async {
    if (widget.post.location != null) {
      var location = await LocationHandler.getAddressFromLatLng(widget.post.location!);
      locationName = "${location?.street}, ${location?.locality}, ${location?.country}";
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int stateComments = ref.watch(postDetailViewModelProvider(postId: widget.post.id)).comments;
    comments = stateComments == -1 ? widget.post.comments : stateComments;

    ref.listen(postDetailViewModelProvider(postId: widget.post.id), (_, next) {
      switch (next.likeState) {
        case SuccessState<LikePostResponse>(data: final data):
          setState(() {
            isLiked = data.isLiked;
            likes = data.likes;
          });
        case ErrorState(message: final message):
          showSnackbar(context, message);
        case LoadingState():
        case IdleState():
      }
    });

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: PageView(
              controller: _pageController,
              children: [
                ...postMedia.map(
                  (media) => media.type == "image"
                      ? Align(
                          alignment: Alignment.center,
                          child: Image.network(
                            media.url,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return SizedBox(
                                width: screenWidth * 0.5,
                                height: screenWidth * 0.5,
                                child: Icon(Icons.image_not_supported_outlined),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: VideoPlayerWidget(
                            videoUrl: media.url,
                            postId: widget.post.id,
                          ),
                        ),
                ),
              ],
            ),
          ),
          // Bottom Content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Left Column
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.0),
                        Text(
                          widget.post.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 5,
                                color: AppPallete.neutralColor.shade300.withAlpha(128),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          widget.post.caption,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 4,
                                color: AppPallete.neutralColor.withAlpha(128),
                              ),
                            ],
                          ),
                        ),
                        hashtags.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(hashtags),
                              )
                            : SizedBox.shrink(),
                        locationName.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(locationName),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.1),
                  // Right Column
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Material(
                        color: AppPallete.neutralColor.shade50,
                        borderRadius: BorderRadius.circular(25),
                        elevation: 2.0,
                        child: CircleAvatar(
                          radius: 22.5,
                          backgroundImage: AssetImage('assets/images/person_dummy.jpg'),
                        ),
                      ),
                      SizedBox(height: 4),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isLiked = !isLiked;
                          });
                          _onLiked();
                        },
                        iconSize: 28,
                        icon: isLiked
                            ? Icon(
                                Icons.favorite,
                                color: Colors.red,
                              )
                            : Icon(Icons.favorite_outline),
                      ),
                      Text(likes.toString()),
                      SizedBox(height: 4.0),
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            enableDrag: true,
                            useRootNavigator: true,
                            isScrollControlled: true,
                            useSafeArea: true,
                            builder: (context) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).viewInsets.bottom),
                                child: PostCommentsWidget(postId: widget.post.id),
                              );
                            },
                          );
                        },
                        iconSize: 28,
                        icon: Icon(Icons.comment_outlined),
                      ),
                      Text(comments.toString()),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
