enum PyrometricClassification {
  vanishingFilamentOptical('Vanishing-Filament Optical'),
  totalRadiationDisplaced('Total Radiation Displaced'),
  biMetallicLinearExpansion('Bi-Metallic Linear Expansion'),
  thermoElectricDissimilar('Thermoelectric Dissimilar-Metal Junction'),
  liquidExpansionCapillary('Liquid-Expansion Capillary');

  const PyrometricClassification(this.label);
  final String label;
}

enum MakerSign {
  leedsNorthrup('Leeds & Northrup Co.'),
  brownInstrument('Brown Instrument Co.'),
  cambridgeScientific('Cambridge Scientific Instrument Co.'),
  thwingAlbert('Thwing-Albert'),
  honeywell('Honeywell'),
  taylorInstrument('Taylor Instrument Co.'),
  bristol('Bristol Co.'),
  foxboro('Foxboro'),
  weston('Weston Electrical'),
  landPyrometers('Land Pyrometers Ltd.'),
  siemens('Siemens'),
  pyroOptical('Pyro-Optical Works'),
  other('Other / Custom');

  const MakerSign(this.label);
  final String label;
}

enum EmissivityFactor {
  liquidSteel(0.28, 'Liquid Steel'),
  roughRefractories(0.80, 'Rough Refractories'),
  blackbody(1.00, 'Blackbody Calibration'),
  moltenCopper(0.15, 'Molten Copper'),
  castIron(0.37, 'Cast Iron'),
  moltenGlass(0.40, 'Molten Glass'),
  ceramic(0.75, 'Ceramic Body');

  const EmissivityFactor(this.value, this.label);
  final double value;
  final String label;
}

enum ThermocoupleAlloy {
  typeS('Type S — Pt/Pt-Rh', 'Platinum/Platinum-Rhodium'),
  typeK('Type K — Chromel/Alumel', 'Chromel/Alumel'),
  typeJ('Type J — Iron/Constantan', 'Iron/Constantan'),
  typeT('Type T — Copper/Constantan', 'Copper/Constantan'),
  typeE('Type E — Chromel/Constantan', 'Chromel/Constantan'),
  typeR('Type R — Pt/Pt-13Rh', 'Platinum/Platinum-13%Rhodium'),
  typeB('Type B — Pt-6Rh/Pt-30Rh', 'Platinum-6%Rhodium/Platinum-30%Rhodium'),
  notApplicable('N/A — Not Thermocouple', 'Not Applicable');

  const ThermocoupleAlloy(this.label, this.fullName);
  final String label;
  final String fullName;
}

enum OpticalIntegrity {
  pristine('Pristine'),
  pitted('Pitted'),
  calciteFogged('Calcite-Fogged'),
  scratched('Scratched'),
  hazy('Hazy / Clouded'),
  cracked('Cracked'),
  missing('Missing / Broken');

  const OpticalIntegrity(this.label);
  final String label;
}

enum MechanicalContinuity {
  verified('Verified — Operational'),
  openCircuit('Open Circuit — Failed'),
  intermittent('Intermittent / Unstable'),
  untested('Untested'),
  notApplicable('N/A — Mechanical Only');

  const MechanicalContinuity(this.label);
  final String label;
}

enum TemperatureBand {
  low('Low Heat', 0, 500),
  medium('Medium', 500, 1000),
  high('High', 1000, 1400),
  extreme('Extreme', 1400, 9999);

  const TemperatureBand(this.label, this.min, this.max);
  final String label;
  final int min;
  final int max;

  bool contains(int temp) => temp >= min && temp < max;
}

enum FoundryProvenance {
  homesteadSteel('Homestead Steel Works'),
  bethlehemSteel('Bethlehem Steel'),
  kruppEssen('Krupp Essen'),
  wedgwood('Wedgwood Potteries'),
  usSteel('U.S. Steel — Gary Works'),
  carnegie('Carnegie Steel'),
  britishSteel('British Steel Corporation'),
  sheffield('Sheffield Steel'),
  pittsburgh('Pittsburgh Carnegie'),
  ohioPottery('Historic Ohio Pottery Kiln'),
  navalShipyard('Naval Shipyard Forge'),
  other('Other / Unknown');

  const FoundryProvenance(this.label);
  final String label;
}
