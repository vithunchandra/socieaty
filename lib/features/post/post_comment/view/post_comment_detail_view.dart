import 'package:flutter/material.dart';
import 'package:socieaty/shared/widgets/custom_circle_avatar.dart';

class PostCommentDetailView extends StatefulWidget {
  const PostCommentDetailView({super.key});

  @override
  State<PostCommentDetailView> createState() => _PostCommentDetailViewState();
}

class _PostCommentDetailViewState extends State<PostCommentDetailView> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCircleAvatar(
              radius: 20, imageUrl: 'assets/images/person_dummy.jpg'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "vithun",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isLiked = !isLiked;
              });
            },
            child: Column(
              children: [
                isLiked
                    ? Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                      )
                    : Icon(Icons.favorite_outline),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "129",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
