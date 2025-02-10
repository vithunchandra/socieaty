import 'package:flutter/material.dart';

bool isNowBetween(TimeOfDay? openTime, TimeOfDay? closeTime) {
  final now = TimeOfDay.now();
  if (openTime != null && closeTime != null) {
    if (openTime.hour * 60 + openTime.minute > closeTime.hour * 60 + closeTime.minute) {
      if (now.isBefore(openTime) || now.isAfter(closeTime)) {
        return true;
      }
    } else {
      if (now.isAfter(openTime) && now.isBefore(closeTime)) {
        return true;
      }
    }
  }
  return false;
}
