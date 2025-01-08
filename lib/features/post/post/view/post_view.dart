import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/post/post_comment/view/post_comments_view.dart';

class PostView extends StatelessWidget {
  const PostView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Background Image
          Center(
            child: Image.asset(
              'assets/images/person_dummy.jpg',
              fit: BoxFit.fitWidth,
            ),
          ),
          // Bottom Content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Left Column
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.0),
                        Text(
                          "Lorem Ipsum",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 5,
                                color: AppPallete.neutralColor.shade300.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 4,
                                color: AppPallete.neutralColor.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.1),
                  // Right Column
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Material(
                        color: AppPallete.neutralColor.shade50,
                        borderRadius: BorderRadius.circular(25),
                        elevation: 2.0,
                        child: CircleAvatar(
                          radius: 22.5,
                          backgroundImage: AssetImage('assets/images/person_dummy.jpg'),
                        ),
                      ),
                      SizedBox(height: 4),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.favorite_outline),
                      ),
                      Text("1"),
                      SizedBox(height: 4.0),
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            enableDrag: true,
                            useRootNavigator: true,
                            isScrollControlled: true,
                            useSafeArea: true,
                            builder: (context) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                child: PostCommentsView(),
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.comment_outlined),
                      ),
                      Text("100"),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
