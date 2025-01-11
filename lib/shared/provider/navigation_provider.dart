import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_provider.g.dart';

@riverpod
class NavigationIndex extends _$NavigationIndex {
  @override
  List<int> build() {
    return [0];
  }

  void addIndex(int index) {
    state = [...state, index];
  }

  void removeLastIndex() {
    state = state.sublist(0, state.length - 1);
  }
}
