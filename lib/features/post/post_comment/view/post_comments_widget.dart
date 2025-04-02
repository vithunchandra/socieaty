import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/post/post_comment/view/post_comment_item_widget.dart';
import 'package:socieaty/features/post/post_comment/viewmodel/post_comments_view_model.dart';
import 'package:socieaty/features/post/post_comment/viewstate/post_comments_form_state.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'package:socieaty/shared/widgets/profile_picture_widget.dart';

class PostCommentsWidget extends ConsumerStatefulWidget {
  final String postId;
  const PostCommentsWidget({super.key, required this.postId});

  @override
  ConsumerState<PostCommentsWidget> createState() => _PostCommentsWidgetState();
}

class _PostCommentsWidgetState extends ConsumerState<PostCommentsWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    PostCommentsFormState postCommentsFormState = PostCommentsFormState(text: "");
    final user = ref.watch(authLocalRepositoryProvider).getUserData();

    var postComments = ref.watch(postCommentsProvider(widget.postId));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: SizedBox(
                    child: Column(
                      children: [
                        Divider(
                          indent: screenWidth * 0.4,
                          endIndent: screenWidth * 0.4,
                          thickness: 2,
                        ),
                        postComments.when(
                          data: (data) {
                            return Text(
                              "${data.length} Komentar",
                              style: Theme.of(context).textTheme.titleSmall,
                            );
                          },
                          error: (object, stacktrace) {
                            return const Text("Komentar");
                          },
                          loading: () {
                            return const Text("Komentar");
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: postComments.when(
                data: (data) {
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      var comment = data[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        child: PostCommentItemWidget(
                            postComment: comment,
                            postId: widget.postId,
                            userId: ref.read(authLocalRepositoryProvider).getUserData()!.id),
                      );
                    },
                  );
                },
                error: (object, stacktrace) {
                  return Text("${object.toString()} \n ${stacktrace.toString()}");
                },
                loading: () {
                  return const LoadingIndicatorWidget(size: 24);
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Form(
                key: _formKey,
                child: Row(
                  children: [
                    ProfilePictureWidget(
                      radius: 20,
                      user: user!,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Komentar tidak boleh kosong";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            postCommentsFormState = postCommentsFormState.copyWith(text: value);
                          },
                          decoration: InputDecoration.collapsed(
                            hintText: "Tulis komentar kamu disini...",
                            hintStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppPallete.neutralColor.shade400),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                          _formKey.currentState?.save();
                          ref
                              .read(postCommentsViewModelProvider.notifier)
                              .createPostComment(postCommentsFormState, widget.postId)
                              .then((_) {
                            ref.invalidate(postCommentsProvider);
                          });
                          _formKey.currentState?.reset();
                        }
                      },
                      icon: Icon(Icons.arrow_upward),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
