import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:socieaty/shared/widgets/custom_circle_avatar.dart';

class LiveScreen extends ConsumerStatefulWidget {
  final Room room;
  const LiveScreen({super.key, required this.room});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: FittedBox(
              fit: BoxFit.cover,
              child: Image.asset("assets/images/person_dummy.jpg"),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    IconButton.filled(
                      onPressed: () {
                        context.pop();
                      },
                      icon: Icon(Icons.close),
                      color: Colors.black.withAlpha(128),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Live",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                          ),
                          SizedBox(width: 2),
                          Icon(Icons.podcasts, color: Colors.red),
                          SizedBox(width: 4),
                          Icon(Icons.person, color: Colors.white),
                          SizedBox(width: 2),
                          Text("0", style: Theme.of(context).textTheme.bodyMedium),
                          SizedBox(width: 4),
                          Icon(Icons.favorite, color: Colors.white),
                          SizedBox(width: 2),
                          Text("0", style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(100),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.flip_camera_android,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.mic,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.comment,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: screenHeight * 0.3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(8),
                    Colors.black.withAlpha(255),
                  ],
                ),
              ),
              child: ShaderMask(
                shaderCallback: (Rect rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.white,
                      Colors.white,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.2, 0.8, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.0),
                  child: ListView.builder(
                    itemCount: 10,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    itemBuilder: (context, index) {
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
                                      "Vithunchan",
                                      // widget.postComment.userName,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "Hallo test comment hehehehhehehe",
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
            ),
          )
        ],
      ),
    );
  }
}
