import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:the_pyrometer_forge/enum/my_enums.dart';
import 'package:the_pyrometer_forge/models/project_model.dart';
import 'package:the_pyrometer_forge/providers/image_provider.dart';
import 'package:the_pyrometer_forge/providers/input_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ProjectNotifier extends ChangeNotifier {
  ProjectNotifier() {
    loadEntries();
  }

  List<ThermalInstrumentModel> entries = [];
  bool isLoading = true;
  int stateVersion = 0;
  static const String _storageKey = 'tpf_entries_v1';
  final _uuid = const Uuid();

  Future<void> loadEntries() async {
    isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> decodedList = jsonDecode(jsonString);
        entries = decodedList
            .map((item) => ThermalInstrumentModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading entries: $e');
      entries = [];
    } finally {
      isLoading = false;
      stateVersion++;
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(
      entries.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encodedList);
  }

  String _generateHash(
      MakerSign maker, String makerCustom, PyrometricClassification classification,
      [String? suffix]) {
    final makerCode = maker == MakerSign.other && makerCustom.isNotEmpty
        ? makerCustom.substring(0, 2).toUpperCase()
        : maker.name.substring(0, 2).toUpperCase();
    final classCode = classification.name;
    final year = DateTime.now().year.toString();
    final rand = suffix ?? _uuid.v4().substring(0, 4).toUpperCase();
    return 'TPF-$makerCode-$classCode-$year-$rand';
  }

  void addEntry(WidgetRef ref) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);

    entries.add(
      ThermalInstrumentModel(
        id: _uuid.v4(),
        thermalRegistryHash: p.thermalRegistryHash.isNotEmpty
            ? p.thermalRegistryHash
            : _generateHash(p.makerSign, p.makerCustom, p.pyrometricClassification),
        pyrometricClassification: p.pyrometricClassification,
        makerSign: p.makerSign,
        makerCustom: p.makerCustom,
        minTemperature: p.minTemperature,
        maxTemperature: p.maxTemperature,
        temperatureUnit: p.temperatureUnit,
        emissivityFactor: p.emissivityFactor,
        thermocoupleAlloy: p.thermocoupleAlloy,
        opticalWavebandFilter: p.opticalWavebandFilter,
        expansionCoefficientVariables: p.expansionCoefficientVariables,
        deformationEndpointScale: p.deformationEndpointScale,
        auxiliaryPowerImpedance: p.auxiliaryPowerImpedance,
        enclosureVolumetrics: p.enclosureVolumetrics,
        mass: p.mass,
        opticalIntegrity: p.opticalIntegrity,
        electricalContinuity: p.electricalContinuity,
        foundryProvenance: p.foundryProvenance,
        foundryProvenanceCustom: p.foundryProvenanceCustom,
        notes: p.notes,
        photoPath:
            imgProv.resultImage.isNotEmpty ? imgProv.resultImage : p.photoPath,
        tags: List<String>.from(p.tags),
        dateAdded: p.dateAdded,
      ),
    );

    _save();
    stateVersion++;
    notifyListeners();
  }

  void editEntry(WidgetRef ref, int index) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final existing = entries[index];

    entries[index] = ThermalInstrumentModel(
      id: existing.id,
      thermalRegistryHash: p.thermalRegistryHash.isNotEmpty
          ? p.thermalRegistryHash
          : existing.thermalRegistryHash,
      pyrometricClassification: p.pyrometricClassification,
      makerSign: p.makerSign,
      makerCustom: p.makerCustom,
      minTemperature: p.minTemperature,
      maxTemperature: p.maxTemperature,
      temperatureUnit: p.temperatureUnit,
      emissivityFactor: p.emissivityFactor,
      thermocoupleAlloy: p.thermocoupleAlloy,
      opticalWavebandFilter: p.opticalWavebandFilter,
      expansionCoefficientVariables: p.expansionCoefficientVariables,
      deformationEndpointScale: p.deformationEndpointScale,
      auxiliaryPowerImpedance: p.auxiliaryPowerImpedance,
      enclosureVolumetrics: p.enclosureVolumetrics,
      mass: p.mass,
      opticalIntegrity: p.opticalIntegrity,
      electricalContinuity: p.electricalContinuity,
      foundryProvenance: p.foundryProvenance,
      foundryProvenanceCustom: p.foundryProvenanceCustom,
      notes: p.notes,
      photoPath: imgProv.resultImage.isNotEmpty
          ? imgProv.resultImage
          : existing.photoPath,
      tags: List<String>.from(p.tags),
      dateAdded: existing.dateAdded,
    );

    _save();
    stateVersion++;
    notifyListeners();
  }

  void deleteEntry(int index) {
    entries.removeAt(index);
    _save();
    stateVersion++;
    notifyListeners();
  }

  void fillInput(WidgetRef ref, int index) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final entry = entries[index];

    p.thermalRegistryHash = entry.thermalRegistryHash;
    p.pyrometricClassification = entry.pyrometricClassification;
    p.makerSign = entry.makerSign;
    p.makerCustom = entry.makerCustom;
    p.minTemperature = entry.minTemperature;
    p.maxTemperature = entry.maxTemperature;
    p.temperatureUnit = entry.temperatureUnit;
    p.emissivityFactor = entry.emissivityFactor;
    p.thermocoupleAlloy = entry.thermocoupleAlloy;
    p.opticalWavebandFilter = entry.opticalWavebandFilter;
    p.expansionCoefficientVariables = entry.expansionCoefficientVariables;
    p.deformationEndpointScale = entry.deformationEndpointScale;
    p.auxiliaryPowerImpedance = entry.auxiliaryPowerImpedance;
    p.enclosureVolumetrics = entry.enclosureVolumetrics;
    p.mass = entry.mass;
    p.opticalIntegrity = entry.opticalIntegrity;
    p.electricalContinuity = entry.electricalContinuity;
    p.foundryProvenance = entry.foundryProvenance;
    p.foundryProvenanceCustom = entry.foundryProvenanceCustom;
    p.notes = entry.notes;
    p.photoPath = entry.photoPath;
    p.tags = List<String>.from(entry.tags);
    p.dateAdded = entry.dateAdded;

    imgProv.resultImage = entry.photoPath;

    notifyListeners();
  }
}

final projectProvider = ChangeNotifierProvider<ProjectNotifier>(
  (ref) => ProjectNotifier(),
);
