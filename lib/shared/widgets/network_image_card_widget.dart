import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:socieaty/shared/widgets/image_error_widget.dart';
import 'package:socieaty/shared/widgets/image_loading_widget.dart';

class NetworkImageCardWidget extends StatelessWidget {
  final String imageUrl;
  final Size size;
  const NetworkImageCardWidget({super.key, required this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: ClipRRect(
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(12.0),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                imageLoadingWidget(context, url, downloadProgress),
            errorWidget: (context, url, error) => imageErrorWidget(context, error, null),
          ),
        ),
      ),
    );
  }
}
