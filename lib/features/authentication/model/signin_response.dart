import 'package:freezed_annotation/freezed_annotation.dart';

part 'signin_response.freezed.dart';
part 'signin_response.g.dart';

@freezed
class SigninResponse with _$SigninResponse {
  const factory SigninResponse({required String token}) = _SigninResponse;

  factory SigninResponse.fromJson(Map<String, dynamic> json) => _$SigninResponseFromJson(json);
}
