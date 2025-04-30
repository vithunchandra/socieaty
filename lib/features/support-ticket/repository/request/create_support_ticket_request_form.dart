import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_support_ticket_request_form.freezed.dart';
part 'create_support_ticket_request_form.g.dart';

@freezed
class CreateSupportTicketRequestForm with _$CreateSupportTicketRequestForm {
  const factory CreateSupportTicketRequestForm({
    @Default(null) String? title,
    @Default(null) String? description,
  }) = _CreateSupportTicketRequestForm;

  factory CreateSupportTicketRequestForm.fromJson(Map<String, dynamic> json) =>
      _$CreateSupportTicketRequestFormFromJson(json);
}
