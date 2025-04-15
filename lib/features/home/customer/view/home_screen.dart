import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/features/home/customer/provider/all_post_provider.dart';
import 'package:socieaty/features/post/post/repository/request/paginate_post_query.dart';
import 'package:socieaty/features/post/post/view/posts_widget.dart';
import 'package:socieaty/shared/models/pagination_query.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PageController _pageController;
  late PaginatePostQuery _postPaginateQuery;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
    _pageController = PageController();
    _postPaginateQuery = PaginatePostQuery(
      paginationQuery: PaginationQuery(page: 0, pageSize: 5),
    );
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
            PostsWidget(
              key: Key(_postPaginateQuery.hashCode.toString()),
              initialQuery: _postPaginateQuery,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          setState(() {
                            _postPaginateQuery = PaginatePostQuery(
                              paginationQuery: PaginationQuery(page: 0, pageSize: 5),
                            );
                          });
                        },
                        child: Text("FYP")),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            _postPaginateQuery = PaginatePostQuery(
                              paginationQuery: PaginationQuery(page: 0, pageSize: 5),
                              userRole: UserRole.customer,
                            );
                          });
                        },
                        child: Text("Customer")),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            _postPaginateQuery = PaginatePostQuery(
                              paginationQuery: PaginationQuery(page: 0, pageSize: 5),
                              userRole: UserRole.restaurant,
                            );
                          });
                        },
                        child: Text("Restaurant")),
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
