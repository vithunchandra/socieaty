import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/features/home/customer/viewmodel/home_screen_view_model.dart';
import 'package:socieaty/shared/provider/navigation_provider.dart';
import 'package:socieaty/shared/widgets/loading_indicator.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends ConsumerStatefulWidget {
  final String videoUrl;
  final String postId;
  const VideoPlayerWidget({super.key, required this.videoUrl, required this.postId});

  @override
  ConsumerState<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends ConsumerState<VideoPlayerWidget> {
  late VideoPlayerController _videoController;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _videoController.initialize();
      setState(() {
        _isInitialized = true;
        _videoController.play();
        _videoController.setLooping(true);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading video: $e';
      });
    }
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.postId != widget.postId) {
      _isInitialized = false;
      _videoController.pause();
      setState(() {});
      _initializeVideo();
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(navigationIndexProvider, (_, next) {
      if (next[next.length - 1] != 0) {
        _videoController.pause();
      } else {
        if (ref.watch(homeScreenViewModelProvider).currentPostId == widget.postId) {
          _videoController.play();
        }
      }
    });

    ref.listen(homeScreenViewModelProvider, (_, next) {
      debugPrint("next: ${next.currentPostId}");
      if (next.currentPostId != widget.postId) {
        _videoController.pause();
      } else {
        _videoController.play();
      }
    });

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (!_isInitialized) {
      return const Center(child: LoadingIndicator());
    }

    return GestureDetector(
      onLongPress: () {
        _videoController.pause();
      },
      onLongPressEnd: (details) {
        _videoController.play();
      },
      child: AspectRatio(
        aspectRatio: _videoController.value.aspectRatio,
        child: VideoPlayer(_videoController),
      ),
    );
  }
}
