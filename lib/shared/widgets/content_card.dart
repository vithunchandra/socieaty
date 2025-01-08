import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/post/post/model/post.dart';

class ContentCard extends StatelessWidget {
  const ContentCard({super.key, required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: Center(
            child: Image.asset(
              'assets/images/person_dummy.jpg',
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      TextButton(onPressed: () {}, child: Text("FYP")),
                      TextButton(onPressed: () {}, child: Text("Customer")),
                      TextButton(onPressed: () {}, child: Text("Restaurant")),
                      Expanded(child: SizedBox()),
                      IconButton(onPressed: () {}, icon: Icon(Icons.live_tv))
                    ],
                  ),
                ),
                Expanded(child: SizedBox()),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: SizedBox(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 12.0,
                                ),
                                Text(
                                  "Lorem Ipsum",
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(0, 0),
                                        blurRadius: 4,
                                        color: AppPallete.neutralColor.shade300.withValues(alpha: 0.5),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 4.0,
                                ),
                                Text(
                                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(0, 0),
                                        blurRadius: 4,
                                        color: AppPallete.neutralColor.shade300.withValues(alpha: 0.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.1),
                        SizedBox(
                          child: Column(
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
                              SizedBox(
                                height: 4,
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.favorite_outline),
                              ),
                              Text("1"),
                              SizedBox(height: 4.0),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.comment_outlined),
                              ),
                              Text("100"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
