import 'package:flutter/material.dart';
import 'package:socieaty/features/livestream/model/livestream_comment.dart';
import 'package:socieaty/shared/widgets/profile_picture_widget.dart';

class LivestreamCommentsWidget extends StatelessWidget {
  final List<LivestreamComment> comments;
  const LivestreamCommentsWidget({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final controller = ScrollController();

    // Scroll to top since list is reversed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients) {
        controller.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return SizedBox(
      height: screenHeight * 0.3,
      child: ShaderMask(
        shaderCallback: (Rect rect) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
            stops: const [0.0, 0.1, 0.9, 1.0],
          ).createShader(rect);
        },
        blendMode: BlendMode.dstIn,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          child: ListView.builder(
            controller: controller,
            scrollDirection: Axis.vertical,
            reverse: true,
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              return AnimatedCommentItem(
                key: ValueKey(comment.id), // Add key back to force widget recreation
                comment: comment,
                index: index,
                totalComments: comments.length,
              );
            },
          ),
        ),
      ),
    );
  }
}

class AnimatedCommentItem extends StatefulWidget {
  final LivestreamComment comment;
  final int index;
  final int totalComments;

  const AnimatedCommentItem({
    super.key,
    required this.comment,
    required this.index,
    required this.totalComments,
  });

  @override
  State<AnimatedCommentItem> createState() => _AnimatedCommentItemState();
}

class _AnimatedCommentItemState extends State<AnimatedCommentItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuad,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Only animate if this is the newest comment (index 0)
    if (widget.index == 0) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfilePictureWidget(
              radius: 20,
              user: widget.comment.user,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      widget.comment.user.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.comment.text,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
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
