import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/enums/bank.enum.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/location_handler.dart';
import 'package:socieaty/core/utils/show_picker_modal.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/map/model/my_location_data.dart';
import 'package:socieaty/features/restaurant/enum/restaurant_verification_status_enum.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/features/restaurant/repository/request/update_restaurant_data_request.dart';
import 'package:socieaty/features/restaurant/viewmodel/update_restaurant_data_view_model.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/custom_underline_text_field.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class UpdateRestaurantDataScreen extends ConsumerStatefulWidget {
  final SocieatyRestaurant restaurant;

  const UpdateRestaurantDataScreen({
    super.key,
    required this.restaurant,
  });

  @override
  ConsumerState<UpdateRestaurantDataScreen> createState() => _UpdateRestaurantDataScreenState();
}

class _UpdateRestaurantDataScreenState extends ConsumerState<UpdateRestaurantDataScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _accountNumberController;
  late final TextEditingController _openTimeController;
  late final TextEditingController _closeTimeController;
  late final TextEditingController _addressController;

  File? _selectedBannerImage;
  File? _selectedProfileImage;
  LatLng? _restaurantLatLng;
  final List<int> _selectedThemes = [];
  Bank? _selectedBank;
  final bool _isLoading = false;
  late UpdateRestaurantDataRequest _formData;

  final List<String> _restaurantThemes = [
    'Casual',
    'Fine Dining',
    'Cafe',
    'Bistro',
    'Street Food',
    'Fusion',
    'Ethnic',
    'Modern',
    'Asian Food',
    'Fast Food',
    'Buffet',
  ];

  final List<Bank> _banks = [
    Bank(name: "BNI (Bank Nasionnal Indonesia)", symbol: BankEnum.bni),
    Bank(name: "BCA (Bank Central Asia)", symbol: BankEnum.bca),
    Bank(name: "BRI (Bank Rakyat Indonesia)", symbol: BankEnum.bri),
    Bank(name: "Bank Mandiri", symbol: BankEnum.mandiri),
  ];

  @override
  void initState() {
    super.initState();
    _formData = UpdateRestaurantDataRequest(
        verificationStatus: widget.restaurant.restaurantData.verificationStatus ==
                RestaurantVerificationStatus.rejected
            ? RestaurantVerificationStatus.unverified
            : widget.restaurant.restaurantData.verificationStatus);
    _initializeControllers();
    _initializeData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.restaurant.name);
    _phoneController = TextEditingController(text: widget.restaurant.phoneNumber);
    _accountNumberController =
        TextEditingController(text: widget.restaurant.restaurantData.accountNumber);
    _openTimeController = TextEditingController(text: widget.restaurant.restaurantData.openTime);
    _closeTimeController = TextEditingController(text: widget.restaurant.restaurantData.closeTime);
    _addressController = TextEditingController(text: "");
  }

  void _initializeData() {
    final restaurantData = widget.restaurant.restaurantData;

    _restaurantLatLng = restaurantData.location;
    _formData = _formData.copyWith(address: _restaurantLatLng);

    // Initialize selected themes
    for (var theme in restaurantData.themes) {
      final themeIndex =
          _restaurantThemes.indexWhere((t) => t.toLowerCase() == theme.name.toLowerCase());
      if (themeIndex != -1) {
        _selectedThemes.add(themeIndex);
      }
    }
    _formData = _formData.copyWith(themes: _selectedThemes);

    // Initialize selected bank
    _selectedBank = _banks.firstWhere((bank) => bank.symbol == restaurantData.payoutBank,
        orElse: () => _banks.first);
    _formData = _formData.copyWith(payoutBank: _selectedBank?.symbol);

    // Parse opening and closing times
    _parseOpenCloseTime();

    getLocationName();
  }

  void _parseOpenCloseTime() {
    final openTime = _openTimeController.text;
    final closeTime = _closeTimeController.text;

    if (openTime.isNotEmpty) {
      final parts = openTime.split(':');
      if (parts.length == 2) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        _formData = _formData.copyWith(openTime: hours * 60 + minutes);
      }
    }

    if (closeTime.isNotEmpty) {
      final parts = closeTime.split(':');
      if (parts.length == 2) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        _formData = _formData.copyWith(closeTime: hours * 60 + minutes);
      }
    }
  }

  void getLocationName() async {
    var location =
        await LocationHandler.getAddressFromLatLng(widget.restaurant.restaurantData.location);
    if (location != null && mounted) {
      setState(() {
        _addressController.text = "${location.street}";
      });
    }
  }

  void _showThemePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                  child: Column(
                    children: _restaurantThemes
                        .asMap()
                        .entries
                        .map(
                          (entry) => ListTile(
                            dense: true,
                            splashColor: AppPallete.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            title: Text(
                              entry.value,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: _selectedThemes.contains(entry.key)
                                        ? AppPallete.primaryColor
                                        : Colors.black87,
                                    fontWeight: _selectedThemes.contains(entry.key)
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                            ),
                            trailing: _selectedThemes.contains(entry.key)
                                ? Icon(
                                    Icons.check_circle,
                                    color: AppPallete.primaryColor,
                                  )
                                : null,
                            onTap: () {
                              setState(() {
                                if (_selectedThemes.contains(entry.key)) {
                                  _selectedThemes.remove(entry.key);
                                } else {
                                  if (_selectedThemes.length < 3) {
                                    _selectedThemes.add(entry.key);
                                  } else {
                                    showSnackbar(context, "Maksimal 3 tema");
                                  }
                                }
                                _formData = _formData.copyWith(themes: _selectedThemes);
                              });

                              context.pop();
                            },
                          ),
                        )
                        .toList(),
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
  }

  Future<void> _updateRestaurantAccount() async {
    if (_formData.openTime > _formData.closeTime) {
      return showSnackbar(context, "Waktu buka tidak boleh lebih dari waktu tutup");
    }
    if (_formKey.currentState != null &&
        _formKey.currentState!.validate() &&
        _openTimeController.text.isNotEmpty &&
        _closeTimeController.text.isNotEmpty) {
      _formKey.currentState?.save();
      _formData = _formData.copyWith(themes: _selectedThemes);

      ref.read(updateRestaurantDataViewModelProvider.notifier).updateRestaurantData(
            widget.restaurant,
            _formData,
            _selectedProfileImage,
            _selectedBannerImage,
          );
    } else {
      showSnackbar(context, "Masukan semua data yang diperlukan");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    ref.listen(updateRestaurantDataViewModelProvider, (previous, next) {
      switch (next.updateRestaurantDataState) {
        case SuccessState(data: final data):
          debugPrint("Success: ${data.toString()}");
          if (data.restaurantData.verificationStatus == RestaurantVerificationStatus.unverified) {
            context.go("/restaurant/unverified");
          } else {
            showSnackbar(context, "Status verifikasi masih rejected");
          }
        case ErrorState(message: final message):
          showSnackbar(context, message);
        default:
          break;
      }
    });

    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      appBar: AppBar(
        title: const Text("Perbarui Data Restoran"),
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
                            const EdgeInsets.only(bottom: 32.0, left: 16.0, right: 16.0, top: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit_note_rounded,
                                  color: AppPallete.neutralColor.shade50,
                                  size: 30,
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(
                                    "Perbarui data restoran",
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(color: AppPallete.darkColorOnSurface),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              "Silahkan perbarui data-data restoran yang diperlukan",
                              style: theme.textTheme.bodyLarge
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileSection(theme, screenWidth),
                              const SizedBox(height: 24.0),
                              _buildBannerSection(screenWidth),
                              const SizedBox(height: 32.0),
                              _buildThemeSection(theme),
                              const SizedBox(height: 32.0),
                              _buildLocationSection(),
                              const SizedBox(height: 32.0),
                              _buildOperatingHoursSection(),
                              const SizedBox(height: 32.0),
                              _buildBankSection(theme),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(ThemeData theme, double screenWidth) {
    return Row(
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
                : widget.restaurant.profilePictureUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Image.network(
                          widget.restaurant.profilePictureUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loading) {
                            if (loading == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppPallete.primaryColor,
                                value: loading.expectedTotalBytes != null
                                    ? loading.cumulativeBytesLoaded / loading.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  color: AppPallete.neutralColor.shade500,
                                  size: 40,
                                ),
                                Text(
                                  "Upload",
                                  style: theme.textTheme.labelSmall,
                                ),
                              ],
                            );
                          },
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
                            style: theme.textTheme.labelSmall,
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
                style: theme.textTheme.titleSmall,
              ),
              CustomUnderlineTextField(
                controller: _nameController,
                maxLength: 24,
                hintText: "Masukan nama restaurant",
                hintStyle: theme.textTheme.titleSmall?.copyWith(color: AppPallete.neutralColor),
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
              const SizedBox(height: 16),
              Text(
                "Nomor Telepon",
                style: theme.textTheme.titleSmall,
              ),
              CustomUnderlineTextField(
                controller: _phoneController,
                maxLength: 12,
                hintText: "cth: 08524390xxxx",
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Nomor telepon tidak boleh kosong";
                  }
                  return null;
                },
                onSaved: (value) {
                  _formData = _formData.copyWith(phoneNumber: value);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBannerSection(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  border: Border.all(width: 1.0, color: AppPallete.neutralColor),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: _selectedBannerImage != null
                    ? Image.file(
                        _selectedBannerImage!,
                        fit: BoxFit.cover,
                      )
                    : widget.restaurant.restaurantData.restaurantBannerUrl.isNotEmpty
                        ? Image.network(
                            widget.restaurant.restaurantData.restaurantBannerUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loading) {
                              if (loading == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: AppPallete.primaryColor,
                                  value: loading.expectedTotalBytes != null
                                      ? loading.cumulativeBytesLoaded / loading.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: AppPallete.neutralColor.shade500,
                                    size: 56,
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    "Upload Banner",
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                ],
                              );
                            },
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                color: AppPallete.neutralColor.shade500,
                                size: 56,
                              ),
                              const SizedBox(height: 4.0),
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
          "Gambar ini akan digunakan sebagai gambar banner dari restaurant anda",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildThemeSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tema Restaurant",
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: [
            ..._selectedThemes.map(
              (key) => Chip(
                label: Text(_restaurantThemes[key]),
                deleteIcon: const Icon(
                  Icons.close,
                  size: 18,
                ),
                onDeleted: () {
                  setState(() {
                    _selectedThemes.remove(key);
                    _formData = _formData.copyWith(themes: _selectedThemes);
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
                    const Text("Pilih"),
                    const SizedBox(width: 4.0),
                    Icon(
                      Icons.add,
                      size: 20,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ],
                ),
                backgroundColor: AppPallete.primaryColor.shade300,
                labelStyle: TextStyle(color: theme.colorScheme.onPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Pilih tema restaurant. Maksimal 3 tema",
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            context.push<MyLocationData>('/select_location').then((locationData) {
              if (locationData != null) {
                _restaurantLatLng = locationData.latlng;
                _formData = _formData.copyWith(address: _restaurantLatLng);
                _addressController.text = locationData.address;
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
        ),
        const SizedBox(height: 8.0),
        Text(
          "Pastikan alamat restaurant benar",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildOperatingHoursSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                      _openTimeController.text =
                          "${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}";
                      _formData = _formData.copyWith(openTime: value.hour * 60 + value.minute);
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
                    context: context,
                    initialTime: TimeOfDay.now(),
                  ).then((value) {
                    if (value != null) {
                      _closeTimeController.text =
                          "${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}";
                      _formData = _formData.copyWith(closeTime: value.hour * 60 + value.minute);
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
      ],
    );
  }

  Widget _buildBankSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bank",
          style: theme.textTheme.titleSmall,
        ),
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<Bank>(
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 22),
            decoration: const InputDecoration(
              border: UnderlineInputBorder(
                borderSide: BorderSide(width: 2.0),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppPallete.neutralColor, width: 2.0),
              ),
            ),
            value: _selectedBank,
            hint: const Text('Pilih Bank'),
            isExpanded: true,
            onChanged: (Bank? newValue) {
              setState(() {
                _selectedBank = newValue;
                _formData = _formData.copyWith(payoutBank: newValue?.symbol);
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
          ),
        ),
        const SizedBox(height: 12.0),
        Text(
          "No Rekening",
          style: theme.textTheme.titleSmall,
        ),
        CustomUnderlineTextField(
          controller: _accountNumberController,
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
        const SizedBox(height: 8.0),
        Text(
          "No rekening akan digunakan untuk melakukan pembayaran. Pastikan no rekening benar",
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppPallete.neutralColor.shade50,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: FilledButton(
          onPressed: _isLoading ? null : _updateRestaurantAccount,
          style: FilledButton.styleFrom(
            backgroundColor: AppPallete.primaryColor,
            disabledBackgroundColor: AppPallete.neutralColor.shade300,
          ),
          child: _isLoading
              ? const LoadingIndicatorWidget(size: 24, color: Colors.white)
              : const Text("Simpan Perubahan"),
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
