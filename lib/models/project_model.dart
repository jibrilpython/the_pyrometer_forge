import 'package:the_pyrometer_forge/enum/my_enums.dart';

class ThermalInstrumentModel {
  String id;
  String thermalRegistryHash;
  PyrometricClassification pyrometricClassification;
  MakerSign makerSign;
  String makerCustom;
  int minTemperature;
  int maxTemperature;
  String temperatureUnit;
  EmissivityFactor emissivityFactor;
  ThermocoupleAlloy thermocoupleAlloy;
  String opticalWavebandFilter;
  String expansionCoefficientVariables;
  String deformationEndpointScale;
  String auxiliaryPowerImpedance;
  String enclosureVolumetrics;
  String mass;
  OpticalIntegrity opticalIntegrity;
  MechanicalContinuity electricalContinuity;
  FoundryProvenance foundryProvenance;
  String foundryProvenanceCustom;
  String notes;
  String photoPath;
  List<String> tags;
  DateTime dateAdded;

  ThermalInstrumentModel({
    required this.id,
    required this.thermalRegistryHash,
    required this.pyrometricClassification,
    required this.makerSign,
    required this.makerCustom,
    required this.minTemperature,
    required this.maxTemperature,
    required this.temperatureUnit,
    required this.emissivityFactor,
    required this.thermocoupleAlloy,
    required this.opticalWavebandFilter,
    required this.expansionCoefficientVariables,
    required this.deformationEndpointScale,
    required this.auxiliaryPowerImpedance,
    required this.enclosureVolumetrics,
    required this.mass,
    required this.opticalIntegrity,
    required this.electricalContinuity,
    required this.foundryProvenance,
    required this.foundryProvenanceCustom,
    required this.notes,
    required this.photoPath,
    required this.tags,
    required this.dateAdded,
  });

  int get temperatureSpan => maxTemperature - minTemperature;

  String get makerDisplay =>
      makerSign == MakerSign.other && makerCustom.isNotEmpty
          ? makerCustom
          : makerSign.label;

  String get provenanceDisplay =>
      foundryProvenance == FoundryProvenance.other &&
              foundryProvenanceCustom.isNotEmpty
          ? foundryProvenanceCustom
          : foundryProvenance.label;

  Map<String, dynamic> toJson() => {
        'id': id,
        'thermalRegistryHash': thermalRegistryHash,
        'pyrometricClassification': pyrometricClassification.name,
        'makerSign': makerSign.name,
        'makerCustom': makerCustom,
        'minTemperature': minTemperature,
        'maxTemperature': maxTemperature,
        'temperatureUnit': temperatureUnit,
        'emissivityFactor': emissivityFactor.name,
        'thermocoupleAlloy': thermocoupleAlloy.name,
        'opticalWavebandFilter': opticalWavebandFilter,
        'expansionCoefficientVariables': expansionCoefficientVariables,
        'deformationEndpointScale': deformationEndpointScale,
        'auxiliaryPowerImpedance': auxiliaryPowerImpedance,
        'enclosureVolumetrics': enclosureVolumetrics,
        'mass': mass,
        'opticalIntegrity': opticalIntegrity.name,
        'electricalContinuity': electricalContinuity.name,
        'foundryProvenance': foundryProvenance.name,
        'foundryProvenanceCustom': foundryProvenanceCustom,
        'notes': notes,
        'photoPath': photoPath,
        'tags': tags,
        'dateAdded': dateAdded.toIso8601String(),
      };

  factory ThermalInstrumentModel.fromJson(Map<String, dynamic> json) =>
      ThermalInstrumentModel(
        id: json['id'] ?? '',
        thermalRegistryHash: json['thermalRegistryHash'] ?? '',
        pyrometricClassification: PyrometricClassification.values
                .asNameMap()[json['pyrometricClassification']] ??
            PyrometricClassification.vanishingFilamentOptical,
        makerSign: MakerSign.values.asNameMap()[json['makerSign']] ??
            MakerSign.other,
        makerCustom: json['makerCustom'] ?? '',
        minTemperature: json['minTemperature'] ?? 0,
        maxTemperature: json['maxTemperature'] ?? 100,
        temperatureUnit: json['temperatureUnit'] ?? '°C',
        emissivityFactor:
            EmissivityFactor.values.asNameMap()[json['emissivityFactor']] ??
                EmissivityFactor.blackbody,
        thermocoupleAlloy:
            ThermocoupleAlloy.values.asNameMap()[json['thermocoupleAlloy']] ??
                ThermocoupleAlloy.notApplicable,
        opticalWavebandFilter: json['opticalWavebandFilter'] ?? '',
        expansionCoefficientVariables:
            json['expansionCoefficientVariables'] ?? '',
        deformationEndpointScale: json['deformationEndpointScale'] ?? '',
        auxiliaryPowerImpedance: json['auxiliaryPowerImpedance'] ?? '',
        enclosureVolumetrics: json['enclosureVolumetrics'] ?? '',
        mass: json['mass'] ?? '',
        opticalIntegrity:
            OpticalIntegrity.values.asNameMap()[json['opticalIntegrity']] ??
                OpticalIntegrity.pristine,
        electricalContinuity: MechanicalContinuity.values
                .asNameMap()[json['electricalContinuity']] ??
            MechanicalContinuity.untested,
        foundryProvenance:
            FoundryProvenance.values.asNameMap()[json['foundryProvenance']] ??
                FoundryProvenance.other,
        foundryProvenanceCustom: json['foundryProvenanceCustom'] ?? '',
        notes: json['notes'] ?? '',
        photoPath: json['photoPath'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
        dateAdded:
            DateTime.tryParse(json['dateAdded'] ?? '') ?? DateTime.now(),
      );
}
