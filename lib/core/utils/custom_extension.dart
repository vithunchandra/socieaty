import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/menu_item/model/menu_item.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';

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

extension MenuItemsExtension on List<MenuItem> {
  int calculateTotalPrice() {
    return fold(0, (sum, item) => sum + item.totalPrice);
  }
}

extension ReservationStatusExtension on ReservationStatus {
  Color getStatusColor() {
    switch (this) {
      case ReservationStatus.confirmed:
        return AppPallete.successColor;
      case ReservationStatus.dining:
        return AppPallete.primaryColor;
      case ReservationStatus.pending:
        return AppPallete.warningColor;
      case ReservationStatus.canceled:
        return AppPallete.errorColor;
      case ReservationStatus.completed:
        return AppPallete.infoColor;
      case ReservationStatus.rejected:
        return AppPallete.errorColor;
    }
  }

  IconData getStatusIcon() {
    switch (this) {
      case ReservationStatus.confirmed:
        return Icons.check_circle;
      case ReservationStatus.dining:
        return Icons.dining;
      case ReservationStatus.pending:
        return Icons.pending;
      case ReservationStatus.canceled:
        return Icons.cancel;
      case ReservationStatus.completed:
        return Icons.task_alt;
      case ReservationStatus.rejected:
        return Icons.close;
    }
  }

  String getStatusName() {
    switch (this) {
      case ReservationStatus.confirmed:
        return 'dikonfirmasi';
      case ReservationStatus.dining:
        return 'sedang makan';
      case ReservationStatus.canceled:
        return 'dibatalkan';
      case ReservationStatus.completed:
        return 'selesai';
      case ReservationStatus.pending:
        return 'menunggu';
      case ReservationStatus.rejected:
        return 'ditolak';
    }
  }
}
