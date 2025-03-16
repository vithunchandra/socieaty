import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/shop/customer/repository/search_local_repository.dart';

part 'recent_searches_provider.g.dart';

@riverpod
Future<List<String>> recentSearches(RecentSearchesRef ref) async {
  final repository = ref.watch(searchLocalRepositoryProvider);
  return await repository.getRecentSearches();
}

final recentSearchesControllerProvider = Provider((ref) {
  final repository = ref.watch(searchLocalRepositoryProvider);
  return RecentSearchesController(repository: repository);
});

class RecentSearchesController {
  final SearchLocalRepository repository;

  RecentSearchesController({required this.repository});

  Future<void> addSearch(String term) async {
    await repository.addRecentSearch(term);
  }

  Future<void> removeSearch(String term) async {
    await repository.removeRecentSearch(term);
  }

  Future<void> clearSearches() async {
    await repository.clearRecentSearches();
  }
}
