import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/app_theme_provider.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/theme/theme.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/core/utils/location_handler.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/authentication/provider/get_user_data_provider.dart';
import 'package:socieaty/features/post/post/repository/response/like_post_response.dart';
import 'package:socieaty/features/post/post/model/post.dart';
import 'package:socieaty/features/post/post/view/update_post_screen.dart';
import 'package:socieaty/features/post/post/viewmodel/post_detail_view_model.dart';
import 'package:socieaty/features/post/post_comment/view/post_comments_widget.dart';
import 'package:socieaty/features/post/post_media/model/post_media.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'package:socieaty/shared/widgets/profile_avatar_placeholder_widget.dart';
import 'package:socieaty/shared/widgets/profile_picture_widget.dart';
import 'package:socieaty/shared/widgets/video_player_widget.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class PostDetailWidgetArgs {
  final Post post;
  final String userId;
  final void Function(Post post)? onUpdate;
  final void Function(Post post)? onDelete;
  PostDetailWidgetArgs({required this.post, required this.userId, this.onUpdate, this.onDelete});
}

class PostDetailWidget extends ConsumerStatefulWidget {
  final PostDetailWidgetArgs args;
  const PostDetailWidget({super.key, required this.args});

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
    if (widget.args.post.location != null) {
      getLocationName();
    }
    isLiked = widget.args.post.likes.any((like) => like.id == widget.args.userId);
    likes = widget.args.post.likes.length;
    hashtags = widget.args.post.hashtags.map((hashtag) => hashtag.tag).toList().toHashtags();
    postMedia = widget.args.post.medias;
  }

  @override
  void didUpdateWidget(covariant PostDetailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ref.invalidate(postDetailViewModelProvider(postId: oldWidget.args.post.id));
    // _pageController = PageController();
    if (widget.args.post.location != null) {
      getLocationName();
    }
    if (oldWidget.args.post.likes.any((like) => like.id == widget.args.userId) !=
        widget.args.post.likes.any((like) => like.id == widget.args.userId)) {
      isLiked = widget.args.post.likes.any((like) => like.id == widget.args.userId);
    }
    if (oldWidget.args.post.likes.length != widget.args.post.likes.length) {
      likes = widget.args.post.likes.length;
    }
    hashtags = widget.args.post.hashtags.map((hashtag) => hashtag.tag).toList().toHashtags();
    postMedia = widget.args.post.medias;
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
      ref.read(postDetailViewModelProvider(postId: widget.args.post.id).notifier).likePost(isLiked);
    });
  }

  void getLocationName() async {
    if (widget.args.post.location != null) {
      var location = await LocationHandler.getAddressFromLatLng(widget.args.post.location!);
      locationName = "${location?.street}, ${location?.locality}, ${location?.country}";
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int stateComments =
        ref.watch(postDetailViewModelProvider(postId: widget.args.post.id)).comments;
    comments = stateComments == -1 ? widget.args.post.comments : stateComments;
    final author = ref.watch(getUserDataProvider(widget.args.post.authorId));

    final isDeleteStateLoading = ref
        .watch(postDetailViewModelProvider(postId: widget.args.post.id))
        .deleteState is LoadingState;

    ref.listen(postDetailViewModelProvider(postId: widget.args.post.id), (_, next) {
      switch (next.likeState) {
        case SuccessState<LikePostResponse>(data: final data):
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                isLiked = data.isLiked;
                likes = data.likes;
              });
            }
            if (widget.args.onUpdate != null) {
              widget.args.onUpdate!(data.updatedPost);
            }
          });
          break;
        case ErrorState(message: final message):
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showSnackbar(context, message);
          });
          break;
        case LoadingState():
        case IdleState():
          break;
      }

      switch (next.deleteState) {
        case SuccessState<String>(data: final data):
          if (widget.args.onDelete != null) {
            widget.args.onDelete!(widget.args.post);
          }
          showSnackbar(context, "Sukses menghapus postingan");
          break;
        case ErrorState(message: final message):
          showSnackbar(context, message);
        default:
          break;
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          PageView(
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
                          postId: widget.args.post.id,
                        ),
                      ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.0),
                        Text(
                          widget.args.post.title,
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
                          widget.args.post.caption,
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          ref.read(appThemeProvider.notifier).setTheme(SocieatyAppTheme.lightTheme);
                          await context.push('/${widget.args.post.authorId}');
                          ref.read(appThemeProvider.notifier).setTheme(SocieatyAppTheme.darkTheme);
                        },
                        child: author.when(
                          data: (data) => ProfilePictureWidget(
                            user: data,
                            radius: 20,
                          ),
                          error: (error, stackTrace) => ProfileAvatarPlaceholderWidget(
                            name: widget.args.post.authorName,
                          ),
                          loading: () => LoadingIndicatorWidget(size: 20),
                        ),
                      ),
                      SizedBox(height: 16),
                      if (isDeleteStateLoading)
                        LoadingIndicatorWidget(size: 20)
                      else if (widget.args.userId == widget.args.post.authorId)
                        DropdownButtonHideUnderline(
                          child: DropdownButton2(
                            customButton: Icon(
                              Icons.more_vert,
                              color: Colors.white,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined,
                                        color: AppPallete.neutralColor.shade800),
                                    const SizedBox(width: 10),
                                    Text('Edit',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(color: Colors.black)),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline,
                                        color: AppPallete.neutralColor.shade800),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Hapus',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              switch (value) {
                                case 'edit':
                                  ref
                                      .read(appThemeProvider.notifier)
                                      .setTheme(SocieatyAppTheme.lightTheme);
                                  context.push(
                                    '/posts/update',
                                    extra: UpdatePostScreenArgs(
                                      post: widget.args.post,
                                      lastTheme: SocieatyAppTheme.darkTheme,
                                      onUpdate: (updatedPost) {
                                        if (widget.args.onUpdate != null) {
                                          widget.args.onUpdate!(updatedPost);
                                        }
                                        postMedia = updatedPost.medias;
                                        if (context.mounted) {
                                          setState(() {});
                                        }
                                      },
                                    ),
                                  );
                                  break;
                                case 'delete':
                                  ref
                                      .read(postDetailViewModelProvider(postId: widget.args.post.id)
                                          .notifier)
                                      .deletePost();
                              }
                            },
                            dropdownStyleData: DropdownStyleData(
                              width: 160,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              elevation: 1,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                              ),
                              offset: const Offset(0, 8),
                            ),
                          ),
                        ),
                      SizedBox(height: 4),
                      IconButton(
                        onPressed: () {
                          if (mounted) {
                            setState(() {
                              isLiked = !isLiked;
                            });
                          }
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
                        onPressed: () async {
                          await showModalBottomSheet(
                            context: context,
                            enableDrag: true,
                            useRootNavigator: true,
                            isScrollControlled: true,
                            useSafeArea: true,
                            builder: (context) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).viewInsets.bottom),
                                child: PostCommentsWidget(postId: widget.args.post.id),
                              );
                            },
                          );

                          ref.invalidate(getPostProvider(widget.args.post.id));
                          final updatedPost =
                              await ref.watch(getPostProvider(widget.args.post.id).future);
                          if (widget.args.onUpdate != null) {
                            widget.args.onUpdate!(updatedPost);
                          }
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
