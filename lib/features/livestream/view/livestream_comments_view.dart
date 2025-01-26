import 'package:flutter/material.dart';
import 'package:socieaty/features/livestream/model/livestream_comment.dart';
import 'package:socieaty/shared/widgets/custom_circle_avatar.dart';

class LivestreamCommentsView extends StatelessWidget {
  final List<LivestreamComment> comments;
  const LivestreamCommentsView({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.symmetric(vertical: 12),
            itemCount: comments.length, // Replace with actual message count
            itemBuilder: (context, index) {
              final comment = comments[index];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomCircleAvatar(radius: 20, imageUrl: 'assets/images/person_dummy.jpg'),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              comment.user.name,
                              // widget.postComment.userName,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            SizedBox(height: 2),
                            Text(
                              comment.text,
                              // widget.postComment.text,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
