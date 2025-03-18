import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/restaurant/viewstate/create_reservation_config_form_state.dart';
import 'package:socieaty/shared/widgets/custom_text_field.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class CreateReservationConfigScreen extends ConsumerStatefulWidget {
  const CreateReservationConfigScreen({super.key});

  @override
  CreateReservationConfigScreenState createState() => CreateReservationConfigScreenState();
}

class CreateReservationConfigScreenState extends ConsumerState<CreateReservationConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _facilityController = TextEditingController();
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

  void _addFacility() {
    if (_facilityController.text.isNotEmpty) {
      setState(() {
        _facilities.add(_facilityController.text);
        _facilityController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = false;

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
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _facilityController,
                      prefixIcon: const Icon(Icons.chair),
                      hintText: "Add facility (e.g., WiFi, Parking)",
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addFacility,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: AppPallete.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _facilities
                    .map((facility) => Chip(
                          label: Text(facility),
                          onDeleted: () {
                            setState(() {
                              _facilities.remove(facility);
                            });
                          },
                        ))
                    .toList(),
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
                            // ref
                            //     .read(createReservationConfigViewModelProvider.notifier)
                            //     .createReservationConfig(_formData);
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
