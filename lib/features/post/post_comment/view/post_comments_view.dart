import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/post/post_comment/view/post_comment_detail_view.dart';
import 'package:socieaty/shared/widgets/custom_circle_avatar.dart';

class PostCommentsView extends StatelessWidget {
  const PostCommentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: SizedBox(
                    child: Column(
                      children: [
                        Divider(
                          indent: screenWidth * 0.4,
                          endIndent: screenWidth * 0.4,
                          thickness: 2,
                        ),
                        const Text("32 Comments"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: const PostCommentDetailView());
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  CustomCircleAvatar(radius: 20, imageUrl: "assets/images/person_dummy.jpg"),
                  SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Caption post harus diisi";
                          }
                          return null;
                        },
                        onSaved: (value) {},
                        decoration: InputDecoration.collapsed(
                          hintText: "Your caption here. Create a wonderful caption for your post",
                          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppPallete.neutralColor.shade400),
                          hintFadeDuration: Duration(milliseconds: 250),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(onPressed: () {}, icon: Icon(Icons.arrow_upward))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
