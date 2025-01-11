import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/utils/LatLngConverter.dart';

part 'create_post_form_state.freezed.dart';
part 'create_post_form_state.g.dart';

@freezed
class CreatePostFormState with _$CreatePostFormState {
  factory CreatePostFormState({
    @Default(null) String? title,
    @Default(null) String? caption,
    @Default([]) List<String> hashtags,
    @LatLngConverter() @Default(LatLng(0, 0)) LatLng? location,
  }) = _CreatePostFormState;

  factory CreatePostFormState.fromJson(Map<String, Object?> json) => _$CreatePostFormStateFromJson(json);
}
