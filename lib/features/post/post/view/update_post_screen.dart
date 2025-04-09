import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/app_theme_provider.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/theme/theme.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/core/utils/show_picker_modal.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/home/customer/provider/all_post_provider.dart';
import 'package:socieaty/features/map/model/my_location_data.dart';
import 'package:socieaty/features/post/post/model/post.dart';
import 'package:socieaty/features/post/post/repository/request/update_post_request.dart';
import 'package:socieaty/features/post/post/viewmodel/update_post_view_model.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/custom_text_field.dart';
import 'package:socieaty/shared/widgets/form_item_widget.dart';
import 'package:socieaty/shared/widgets/image_card_widget.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'package:socieaty/shared/widgets/network_image_card_widget.dart';
import 'package:socieaty/shared/widgets/profile_card_widget.dart';
import 'package:socieaty/shared/widgets/video_thumbail_widget.dart';

class UpdatePostScreenArgs {
  final Post post;
  final ThemeData lastTheme;
  UpdatePostScreenArgs({required this.post, required this.lastTheme});
}

class UpdatePostScreen extends ConsumerStatefulWidget {
  final UpdatePostScreenArgs args;
  const UpdatePostScreen({super.key, required this.args});

  @override
  ConsumerState<UpdatePostScreen> createState() => _UpdatePostScreenState();
}

class _UpdatePostScreenState extends ConsumerState<UpdatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<File> files = List.empty(growable: true);
  final List<String> deleteMediaIds = List.empty(growable: true);
  String hashtagsText = "";
  String locationAddress = "";
  UpdatePostRequest formData = UpdatePostRequest();

  @override
  void initState() {
    super.initState();
    debugPrint(widget.args.post.medias.toString());
    hashtagsText = widget.args.post.hashtags.map((hashtag) => hashtag.tag).toList().toHashtags();
    formData = UpdatePostRequest(
      title: widget.args.post.title,
      caption: widget.args.post.caption,
      hashtags: widget.args.post.hashtags.map((hashtag) => hashtag.tag).toList(),
      location: widget.args.post.location,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(updatePostViewModelProvider(widget.args.post.id)).updatedPostState
        is LoadingState;

    ref.listen(updatePostViewModelProvider(widget.args.post.id), (_, next) {
      switch (next.updatedPostState) {
        case SuccessState<Post>():
          ref.invalidate(allPostProvider);
          context.pop();
        case ErrorState(message: final message):
          showSnackbar(context, message, state: SnackbarState.error);
        case LoadingState():
        case IdleState():
      }
    });

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool result, dynamic args) {
        ref.read(appThemeProvider.notifier).setTheme(widget.args.lastTheme);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(Icons.chevron_left),
            iconSize: 30,
          ),
          backgroundColor: AppPallete.neutralColor.shade50,
          title: Text("Edit Post"),
          titleTextStyle: Theme.of(context).textTheme.titleMedium,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileCardWidget(),
                        SizedBox(height: 20),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.args.post.medias.length + files.length + 1,
                            itemBuilder: (context, index) {
                              if (index == widget.args.post.medias.length + files.length) {
                                return GestureDetector(
                                  onTap: () {
                                    showContentPickerModal(context, (image) {
                                      setState(() {
                                        files.add(image);
                                      });
                                    });
                                  },
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey[200],
                                      ),
                                      child: Center(
                                        child: Icon(Icons.add,
                                            size: 50, color: AppPallete.neutralColor.shade400),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              if (index < widget.args.post.medias.length) {
                                final media = widget.args.post.medias[index];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (deleteMediaIds.contains(media.id)) {
                                        deleteMediaIds.remove(media.id);
                                      } else {
                                        deleteMediaIds.add(media.id);
                                      }
                                    });
                                  },
                                  child: Stack(
                                    children: [
                                      if (media.type == 'video')
                                        NetworkImageCardWidget(
                                          imageUrl: media.videoThumbnailUrl!,
                                          size: Size(100, 100),
                                        )
                                      else
                                        NetworkImageCardWidget(
                                          imageUrl: media.url,
                                          size: Size(100, 100),
                                        ),
                                      if (deleteMediaIds.contains(media.id))
                                        Card(
                                          color: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              color: Colors.black.withAlpha(128),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.delete,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              } else {
                                final file = files[index - widget.args.post.medias.length];
                                if (RegExp(r'\.(mp4|mov|avi|wmv|flv|mkv|webm)$',
                                        caseSensitive: false)
                                    .hasMatch(file.path)) {
                                  return VideoThumbailWidget(
                                    size: Size(100, 100),
                                    videoPath: file.path,
                                  );
                                } else {
                                  return ImageCardWidget(
                                    file: file,
                                    size: Size(100, 100),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: 300,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 12.0),
                                child: TextFormField(
                                  initialValue: widget.args.post.title,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Judul post harus diisi";
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    formData = formData.copyWith(title: value);
                                  },
                                  style: Theme.of(context).textTheme.titleLarge,
                                  decoration: InputDecoration.collapsed(
                                    hintText: "Judul post kamu...",
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(color: AppPallete.neutralColor.shade400),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 12.0),
                                child: TextFormField(
                                  initialValue: widget.args.post.caption,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Caption post harus diisi";
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    formData = formData.copyWith(caption: value);
                                  },
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  decoration: InputDecoration.collapsed(
                                    hintText:
                                        "Tulis caption kamu disini. Buat caption yang menarik untuk post kamu",
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: AppPallete.neutralColor.shade400),
                                    border: InputBorder.none,
                                  ),
                                  minLines: 5,
                                  maxLines: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (_) {
                                  final hashtagsController = TextEditingController();
                                  hashtagsController.text = formData.hashtags.toHashtags();
                                  return AlertDialog(
                                    elevation: 2.0,
                                    content: SizedBox(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Hashtags",
                                              style: Theme.of(context).textTheme.titleLarge),
                                          SizedBox(height: 16),
                                          CustomTextField(
                                            controller: hashtagsController,
                                            hintText: "#hashtag1 #hashtag2...",
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Batal"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          final text = hashtagsController.text;
                                          if (text.isNotEmpty) {
                                            final hashtags = text.extractHashtags();
                                            formData = formData.copyWith(
                                              hashtags: hashtags,
                                            );

                                            setState(() {
                                              hashtagsText = hashtags.toHashtags();
                                            });
                                          }

                                          Navigator.pop(context);
                                        },
                                        child: Text("Simpan"),
                                      )
                                    ],
                                  );
                                });
                          },
                          child: FormItemWidget(
                              itemIcon: Icons.tag,
                              itemTitle: hashtagsText.isEmpty ? "Hashtags" : hashtagsText),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.push<MyLocationData>('/select_location').then((locationData) {
                              if (locationData != null) {
                                locationAddress = locationData.address;
                                formData = formData.copyWith(location: locationData.latlng);
                                setState(() {});
                              }
                            });
                          },
                          child: FormItemWidget(
                            itemIcon: Icons.location_on_outlined,
                            itemTitle: locationAddress.isEmpty ? "Lokasi" : locationAddress,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: FilledButton(
                      onPressed: () {
                        if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                          _formKey.currentState?.save();
                          formData = formData.copyWith(deleteMediaIds: deleteMediaIds);
                          ref
                              .read(updatePostViewModelProvider(widget.args.post.id).notifier)
                              .updatePost(formData, files);
                        }
                      },
                      child: isLoading
                          ? const LoadingIndicatorWidget(size: 16, color: Colors.white)
                          : const Text("Simpan"),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
