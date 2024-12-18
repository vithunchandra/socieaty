import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_provider.g.dart';

@riverpod
class NavigationIndex extends _$NavigationIndex {
  @override
  int build() {
    return 0;
  }

  void changeNavigationIndex(int index) {
    state = index;
  }
}
