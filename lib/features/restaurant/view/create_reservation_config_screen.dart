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
import 'package:socieaty/features/restaurant/viewmodel/create_reservation_config_view_model.dart';
import 'package:socieaty/features/restaurant/viewstate/create_reservation_config_form_state.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/custom_text_field.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class CreateReservationConfigScreen extends ConsumerStatefulWidget {
  const CreateReservationConfigScreen({super.key});

  @override
  CreateReservationConfigScreenState createState() => CreateReservationConfigScreenState();
}

class CreateReservationConfigScreenState extends ConsumerState<CreateReservationConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _facilityController = TextEditingController();
  final List<String> _facilities = [];
  late CreateReservationConfigFormState _formData;

  @override
  void initState() {
    super.initState();
    _formData = const CreateReservationConfigFormState(
      maxPerson: 0,
      minCostPerPerson: 0,
      timeLimit: 0,
      facilities: [],
    );
  }

  @override
  void dispose() {
    _facilityController.dispose();
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
        .watch(createReservationConfigViewModelProvider)
        .createReservationConfigState is LoadingState;

    ref.listen(createReservationConfigViewModelProvider, (previous, next) {
      switch (next.createReservationConfigState) {
        case SuccessState<ReservationConfig>():
          final currentUser = ref.watch(authLocalRepositoryProvider).getUserData();
          if (currentUser != null) {
            ref.invalidate(getRestaurantReservationConfigProvider(currentUser.restaurantData!.id));
            context.pop();
            context.push('/restaurant/dashboard/reservation');
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
        title: const Text('Create Reservation Config'),
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
              Text("Maximum Person", style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8.0),
              CustomTextField(
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.people),
                hintText: "Enter maximum number of people",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Maximum person is required';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _formData = _formData.copyWith(maxPerson: int.parse(value!));
                },
              ),
              const SizedBox(height: 8),
              const Text("Maximum number of people allowed for reservation"),
              const SizedBox(height: 20),
              Text("Minimum Cost Per Person", style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8.0),
              CustomTextField(
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.attach_money),
                hintText: "Enter minimum cost per person",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Minimum cost is required';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _formData = _formData.copyWith(minCostPerPerson: int.parse(value!));
                },
              ),
              const SizedBox(height: 8),
              const Text("Minimum amount each person must spend"),
              const SizedBox(height: 20),
              Text("Time Limit (minutes)", style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8.0),
              CustomTextField(
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.timer),
                hintText: "Enter time limit in minutes",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Time limit is required';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _formData = _formData.copyWith(timeLimit: int.parse(value!));
                },
              ),
              const SizedBox(height: 8),
              const Text("Maximum time allowed for the reservation"),
              const SizedBox(height: 20),
              Text("Facilities", style: Theme.of(context).textTheme.titleSmall),
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
                              "Add Facility",
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
              const Text("List of facilities available for reservations"),
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
                                .read(createReservationConfigViewModelProvider.notifier)
                                .createReservationConfig(_formData);
                          }
                        },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: isLoading
                        ? const LoadingIndicatorWidget()
                        : const Text('Save Configuration'),
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
      title: const Text('Add Facility'),
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
                hintText: "Type to search or add new facility",
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
              debugPrint('Error fetching suggestions: $e');
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
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            // Use either the selected suggestion or the manually typed text
            final facility = _selectedFacility ?? _textEditingController.text;
            if (facility.isNotEmpty) {
              widget.onFacilitySelected(facility);
            }
            context.pop();
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
