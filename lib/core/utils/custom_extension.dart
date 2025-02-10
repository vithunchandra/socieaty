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

  TimeOfDay toTimeOfDay() {
    final parts = split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
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

extension PriceFormatter on num {
  String toIDRFormat() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
