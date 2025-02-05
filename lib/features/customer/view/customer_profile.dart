import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/features/customer/viewmodel/customer_profile_viewmodel.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class CustomerProfile extends ConsumerStatefulWidget {
  const CustomerProfile({super.key});

  @override
  ConsumerState<CustomerProfile> createState() => _CustomerProfileState();
}

class _CustomerProfileState extends ConsumerState<CustomerProfile> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ref.watch(getCustomerProfileProvider).when(
          data: (data) {
            return Text(data.name);
          },
          error: (error, stackTrace) {
            return Text(stackTrace.toString());
          },
          loading: () {
            return LoadingIndicatorWidget();
          },
        ),
      ),
    );
  }
}
