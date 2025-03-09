import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/features/transaction/customer/socket/customer_socket_service.dart';
import 'package:socieaty/features/home/customer/provider/all_post_provider.dart';
import 'package:socieaty/features/post/post/view/posts_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerSocketServiceProvider).initConnection();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            PostsWidget(),
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
                    IconButton(
                      onPressed: () {
                        ref.invalidate(allPostProvider);
                      },
                      icon: Icon(Icons.live_tv),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
