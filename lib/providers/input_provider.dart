import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_pyrometer_forge/enum/my_enums.dart';

class InputNotifier extends ChangeNotifier {
  String _thermalRegistryHash = '';
  PyrometricClassification _pyrometricClassification =
      PyrometricClassification.vanishingFilamentOptical;
  MakerSign _makerSign = MakerSign.other;
  String _makerCustom = '';
  int _minTemperature = 0;
  int _maxTemperature = 100;
  String _temperatureUnit = '°C';
  EmissivityFactor _emissivityFactor = EmissivityFactor.blackbody;
  ThermocoupleAlloy _thermocoupleAlloy = ThermocoupleAlloy.notApplicable;
  String _opticalWavebandFilter = '';
  String _expansionCoefficientVariables = '';
  String _deformationEndpointScale = '';
  String _auxiliaryPowerImpedance = '';
  String _enclosureVolumetrics = '';
  String _mass = '';
  OpticalIntegrity _opticalIntegrity = OpticalIntegrity.pristine;
  MechanicalContinuity _electricalContinuity = MechanicalContinuity.untested;
  FoundryProvenance _foundryProvenance = FoundryProvenance.other;
  String _foundryProvenanceCustom = '';
  String _notes = '';
  String _photoPath = '';
  List<String> _tags = [];
  DateTime _dateAdded = DateTime.now();

  String get thermalRegistryHash => _thermalRegistryHash;
  PyrometricClassification get pyrometricClassification =>
      _pyrometricClassification;
  MakerSign get makerSign => _makerSign;
  String get makerCustom => _makerCustom;
  int get minTemperature => _minTemperature;
  int get maxTemperature => _maxTemperature;
  String get temperatureUnit => _temperatureUnit;
  EmissivityFactor get emissivityFactor => _emissivityFactor;
  ThermocoupleAlloy get thermocoupleAlloy => _thermocoupleAlloy;
  String get opticalWavebandFilter => _opticalWavebandFilter;
  String get expansionCoefficientVariables =>
      _expansionCoefficientVariables;
  String get deformationEndpointScale => _deformationEndpointScale;
  String get auxiliaryPowerImpedance => _auxiliaryPowerImpedance;
  String get enclosureVolumetrics => _enclosureVolumetrics;
  String get mass => _mass;
  OpticalIntegrity get opticalIntegrity => _opticalIntegrity;
  MechanicalContinuity get electricalContinuity => _electricalContinuity;
  FoundryProvenance get foundryProvenance => _foundryProvenance;
  String get foundryProvenanceCustom => _foundryProvenanceCustom;
  String get notes => _notes;
  String get photoPath => _photoPath;
  List<String> get tags => _tags;
  DateTime get dateAdded => _dateAdded;

  set thermalRegistryHash(String v) {
    _thermalRegistryHash = v;
    notifyListeners();
  }
  set pyrometricClassification(PyrometricClassification v) {
    _pyrometricClassification = v;
    notifyListeners();
  }
  set makerSign(MakerSign v) {
    _makerSign = v;
    notifyListeners();
  }
  set makerCustom(String v) {
    _makerCustom = v;
    notifyListeners();
  }
  set minTemperature(int v) {
    _minTemperature = v;
    notifyListeners();
  }
  set maxTemperature(int v) {
    _maxTemperature = v;
    notifyListeners();
  }
  set temperatureUnit(String v) {
    _temperatureUnit = v;
    notifyListeners();
  }
  set emissivityFactor(EmissivityFactor v) {
    _emissivityFactor = v;
    notifyListeners();
  }
  set thermocoupleAlloy(ThermocoupleAlloy v) {
    _thermocoupleAlloy = v;
    notifyListeners();
  }
  set opticalWavebandFilter(String v) {
    _opticalWavebandFilter = v;
    notifyListeners();
  }
  set expansionCoefficientVariables(String v) {
    _expansionCoefficientVariables = v;
    notifyListeners();
  }
  set deformationEndpointScale(String v) {
    _deformationEndpointScale = v;
    notifyListeners();
  }
  set auxiliaryPowerImpedance(String v) {
    _auxiliaryPowerImpedance = v;
    notifyListeners();
  }
  set enclosureVolumetrics(String v) {
    _enclosureVolumetrics = v;
    notifyListeners();
  }
  set mass(String v) {
    _mass = v;
    notifyListeners();
  }
  set opticalIntegrity(OpticalIntegrity v) {
    _opticalIntegrity = v;
    notifyListeners();
  }
  set electricalContinuity(MechanicalContinuity v) {
    _electricalContinuity = v;
    notifyListeners();
  }
  set foundryProvenance(FoundryProvenance v) {
    _foundryProvenance = v;
    notifyListeners();
  }
  set foundryProvenanceCustom(String v) {
    _foundryProvenanceCustom = v;
    notifyListeners();
  }
  set notes(String v) {
    _notes = v;
    notifyListeners();
  }
  set photoPath(String v) {
    _photoPath = v;
    notifyListeners();
  }
  set tags(List<String> v) {
    _tags = v;
    notifyListeners();
  }
  set dateAdded(DateTime v) {
    _dateAdded = v;
    notifyListeners();
  }

  void clearAll() {
    _thermalRegistryHash = '';
    _pyrometricClassification =
        PyrometricClassification.vanishingFilamentOptical;
    _makerSign = MakerSign.other;
    _makerCustom = '';
    _minTemperature = 0;
    _maxTemperature = 100;
    _temperatureUnit = '°C';
    _emissivityFactor = EmissivityFactor.blackbody;
    _thermocoupleAlloy = ThermocoupleAlloy.notApplicable;
    _opticalWavebandFilter = '';
    _expansionCoefficientVariables = '';
    _deformationEndpointScale = '';
    _auxiliaryPowerImpedance = '';
    _enclosureVolumetrics = '';
    _mass = '';
    _opticalIntegrity = OpticalIntegrity.pristine;
    _electricalContinuity = MechanicalContinuity.untested;
    _foundryProvenance = FoundryProvenance.other;
    _foundryProvenanceCustom = '';
    _notes = '';
    _photoPath = '';
    _tags = [];
    _dateAdded = DateTime.now();
    notifyListeners();
  }
}

final inputProvider = ChangeNotifierProvider<InputNotifier>(
  (ref) => InputNotifier(),
);
