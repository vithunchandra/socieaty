import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:socieaty/features/post/post/model/post.dart';
import 'package:socieaty/shared/widgets/image_error_widget.dart';
import 'package:socieaty/shared/widgets/image_loading_widget.dart';

class PostCardWidget extends StatelessWidget {
  final Post post;
  const PostCardWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final imageUrl = post.medias.first.type == "image"
        ? post.medias.first.url
        : post.medias.first.videoThumbnailUrl ?? "";
    final mediaWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          imageLoadingWidget(context, url, downloadProgress),
      errorWidget: (context, url, error) => imageErrorWidget(context, error, null),
      useOldImageOnUrlChange: false,
    );

    return mediaWidget;
  }
}
