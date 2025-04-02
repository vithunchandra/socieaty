import 'package:flutter/material.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'package:video_player/video_player.dart';

class VideoThumbailWidget extends StatefulWidget {
  final Size size;
  final String videoPath;
  const VideoThumbailWidget({super.key, required this.size, required this.videoPath});

  @override
  State<VideoThumbailWidget> createState() => _VideoThumbailWidgetState();
}

class _VideoThumbailWidgetState extends State<VideoThumbailWidget> {
  late VideoPlayerController _videoPlayerController;
  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(12.0),
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: widget.size.width,
          height: widget.size.height,
          child: _videoPlayerController.value.isInitialized
              ? VideoPlayer(_videoPlayerController)
              : const LoadingIndicatorWidget(size: 24),
        ),
      ),
    );
  }
}
