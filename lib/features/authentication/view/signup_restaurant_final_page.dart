import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/utils/show_image_picker_modal.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/authentication/viewmodel/signup_restaurant_viewmodel.dart';
import 'package:socieaty/features/authentication/viewstate/signup_restaurant_form_state.dart';
import 'package:socieaty/features/map/model/MyLocationData.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/loading_indicator.dart';

import '../../../core/theme/app_pallete.dart';
import '../../../shared/widgets/custom_underline_text_field.dart';

class SignupRestaurantFinalPage extends ConsumerStatefulWidget {
  final SignupRestaurantFormState previousFormData;
  const SignupRestaurantFinalPage(this.previousFormData, {super.key});

  @override
  ConsumerState<SignupRestaurantFinalPage> createState() => _SignupRestaurantFinalPageState();
}

class _SignupRestaurantFinalPageState extends ConsumerState<SignupRestaurantFinalPage> {
  final _formKey = GlobalKey<FormState>();
  late SignupRestaurantFormState _formData = widget.previousFormData.copyWith();
  File? _selectedImage;
  final _restaurantNameController = TextEditingController();
  final _addressController = TextEditingController();
  LatLng? _restaurantLatLng;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final isSignupLoading = ref.watch(signupRestaurantViewModelProvider).signupRestaurantState is LoadingState;

    ref.listen(signupRestaurantViewModelProvider, (_, next) {
      switch (next.signupRestaurantState) {
        case SuccessState<SocieatyUser>(data: final user):
          context.replace('/signin');
        case ErrorState(message: final message):
          showSnackbar(context, message);
        case LoadingState():
        case IdleState():
      }
    });

    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      appBar: AppBar(
        title: const Text("Registrasi customer"),
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: AppPallete.darkColorOnSurface,
      ),
      body: SafeArea(
        child: Container(
          color: AppPallete.primaryColor,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: screenWidth,
                        padding: const EdgeInsets.only(bottom: 48.0, left: 16.0, right: 16.0, top: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppPallete.neutralColor.shade50,
                                  size: 30,
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(
                                    "Isi data restaurant",
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppPallete.darkColorOnSurface),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              "Silahkan masukan data-data restaurant yang diperlukan untuk lanjut ke proses selanjutnya",
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppPallete.darkColorOnSurface),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppPallete.neutralColor.shade50,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                        child: SafeArea(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Nama restaurant",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                CustomUnderlineTextField(
                                  controller: _restaurantNameController,
                                  maxLength: 24,
                                  hintText: "Masukan nama restaurant",
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Nama restaurant tidak boleh kosong";
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _formData = _formData.copyWith(restaurantName: value);
                                  },
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  "Nama ini akan digunakan sebagai nama restaurant anda",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 32.0),
                                Text(
                                  "Alamat restaurant",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 8.0),
                                CustomUnderlineTextField(
                                  controller: _addressController,
                                  maxLength: 256,
                                  hintText: "Masukan alamat restaurant",
                                  suffixIcon: const Icon(Icons.location_on),
                                  suffixIconAction: () {
                                    context.push<MyLocationData>('/select_location').then((locationData) {
                                      if (locationData != null) {
                                        debugPrint("${locationData.address} halooo");
                                        _addressController.text = locationData.address;
                                        _restaurantLatLng = locationData.latlng;
                                        setState(() {});
                                      }
                                    });
                                  },
                                  validator: (value) {
                                    if (_restaurantLatLng == null) {
                                      return "Alamat restaurant tidak boleh kosong";
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _formData = _formData.copyWith(address: _restaurantLatLng);
                                  },
                                ),
                                const SizedBox(height: 32.0),
                                Text(
                                  "Gambar restaurant",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 8.0),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        showImagePickerModal(context, (image) {
                                          setState(() {
                                            _selectedImage = image;
                                          });
                                        });
                                      },
                                      splashColor: AppPallete.neutralColor.shade50,
                                      child: Container(
                                        width: screenWidth - 48,
                                        height: (screenWidth - 48) * 0.5625,
                                        decoration: BoxDecoration(
                                          border: Border.all(width: 1.0, color: AppPallete.neutralColor),
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            _selectedImage != null
                                                ? Expanded(
                                                    child: FittedBox(
                                                      fit: BoxFit.fitWidth,
                                                      child: Image.file(_selectedImage!),
                                                    ),
                                                  )
                                                : const Center(
                                                    child: Icon(
                                                      Icons.add_photo_alternate_outlined,
                                                      size: 56,
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  "Gambar ini akan digunakan sebagai nama gambar banner dari restaurant anda",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
                    onPressed: () async {
                      if (_formKey.currentState != null && _formKey.currentState!.validate() && _selectedImage != null) {
                        _formKey.currentState?.save();
                        ref.read(signupRestaurantViewModelProvider.notifier).signupRestaurant(
                              _formData,
                              _selectedImage!,
                            );
                      }
                    },
                    child: !isSignupLoading ? const Text("Daftar") : LoadingIndicator(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
