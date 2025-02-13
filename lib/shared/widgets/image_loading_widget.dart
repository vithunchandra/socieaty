import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget imageLoadingWidget(BuildContext context, String url, DownloadProgress loadingProgress) {
  final screenWidth = MediaQuery.of(context).size.width;

  return SizedBox(
    width: screenWidth * 0.1,
    height: screenWidth * 0.1,
    child: Center(
      child: CircularProgressIndicator(
        value: loadingProgress.progress,
      ),
    ),
  );
}
