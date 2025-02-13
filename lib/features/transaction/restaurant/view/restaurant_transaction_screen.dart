import 'package:flutter/material.dart';

class RestaurantTransactionScreen extends StatelessWidget {
  const RestaurantTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: TabBar(
                      tabs: [
                        Tab(icon: Icon(Icons.directions_car)),
                        Tab(icon: Icon(Icons.directions_transit)),
                        Tab(icon: Icon(Icons.directions_bike)),
                      ],
                    ),
                  ),
                )
              ];
            },
            body: TabBarView(
              children: [
                CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: CarouselView(
                        itemExtent: 150,
                        itemSnapping: true,
                        elevation: 2,
                        scrollDirection: Axis.horizontal,
                        reverse: false,
                        onTap: (int value) {
                          print('item tapped $value');
                        },
                        children: List.generate(20, (int index) {
                          return Container(
                            color: Colors.red,
                            child: Center(child: Text(index.toString())),
                          );
                        })),
                  ),
                )
              ],
            ),
                Container(color: Colors.blue),
                Container(color: Colors.green),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
