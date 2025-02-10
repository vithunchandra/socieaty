import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_data.freezed.dart';
part 'customer_data.g.dart';

@freezed
class CustomerData with _$CustomerData {
  const factory CustomerData({
    required String id,
    @Default(null) String? bio,
    required int wallet,
  }) = _CustomerData;

  factory CustomerData.fromJson(Map<String, dynamic> json) => _$CustomerDataFromJson(json);
}
