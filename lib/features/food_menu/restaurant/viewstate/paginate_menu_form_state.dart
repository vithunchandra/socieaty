import 'package:freezed_annotation/freezed_annotation.dart';

part 'paginate_menu_form_state.freezed.dart';
part 'paginate_menu_form_state.g.dart';

@freezed
class PaginateMenuFormState with _$PaginateMenuFormState {
  const factory PaginateMenuFormState({
    @Default('') String restaurantId,
    @Default([]) List<String> priceRanges,
    @Default(0) double minRating,
    @Default([]) List<int> categories,
    @Default('') String searchQuery,
    @Default(0) int offset,
    @Default(5) int limit,
  }) = _PaginateMenuFormState;

  factory PaginateMenuFormState.fromJson(Map<String, dynamic> json) =>
      _$PaginateMenuFormStateFromJson(json);
}
