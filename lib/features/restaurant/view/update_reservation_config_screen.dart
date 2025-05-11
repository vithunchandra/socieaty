import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/restaurant/model/reservation_config.dart';
import 'package:socieaty/features/restaurant/provider/get_facilities_suggestion_provider.dart';
import 'package:socieaty/features/restaurant/provider/get_restaurant_reservation_config_provider.dart';
import 'package:socieaty/features/restaurant/viewmodel/update_reservation_config_view_model.dart';
import 'package:socieaty/features/restaurant/viewstate/update_reservation_config_form_state.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/custom_text_field.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class UpdateReservationConfigScreen extends ConsumerStatefulWidget {
  final ReservationConfig reservationConfig;
  const UpdateReservationConfigScreen({super.key, required this.reservationConfig});

  @override
  UpdateReservationConfigScreenState createState() => UpdateReservationConfigScreenState();
}

class UpdateReservationConfigScreenState extends ConsumerState<UpdateReservationConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _maxPersonController = TextEditingController();
  final TextEditingController _minCostController = TextEditingController();
  final TextEditingController _timeLimitController = TextEditingController();
  final List<String> _facilities = [];
  late UpdateReservationConfigFormState _formData;

  @override
  void initState() {
    super.initState();
    _maxPersonController.text = widget.reservationConfig.maxPerson.toString();
    _minCostController.text = widget.reservationConfig.minCostPerPerson.toString();
    _timeLimitController.text = widget.reservationConfig.timeLimit.toString();
    _facilities.addAll(widget.reservationConfig.facilities);

    _formData = UpdateReservationConfigFormState(
      id: widget.reservationConfig.id,
      maxPerson: widget.reservationConfig.maxPerson,
      minCostPerPerson: widget.reservationConfig.minCostPerPerson,
      timeLimit: widget.reservationConfig.timeLimit,
      facilities: _facilities,
    );
  }

  @override
  void dispose() {
    _maxPersonController.dispose();
    _minCostController.dispose();
    _timeLimitController.dispose();
    super.dispose();
  }

  void _addFacility(String facility) {
    if (facility.isNotEmpty && !_facilities.contains(facility)) {
      setState(() {
        _facilities.add(facility);
      });
    }
  }

  void _showAddFacilityDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return FacilitySelectionDialog(
          onFacilitySelected: _addFacility,
          existingFacilities: _facilities,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref
        .watch(updateReservationConfigViewModelProvider)
        .updateReservationConfigState is LoadingState;

    ref.listen(updateReservationConfigViewModelProvider, (previous, next) {
      switch (next.updateReservationConfigState) {
        case SuccessState<ReservationConfig>():
          final currentUser = ref.watch(authLocalRepositoryProvider).getUserData();
          if (currentUser != null) {
            ref.invalidate(getRestaurantReservationConfigProvider(currentUser.restaurantData!.id));
            context.pop();
          }
        case ErrorState(message: final message):
          showSnackbar(context, message, state: SnackbarState.error);
        case LoadingState<ReservationConfig>():
        case IdleState():
      }
    });

    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      appBar: AppBar(
        title: const Text('Update Reservation Config'),
        elevation: 0,
        backgroundColor: AppPallete.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Maksimal Orang", style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8.0),
              CustomTextField(
                controller: _maxPersonController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.people),
                hintText: "Masukkan maksimal orang",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Maksimal orang dibutuhkan';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
                onSaved: (value) {
                  _formData = _formData.copyWith(maxPerson: int.parse(value!));
                },
              ),
              const SizedBox(height: 8),
              const Text("Maksimal orang yang diizinkan untuk reservasi"),
              const SizedBox(height: 20),
              Text("Minimum Biaya Per Orang", style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8.0),
              CustomTextField(
                controller: _minCostController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.attach_money),
                hintText: "Masukkan biaya minimum per orang",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Biaya minimum dibutuhkan';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
                onSaved: (value) {
                  _formData = _formData.copyWith(minCostPerPerson: int.parse(value!));
                },
              ),
              const SizedBox(height: 8),
              const Text("Biaya minimum yang harus dihabiskan setiap orang"),
              const SizedBox(height: 20),
              Text("Batas Waktu (menit)", style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8.0),
              CustomTextField(
                controller: _timeLimitController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.timer),
                hintText: "Masukkan batas waktu dalam menit",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Batas waktu dibutuhkan';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
                onSaved: (value) {
                  _formData = _formData.copyWith(timeLimit: int.parse(value!));
                },
              ),
              const SizedBox(height: 8),
              const Text("Maksimal waktu yang diizinkan untuk reservasi"),
              const SizedBox(height: 20),
              Text("Fasilitas", style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8.0),
              Container(
                decoration: BoxDecoration(
                  color: AppPallete.neutralColor.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    ..._facilities.map((facility) => Chip(
                          label: Text(
                            facility,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: AppPallete.neutralColor.shade200),
                          deleteIconColor: AppPallete.primaryColor,
                          onDeleted: () {
                            setState(() {
                              _facilities.remove(facility);
                            });
                          },
                        )),
                    GestureDetector(
                      onTap: _showAddFacilityDialog,
                      child: Chip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Tambah Fasilitas",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 4.0),
                            Icon(
                              Icons.add,
                              size: 20,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        backgroundColor: AppPallete.primaryColor,
                        side: BorderSide.none,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text("Daftar fasilitas yang tersedia untuk reservasi"),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            _formData = _formData.copyWith(facilities: _facilities);
                            ref
                                .read(updateReservationConfigViewModelProvider.notifier)
                                .updateReservationConfig(_formData);
                          }
                        },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: isLoading
                        ? const LoadingIndicatorWidget(size: 16, color: Colors.white)
                        : const Text('Update Konfigurasi'),
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

class FacilitySelectionDialog extends ConsumerStatefulWidget {
  final Function(String) onFacilitySelected;
  final List<String> existingFacilities;

  const FacilitySelectionDialog({
    super.key,
    required this.onFacilitySelected,
    required this.existingFacilities,
  });

  @override
  ConsumerState<FacilitySelectionDialog> createState() => _FacilitySelectionDialogState();
}

class _FacilitySelectionDialogState extends ConsumerState<FacilitySelectionDialog> {
  final TextEditingController _textEditingController = TextEditingController();
  String? _selectedFacility;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Fasilitas'),
      content: SizedBox(
        width: double.maxFinite,
        child: TypeAheadField<String>(
          controller: _textEditingController,
          builder: (context, controller, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Cari atau tambahkan fasilitas baru",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppPallete.neutralColor.shade200),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedFacility = value.isEmpty ? null : value;
                });
              },
            );
          },
          suggestionsCallback: (pattern) async {
            if (pattern.isEmpty) {
              return const <String>[];
            }

            try {
              final suggestions = await ref.read(getFacilitiesSuggestionProvider(pattern).future);
              return suggestions
                  .where((facility) => !widget.existingFacilities.contains(facility))
                  .toList();
            } catch (e) {
              return const <String>[];
            }
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              dense: true,
              title: Text(suggestion),
            );
          },
          onSelected: (suggestion) {
            _textEditingController.text = suggestion;
            setState(() {
              _selectedFacility = suggestion;
            });
          },
          hideOnLoading: true,
          hideOnEmpty: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.pop();
          },
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            final facility = _selectedFacility ?? _textEditingController.text;
            if (facility.isNotEmpty) {
              widget.onFacilitySelected(facility);
            }
            context.pop();
          },
          child: const Text('Tambah'),
        ),
      ],
    );
  }
}
