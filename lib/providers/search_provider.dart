import 'package:the_pyrometer_forge/models/project_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchNotifier extends ChangeNotifier {
  String searchQuery = '';

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    searchQuery = '';
    notifyListeners();
  }

  List<ThermalInstrumentModel> filteredList(
      List<ThermalInstrumentModel> list) {
    if (searchQuery.isEmpty) {
      return list;
    } else {
      final query = searchQuery.toLowerCase();
      return list
          .where((item) =>
              item.thermalRegistryHash.toLowerCase().contains(query) ||
              item.makerDisplay.toLowerCase().contains(query) ||
              item.pyrometricClassification.label.toLowerCase().contains(query) ||
              item.provenanceDisplay.toLowerCase().contains(query) ||
              item.notes.toLowerCase().contains(query) ||
              item.tags.any((tag) => tag.toLowerCase().contains(query)))
          .toList();
    }
  }
}

final searchProvider = ChangeNotifierProvider((ref) => SearchNotifier());
