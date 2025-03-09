import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'dart:io';
import 'package:socieaty/core/utils/show_picker_modal.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/food_menu/restaurant/viewmodel/create_food_menu_view_model.dart';
import 'package:socieaty/features/food_menu/restaurant/viewstate/create_food_menu_form_state.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/custom_text_field.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class CreateFoodMenuScreen extends ConsumerStatefulWidget {
  const CreateFoodMenuScreen({super.key});

  @override
  CreateFoodMenuScreenState createState() => CreateFoodMenuScreenState();
}

class CreateFoodMenuScreenState extends ConsumerState<CreateFoodMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _menuTypes = [
    'Drink',
    'Rice',
    'Noodles',
    'Soup',
    'Salad',
    'Sandwich',
    'Burger',
    'Pizza',
    'Cake',
    'Ice Cream',
    'Smoothie',
    'Juice',
    'Tea',
    'Coffee',
    'Alcohol'
  ];
  final List<int> _selectedCategories = [];
  CreateFoodMenuFormState _formData = CreateFoodMenuFormState();

  File? _selectedMenuImage;

  void _showMenuTypePickerDialog() {
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
              'Pilih Tipe Menu',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            content: SizedBox(
              height: 300,
              child: Scrollbar(
                interactive: true,
                radius: const Radius.circular(10),
                child: SingleChildScrollView(
                  child: Column(
                    children: _menuTypes
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
                                    color: _selectedCategories.contains(entry.key)
                                        ? AppPallete.primaryColor
                                        : Colors.black87,
                                    fontWeight: _selectedCategories.contains(entry.key)
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                            ),
                            trailing: _selectedCategories.contains(entry.key)
                                ? Icon(
                                    Icons.check_circle,
                                    color: AppPallete.primaryColor,
                                  )
                                : null,
                            onTap: () {
                              setState(() {
                                if (_selectedCategories.contains(entry.key)) {
                                  _selectedCategories.remove(entry.key);
                                } else {
                                  _selectedCategories.add(entry.key);
                                }
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCreateLoading =
        ref.watch(createFoodMenuViewModelProvider).createMenuState is LoadingState;

    ref.listen(createFoodMenuViewModelProvider, (_, next) {
      switch (next.createMenuState) {
        case SuccessState():
          context.pop();
        case ErrorState(message: final message):
          showSnackbar(context, message, isError: true);
        case LoadingState():
        case IdleState():
      }
    });

    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      appBar: AppBar(
        title: Text('Create New Menu Item'),
        elevation: 0,
        backgroundColor: AppPallete.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          showImagePickerModal(context, (image) {
                            setState(() {
                              _selectedMenuImage = image;
                            });
                          });
                        },
                        splashColor: AppPallete.neutralColor.shade50,
                        child: Container(
                          width: screenWidth * 0.3,
                          height: screenWidth * 0.3,
                          decoration: BoxDecoration(
                            color: AppPallete.neutralColor.shade100,
                            border: Border.all(width: 1.0, color: AppPallete.neutralColor),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: _selectedMenuImage != null
                              ? FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Image.file(_selectedMenuImage!),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      color: AppPallete.neutralColor.shade500,
                                      size: 36,
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      "Upload Gambar",
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Nama", style: Theme.of(context).textTheme.titleSmall),
                        SizedBox(height: 8.0),
                        CustomTextField(
                          minLines: 1,
                          maxLines: 2,
                          hintText: "Nasi goreng merah",
                          prefixIcon: Icon(Icons.restaurant_menu),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama wajib diisi';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _formData = _formData.copyWith(name: value);
                          },
                        ),
                        SizedBox(height: 8.0),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),

              Text(
                "Tipe Menu",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  ..._selectedCategories.map(
                    (type) => Chip(
                      label: Text(_menuTypes[type]),
                      onDeleted: () {
                        _selectedCategories.remove(type);
                        setState(() {});
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_selectedCategories.length >= 3) {
                        showSnackbar(context, "Maksimal 3 tema");
                      } else {
                        FocusManager.instance.primaryFocus?.unfocus();

                        _showMenuTypePickerDialog();
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
              Text("Pilih tipe menu. Maksimal 3 tipe"),
              SizedBox(height: 20),

              Text("Deskripsi", style: Theme.of(context).textTheme.titleSmall),
              SizedBox(height: 8.0),
              CustomTextField(
                prefixIcon: Icon(Icons.description),
                hintText: "Masukan deskripsi menu kamu",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi wajib diisi';
                  }
                  return null;
                },
                onSaved: (value) {
                  _formData = _formData.copyWith(description: value);
                },
              ),
              const SizedBox(height: 8),
              Text("Pastikan deskripsi menu menjelaskan detail menu kamu"),
              SizedBox(height: 20),

              Text("Estimasi waktu (menit)", style: Theme.of(context).textTheme.titleSmall),
              SizedBox(height: 8.0),
              CustomTextField(
                keyboardType: TextInputType.number,
                hintText: "Contoh, 40 menit",
                prefixIcon: Icon(Icons.timer),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Estimasi waktu wajib diisi';
                  }
                  return null;
                },
                onSaved: (value) {
                  _formData = _formData.copyWith(estimatedTime: int.parse(value!));
                },
              ),
              const SizedBox(height: 8),
              Text("Estimasi waktu pembuatan menu yang akan ditampilkan ke user"),

              SizedBox(height: 20),
              Text("Harga", style: Theme.of(context).textTheme.titleSmall),
              SizedBox(height: 8.0),
              CustomTextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icon(Icons.attach_money),
                hintText: "Contoh, 100.000",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga wajib diisi';
                  }
                  return null;
                },
                onSaved: (value) {
                  _formData = _formData.copyWith(price: int.parse(value ?? "0"));
                },
              ),
              const SizedBox(height: 8),
              Text("Pastikan harga menu kamu sudah sesuai"),

              SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_selectedMenuImage == null) {
                      showSnackbar(context, "Please upload a photo");
                    }
                    if (_formKey.currentState!.validate() && _selectedCategories.isNotEmpty) {
                      _formKey.currentState!.save();
                      _formData = _formData.copyWith(categories: _selectedCategories);
                      ref
                          .read(createFoodMenuViewModelProvider.notifier)
                          .createFoodMenu(_formData, _selectedMenuImage!);
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: isCreateLoading ? LoadingIndicatorWidget() : Text('Create Menu Item'),
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
