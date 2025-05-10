import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/core/utils/show_picker_modal.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/authentication/provider/get_user_data_provider.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/customer/model/socieaty_customer.dart';
import 'package:socieaty/features/customer/viewmodel/update_customer_profile_view_model.dart';
import 'package:socieaty/features/customer/viewstate/update_customer_profile_form_state.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/custom_text_field.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'package:socieaty/shared/widgets/profile_picture_widget.dart';

class UpdateCustomerProfileScreen extends ConsumerStatefulWidget {
  final SocieatyCustomer user;
  const UpdateCustomerProfileScreen({super.key, required this.user});

  @override
  ConsumerState<UpdateCustomerProfileScreen> createState() => _UpdateCustomerProfileScreenState();
}

class _UpdateCustomerProfileScreenState extends ConsumerState<UpdateCustomerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final bool _isLoading = false;
  File? _selectedProfilePicture;
  late UpdateCustomerProfileFormState _formData;

  @override
  void initState() {
    super.initState();
    _formData = UpdateCustomerProfileFormState(
      profileUserId: widget.user.id,
      name: widget.user.name,
      phoneNumber: widget.user.phoneNumber,
      bio: widget.user.customerData.bio,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(updateCustomerProfileViewModelProvider, (previous, next) {
      switch (next.updateCustomerState) {
        case SuccessState<SocieatyCustomer>(data: final user):
          () async {
            await ref
                .read(authLocalRepositoryProvider)
                .setUserData(UserConverter.customerToUser(user));
            ref.invalidate(getUserDataProvider(widget.user.id));
            if (context.mounted) {
              context.pop();
            }
          }();
        case ErrorState(message: final message):
          showSnackbar(context, message, state: SnackbarState.error);
        case LoadingState<SocieatyCustomer>():
        case IdleState():
      }
    });

    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      appBar: AppBar(
        backgroundColor: AppPallete.neutralColor.shade50,
        surfaceTintColor: AppPallete.neutralColor.shade50,
        title: Text('Edit Profile', style: Theme.of(context).textTheme.titleMedium),
        centerTitle: true,
        elevation: 0,
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: LoadingIndicatorWidget(size: 16),
                  ),
                )
              : IconButton(
                  onPressed: _handleSave,
                  icon: const Icon(Icons.check, color: AppPallete.primaryColor),
                ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicatorWidget(size: 32)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          showImagePickerModal(context, (image) {
                            setState(() {
                              _selectedProfilePicture = image;
                            });
                          });
                        },
                        child: Stack(
                          children: [
                            PhysicalModel(
                              color: AppPallete.neutralColor.shade50,
                              elevation: 2.0,
                              shadowColor: AppPallete.neutralColor,
                              borderRadius: BorderRadius.circular(50),
                              child: _selectedProfilePicture == null
                                  ? ProfilePictureWidget(
                                      radius: 50,
                                      user: UserConverter.customerToUser(widget.user),
                                    )
                                  : CircleAvatar(
                                      radius: 50,
                                      backgroundColor: AppPallete.neutralColor.shade50,
                                      foregroundImage: FileImage(_selectedProfilePicture!),
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppPallete.primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppPallete.neutralColor.shade50,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      "Nama",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      initialValue: widget.user.name,
                      prefixIcon: const Icon(Icons.person_outline),
                      hintText: "Masukan nama kamu",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama wajib diisi';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _formData = _formData.copyWith(name: value!);
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text("Nama yang akan ditampilkan ke user lain"),
                    const SizedBox(height: 20),
                    Text(
                      "Nomor Telepon",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      initialValue: widget.user.phoneNumber,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      hintText: "Masukan nomor telepon kamu",
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor telepon wajib diisi';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _formData = _formData.copyWith(phoneNumber: value!);
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text("Nomor telepon untuk kontak"),
                    const SizedBox(height: 20),
                    Text(
                      "Bio",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      initialValue: widget.user.customerData.bio,
                      prefixIcon: const Icon(Icons.description_outlined),
                      hintText: "Masukan bio kamu",
                      minLines: 1,
                      maxLines: 3,
                      onSaved: (value) {
                        _formData = _formData.copyWith(bio: value ?? '');
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text("Bio yang akan ditampilkan ke user lain"),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      ref
          .read(updateCustomerProfileViewModelProvider.notifier)
          .updateProfile(_formData, _selectedProfilePicture);
    }
  }
}
