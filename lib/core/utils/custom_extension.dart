import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension StringCasingExtension on String {
  String toCapitalized() {
    if (isEmpty) {
      return "";
    }
    final firstLetter = this[0].toUpperCase();
    if (length < 2) {
      return firstLetter;
    }
    final restOfLetter = substring(1).toLowerCase();
    return length > 0 ? '$firstLetter$restOfLetter' : '';
  }

  String toTitleCase() {
    return replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized).join(' ');
  }

  List<String> extractHashtags() {
    return replaceAll(' ', '').split('#').where((element) => element.isNotEmpty).toList();
  }
}

extension ListStringExtension on List<String> {
  String toHashtags() {
    return where((hashtag) => hashtag.isNotEmpty) // Exclude empty strings
        .map((hashtag) => "#$hashtag") // Prepend #
        .join(" "); // Join with space
  }
}

extension DioExceptionExtension on DioException {
  String extractMesage() {
    final response = this.response;
    if (response != null) {
      if (response.data is Map<String, dynamic>) {
        return response.data['message']?.toString() ?? '';
      } else {
        return response.data;
      }
    } else {
      return message.toString();
    }
  }
}

extension BuildContextExtension on BuildContext {
  void popUntilPath(String routePath) {
    final router = GoRouter.of(this);
    while (router.routerDelegate.currentConfiguration.matches.last.matchedLocation != routePath) {
      if (!router.canPop()) {
        return;
      }
      router.pop();
    }
  }
}
