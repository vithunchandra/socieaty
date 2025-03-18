import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'search_local_repository.g.dart';

@Riverpod(keepAlive: true)
SearchLocalRepository searchLocalRepository(Ref ref) {
  final repository = SearchLocalRepository();
  repository.init();
  return repository;
}

class SearchLocalRepository {
  SharedPreferences? _sharedPreferences;
  static const String recentSearchesKey = "recent_searches";
  static const int maxRecentSearches = 10;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      _sharedPreferences = await SharedPreferences.getInstance();
      _initialized = true;
    } catch (e) {
      // Handle initialization error
      debugPrint('Error initializing SharedPreferences: $e');
    }
  }

  Future<bool> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
    return _initialized && _sharedPreferences != null;
  }

  Future<void> addRecentSearch(String searchTerm) async {
    if (searchTerm.isEmpty) return;
    if (!await _ensureInitialized()) return;

    List<String> recentSearches = await getRecentSearches();

    // Remove the search term if it already exists (to avoid duplicates)
    recentSearches.removeWhere((term) => term.toLowerCase() == searchTerm.toLowerCase());

    // Add the new search term at the beginning of the list
    recentSearches.insert(0, searchTerm);

    // Limit the number of recent searches to maxRecentSearches
    if (recentSearches.length > maxRecentSearches) {
      recentSearches = recentSearches.sublist(0, maxRecentSearches);
    }

    await _sharedPreferences!.setStringList(recentSearchesKey, recentSearches);
  }

  Future<List<String>> getRecentSearches() async {
    if (!await _ensureInitialized()) return [];
    return _sharedPreferences!.getStringList(recentSearchesKey) ?? [];
  }

  Future<void> removeRecentSearch(String searchTerm) async {
    if (!await _ensureInitialized()) return;

    List<String> recentSearches = await getRecentSearches();
    recentSearches.removeWhere((term) => term.toLowerCase() == searchTerm.toLowerCase());
    await _sharedPreferences!.setStringList(recentSearchesKey, recentSearches);
  }

  Future<bool> clearRecentSearches() async {
    if (!await _ensureInitialized()) return false;
    return await _sharedPreferences!.remove(recentSearchesKey);
  }
}
