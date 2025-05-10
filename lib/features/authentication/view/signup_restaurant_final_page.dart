import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/enums/bank.enum.dart';
import 'package:socieaty/core/utils/show_picker_modal.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/authentication/viewmodel/signup_restaurant_viewmodel.dart';
import 'package:socieaty/features/authentication/viewstate/signup_restaurant_form_state.dart';
import 'package:socieaty/features/map/model/my_location_data.dart';
import 'package:socieaty/features/restaurant/model/restaurant_theme.dart';
import 'package:socieaty/features/restaurant/provider/get_all_restaurant_themes_provider.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

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
  File? _selectedBannerImage;
  File? _selectedProfileImage;
  final _restaurantNameController = TextEditingController();
  final _addressController = TextEditingController();
  LatLng? _restaurantLatLng;
  final List<RestaurantTheme> _selectedThemes = [];
  Bank? _selectedBank;
  final _openTimeController = TextEditingController(text: "");
  final _closeTimeController = TextEditingController(text: "");

  final List<Bank> _banks = [
    Bank(name: "BNI (Bank Nasionnal Indonesia)", symbol: BankEnum.bni),
    Bank(name: "BCA (Bank Central Asia)", symbol: BankEnum.bca),
    Bank(name: "BRI (Bank Rakyat Indonesia)", symbol: BankEnum.bri),
    Bank(name: "Bank Mandiri", symbol: BankEnum.mandiri),
  ];

  void _showThemePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer(
          builder: (BuildContext context, WidgetRef ref, child) {
            final restaurantThemes = ref.watch(getAllRestaurantThemesProvider);
            return PopScope(
              onPopInvokedWithResult: (didPop, result) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                title: Text(
                  'Pilih Tema Resto',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                content: SizedBox(
                  height: 300,
                  child: Scrollbar(
                    interactive: true,
                    radius: const Radius.circular(10),
                    child: SingleChildScrollView(
                      child: restaurantThemes.when(
                        data: (themes) {
                          return Column(
                            children: themes
                                .map(
                                  (theme) => ListTile(
                                    dense: true,
                                    splashColor: AppPallete.primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                    title: Text(
                                      theme.name,
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            color: _selectedThemes.any((t) => t.id == theme.id)
                                                ? AppPallete.primaryColor
                                                : Colors.black87,
                                            fontWeight: _selectedThemes.any((t) => t.id == theme.id)
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                    ),
                                    trailing: _selectedThemes.any((t) => t.id == theme.id)
                                        ? Icon(
                                            Icons.check_circle,
                                            color: AppPallete.primaryColor,
                                          )
                                        : null,
                                    onTap: () {
                                      setState(() {
                                        final existingIndex =
                                            _selectedThemes.indexWhere((t) => t.id == theme.id);
                                        if (existingIndex >= 0) {
                                          _selectedThemes.removeAt(existingIndex);
                                        } else {
                                          if (_selectedThemes.length < 3) {
                                            _selectedThemes.add(theme);
                                          } else {
                                            showSnackbar(context, "Maksimal 3 tema");
                                          }
                                        }
                                      });

                                      context.pop();
                                    },
                                  ),
                                )
                                .toList(),
                          );
                        },
                        loading: () => const Center(
                          child: LoadingIndicatorWidget(size: 24),
                        ),
                        error: (error, stackTrace) => Center(
                          child: Text('Error: ${error.toString()}'),
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: Text(
                      'Tutup',
                      style: TextStyle(color: AppPallete.primaryColor),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final isSignupLoading =
        ref.watch(signupRestaurantViewModelProvider).signupRestaurantState is LoadingState;

    ref.listen(signupRestaurantViewModelProvider, (_, next) {
      switch (next.signupRestaurantState) {
        case SuccessState<SocieatyUser>():
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
        title: const Text("Registrasi Restaurant"),
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
                        padding:
                            const EdgeInsets.only(bottom: 48.0, left: 16.0, right: 16.0, top: 24.0),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(color: AppPallete.darkColorOnSurface),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              "Silahkan masukan data-data restaurant yang diperlukan untuk lanjut ke proses selanjutnya",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: AppPallete.darkColorOnSurface),
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
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        showImagePickerModal(context, (image) {
                                          setState(() {
                                            _selectedProfileImage = image;
                                          });
                                        });
                                      },
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: AppPallete.neutralColor.shade200,
                                          borderRadius: BorderRadius.circular(15.0),
                                          border: Border.all(color: AppPallete.neutralColor),
                                        ),
                                        child: _selectedProfileImage != null
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(15.0),
                                                child: Image.file(
                                                  _selectedProfileImage!,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.camera_alt,
                                                    color: AppPallete.neutralColor.shade500,
                                                    size: 40,
                                                  ),
                                                  Text(
                                                    "Upload",
                                                    style: Theme.of(context).textTheme.labelSmall,
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Nama Restaurant",
                                            style: Theme.of(context).textTheme.titleSmall,
                                          ),
                                          CustomUnderlineTextField(
                                            controller: _restaurantNameController,
                                            maxLength: 24,
                                            hintText: "Masukan nama restaurant",
                                            hintStyle: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(color: AppPallete.neutralColor),
                                            validator: (value) {
                                              if (value == null || value.trim().isEmpty) {
                                                return "Nama restaurant tidak boleh kosong";
                                              }
                                              return null;
                                            },
                                            onSaved: (value) {
                                              _formData = _formData.copyWith(name: value);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Banner restaurant",
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
                                            _selectedBannerImage = image;
                                          });
                                        });
                                      },
                                      splashColor: AppPallete.neutralColor.shade50,
                                      child: Container(
                                        width: screenWidth - 48,
                                        height: (screenWidth - 48) * 0.5625,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1.0, color: AppPallete.neutralColor),
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                        child: _selectedBannerImage != null
                                            ? FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Image.file(_selectedBannerImage!),
                                              )
                                            : Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.add_photo_alternate_outlined,
                                                    color: AppPallete.neutralColor.shade500,
                                                    size: 56,
                                                  ),
                                                  SizedBox(height: 4.0),
                                                  Text(
                                                    "Upload Banner",
                                                    style: Theme.of(context).textTheme.labelSmall,
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
                                const SizedBox(height: 32.0),
                                Text(
                                  "Tema Restaurant",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children: [
                                    ..._selectedThemes.map(
                                      (theme) => Chip(
                                        label: Text(theme.name),
                                        onDeleted: () {
                                          setState(() {
                                            _selectedThemes.remove(theme);
                                          });
                                        },
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (_selectedThemes.length >= 3) {
                                          showSnackbar(context, "Maksimal 3 tema");
                                        } else {
                                          FocusManager.instance.primaryFocus?.unfocus();

                                          _showThemePickerDialog();
                                        }
                                      },
                                      child: Chip(
                                        label: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("Pilih"),
                                            SizedBox(width: 4.0),
                                            Icon(
                                              Icons.add,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                        backgroundColor: AppPallete.primaryColor.shade300,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text("Pilih tema restaurant. Maksimal 3 tema"),
                                const SizedBox(
                                  height: 32,
                                ),
                                Text(
                                  "Alamat restaurant",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                CustomUnderlineTextField(
                                  controller: _addressController,
                                  maxLength: 256,
                                  hintText: "Masukan alamat restaurant",
                                  autoFocus: false,
                                  suffixIcon: const Icon(Icons.location_on),
                                  suffixIconAction: () {
                                    context
                                        .push<MyLocationData>('/select_location')
                                        .then((locationData) {
                                      if (locationData != null) {
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
                                SizedBox(height: 8.0),
                                Text("Pastikan alamat restaurant benar"),
                                SizedBox(height: 32.0),
                                Text(
                                  "Jam Buka Restaurant",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomUnderlineTextField(
                                        controller: _openTimeController,
                                        hintText: "Buka",
                                        onTap: () async {
                                          showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now(),
                                          ).then((value) {
                                            if (value != null) {
                                              _formData = _formData.copyWith(
                                                  openTime: value.hour * 60 + value.minute);
                                              _openTimeController.text =
                                                  "${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}";
                                              setState(() {});
                                            }
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Waktu buka tidak boleh kosong";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: CustomUnderlineTextField(
                                        controller: _closeTimeController,
                                        hintText: "Tutup",
                                        onTap: () async {
                                          showTimePicker(
                                                  context: context, initialTime: TimeOfDay.now())
                                              .then((value) {
                                            if (value != null) {
                                              _formData = _formData.copyWith(
                                                  closeTime: value.hour * 60 + value.minute);
                                              _closeTimeController.text =
                                                  "${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}";
                                              setState(() {});
                                            }
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Waktu tutup tidak boleh kosong";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 32.0),
                                Text(
                                  "Bank",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: DropdownButtonFormField<Bank>(
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontSize: 22),
                                    decoration: InputDecoration(
                                      border: const UnderlineInputBorder(
                                        borderSide: BorderSide(width: 2.0),
                                      ),
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: AppPallete.neutralColor, width: 2.0),
                                      ),
                                    ),
                                    value: _selectedBank,
                                    hint: Text('Pilih Bank'),
                                    isExpanded: true,
                                    onChanged: (Bank? newValue) {
                                      setState(() {
                                        _selectedBank = newValue;
                                      });
                                    },
                                    items: _banks.map<DropdownMenuItem<Bank>>((bank) {
                                      return DropdownMenuItem<Bank>(
                                        value: bank,
                                        child: Text(bank.name),
                                      );
                                    }).toList(),
                                    validator: (value) {
                                      if (value == null) {
                                        return "Bank tidak boleh kosong";
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _formData = _formData.copyWith(payoutBank: value!.symbol);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 12.0,
                                ),
                                Text(
                                  "No Rekening",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                CustomUnderlineTextField(
                                  hintText: "Masukan no rekening",
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "No rekening tidak boleh kosong";
                                    }
                                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                      return "No rekening tidak valid";
                                    }

                                    return null;
                                  },
                                  onSaved: (value) {
                                    _formData = _formData.copyWith(accountNumber: value);
                                  },
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                    "No rekening akan digunakan untuk melakukan pembayaran. Pastikan no rekening benar"),
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
                      if (_formData.openTime > _formData.closeTime) {
                        return showSnackbar(
                            context, "Waktu buka tidak boleh lebih dari waktu tutup");
                      }
                      if (_formKey.currentState != null &&
                          _formKey.currentState!.validate() &&
                          _selectedBannerImage != null &&
                          _selectedProfileImage != null &&
                          _openTimeController.text.isNotEmpty &&
                          _closeTimeController.text.isNotEmpty) {
                        _formKey.currentState?.save();
                        _formData = _formData.copyWith(
                            themes: _selectedThemes.map((theme) => theme.id).toList());

                        ref.read(signupRestaurantViewModelProvider.notifier).signupRestaurant(
                              _formData,
                              _selectedProfileImage!,
                              _selectedBannerImage!,
                            );
                      } else {
                        showSnackbar(context, "Masukan semua data yang diperlukan");
                      }
                    },
                    child: !isSignupLoading
                        ? const Text("Daftar")
                        : const LoadingIndicatorWidget(size: 16, color: Colors.white),
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

class Bank {
  final String name;
  final BankEnum symbol;

  Bank({required this.name, required this.symbol});
}
