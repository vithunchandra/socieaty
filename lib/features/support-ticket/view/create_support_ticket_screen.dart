import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/support-ticket/repository/request/create_support_ticket_request_form.dart';
import 'package:socieaty/features/support-ticket/viewmodel/create_support_ticket_view_model.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/custom_text_field.dart';
import 'package:socieaty/shared/widgets/custom_underline_text_field.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class CreateSupportTicketScreen extends ConsumerStatefulWidget {
  const CreateSupportTicketScreen({super.key});

  @override
  ConsumerState<CreateSupportTicketScreen> createState() => _CreateSupportTicketScreenState();
}

class _CreateSupportTicketScreenState extends ConsumerState<CreateSupportTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  late CreateSupportTicketRequestForm _createSupportTicketRequestForm;

  @override
  void initState() {
    super.initState();
    _createSupportTicketRequestForm = CreateSupportTicketRequestForm();
  }

  void submitTicket() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      ref
          .read(createSupportTicketViewModelProvider.notifier)
          .createSupportTicket(_createSupportTicketRequestForm);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreatingTicket =
        ref.watch(createSupportTicketViewModelProvider).createdSupportTicketState is LoadingState;

    ref.listen(createSupportTicketViewModelProvider, (previous, next) {
      switch (next.createdSupportTicketState) {
        case SuccessState():
          showSnackbar(context, "Tiket dukungan berhasil dibuat");
          context.pop();
          break;
        case ErrorState(message: final message):
          showSnackbar(context, message);
          break;
        default:
          break;
      }
    });
    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      appBar: AppBar(
        title: const Text("Buat Tiket Dukungan"),
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: AppPallete.darkColorOnSurface,
      ),
      body: SafeArea(
        child: Container(
          color: AppPallete.primaryColor,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppPallete.neutralColor.shade50,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Judul",
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          CustomUnderlineTextField(
                            hintText: "Masukkan judul tiket",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Judul tidak boleh kosong";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _createSupportTicketRequestForm =
                                  _createSupportTicketRequestForm.copyWith(title: value);
                            },
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Deskripsi",
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            hintText: "Jelaskan masalah Anda secara detail",
                            maxLines: 5,
                            minLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Deskripsi tidak boleh kosong";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _createSupportTicketRequestForm =
                                  _createSupportTicketRequestForm.copyWith(description: value);
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Berikan detail sebanyak mungkin untuk membantu kami memahami masalah Anda",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppPallete.neutralColor.shade50,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: FilledButton(
                    onPressed: () {
                      submitTicket();
                    },
                    child: isCreatingTicket
                        ? const LoadingIndicatorWidget(
                            size: 16,
                            color: Colors.white,
                          )
                        : const Text("Kirim Tiket"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
