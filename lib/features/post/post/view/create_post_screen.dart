import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/core/utils/show_picker_modal.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/home/customer/provider/all_post_provider.dart';
import 'package:socieaty/features/map/model/my_location_data.dart';
import 'package:socieaty/features/post/post/model/post.dart';
import 'package:socieaty/features/post/post/viewmodel/create_post_view_model.dart';
import 'package:socieaty/features/post/post/viewstate/create_post_form_state.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/custom_text_field.dart';
import 'package:socieaty/shared/widgets/form_item_widget.dart';
import 'package:socieaty/shared/widgets/image_card_widget.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'package:socieaty/shared/widgets/profile_card_widget.dart';
import 'package:socieaty/shared/widgets/video_thumbail_widget.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<File> files = List.empty(growable: true);
  String hashtagsText = "";
  String locationAddress = "";
  CreatePostFormState formData = CreatePostFormState();

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(createPostViewModelProvider).createPostState is LoadingState;
    final user = ref.watch(authLocalRepositoryProvider).getUserData();

    ref.listen(createPostViewModelProvider, (_, next) {
      switch (next.createPostState) {
        case SuccessState<Post>():
          ref.invalidate(allPostProvider);
          if (user?.role == UserRole.customer) {
            context.pop();
          } else {
            context.pop();
          }
        case ErrorState(message: final message):
          showSnackbar(context, message, state: SnackbarState.error);
        case LoadingState():
        case IdleState():
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.chevron_left),
          iconSize: 30,
        ),
        backgroundColor: AppPallete.neutralColor.shade50,
        title: Text("Buat Post"),
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
                          itemCount: files.length + 1,
                          itemBuilder: (context, index) {
                            if (index == files.length) {
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
                            final file = files[index];
                            if (RegExp(r'\.(mp4|mov|avi|wmv|flv|mkv|webm)$', caseSensitive: false)
                                .hasMatch(file.path)) {
                              return VideoThumbailWidget(
                                size: Size(100, 100),
                                videoPath: file.path,
                              );
                            } else {
                              return ImageCardWidget(
                                file: files[index],
                                size: Size(100, 100),
                              );
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
                        ref.read(createPostViewModelProvider.notifier).createPost(formData, files);
                      }
                    },
                    child: isLoading
                        ? const LoadingIndicatorWidget(size: 16, color: Colors.white)
                        : const Text("Unggah"),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
