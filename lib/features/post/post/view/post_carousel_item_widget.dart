import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:socieaty/features/post/post/model/post.dart';
import 'package:socieaty/shared/widgets/image_error_widget.dart';
import 'package:socieaty/shared/widgets/image_loading_widget.dart';

class PostCarouselItemWidget extends StatefulWidget {
  final Post post;
  const PostCarouselItemWidget({super.key, required this.post});

  @override
  State<PostCarouselItemWidget> createState() => _PostCarouselItemWidgetState();
}

class _PostCarouselItemWidgetState extends State<PostCarouselItemWidget> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.post.medias.first.type == "video") {
      debugPrint("url: ${widget.post.medias.first.url}");
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.post.medias.first.url))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidget = widget.post.medias.first.type == "image"
        ? CachedNetworkImage(
            imageUrl: widget.post.medias.first.url,
            fit: BoxFit.cover,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                imageLoadingWidget(context, url, downloadProgress),
            errorWidget: (context, url, error) => imageErrorWidget(context, error, null),
          )
        : _controller?.value.isInitialized ?? false
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              );

    return LayoutBuilder(
      builder: (context, constraints) {
        final double fullScreenWidth = MediaQuery.of(context).size.width;
        final bool showOverlayAndTitle = constraints.maxWidth >= (fullScreenWidth / 2);

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxWidth,
            child: Stack(
              fit: StackFit.expand,
              children: [
                mediaWidget,
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: showOverlayAndTitle ? 1.0 : 0.0,
                  curve: Curves.easeInOut,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: showOverlayAndTitle ? 1.0 : 0.0,
                  curve: Curves.easeInOut,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: FractionallySizedBox(
                        widthFactor: 0.7,
                        child: Text(
                          widget.post.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
