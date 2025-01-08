import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/features/home/customer/provider/all_post_provider.dart';
import 'package:socieaty/features/post/post/view/post_view.dart';
import 'package:socieaty/shared/widgets/loading_indicator.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(allPostProvider).when(
      data: (posts) {
        return SafeArea(
          child: Scaffold(
            body: Stack(
              children: [
                PostView(),
                // Top Bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        TextButton(onPressed: () {}, child: Text("FYP")),
                        TextButton(onPressed: () {}, child: Text("Customer")),
                        TextButton(onPressed: () {}, child: Text("Restaurant")),
                        Expanded(child: SizedBox()),
                        IconButton(onPressed: () {}, icon: Icon(Icons.live_tv))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      error: (error, stacktrace) {
        debugPrint(stacktrace.toString());
        return SafeArea(child: Center(child: Text(error.toString())));
      },
      loading: () {
        return SafeArea(
          child: LoadingIndicator(),
        );
      },
    );
  }
}
