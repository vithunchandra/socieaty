import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/topup/enum/topup_status_enum.dart';

part 'topup.freezed.dart';
part 'topup.g.dart';

@freezed
class Topup with _$Topup {
  const factory Topup({
    required String id,
    required String customerId,
    @TopupStatusConverter() required TopupStatusEnum status,
    required double amount,
    @Default(null) String? paymentMethod,
    @Default(null) String? transactionId,
    @Default(null) DateTime? settlemantTime,
    required DateTime createdAt,
  }) = _Topup;

  factory Topup.fromJson(Map<String, dynamic> json) => _$TopupFromJson(json);
}
