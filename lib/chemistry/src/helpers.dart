part of chemistry;

/// Maps MatterPhases to their Phase variants.
///
/// MatterPhases are used in ChemicalElements and Phases are used in Elements
/// and Compounds.
Map<MatterPhase, Phase> mPhaseToPhase = {
  MatterPhase.solid: Phase.solid,
  MatterPhase.liquid: Phase.liquid,
  MatterPhase.gas: Phase.gas,
};

/// Maps characters to their superscript and subscript variants.
Map<String, List<String>> changeScript = {
  '0': ['\u2070', '\u2080'],
  '1': ['\u00B9', '\u2081'],
  '2': ['\u00B2', '\u2082'],
  '3': ['\u00B3', '\u2083'],
  '4': ['\u2074', '\u2084'],
  '5': ['\u2075', '\u2085'],
  '6': ['\u2076', '\u2086'],
  '7': ['\u2077', '\u2087'],
  '8': ['\u2078', '\u2088'],
  '9': ['\u2079', '\u2089'],
  's': ['\u02e2', '\u209b'],
  'l': ['\u02e1', '\u2097'],
  'g': ['\u1d4d', '?'],
  'a': ['\u1d43', '\u2090'],
  'q': ['?', '?'],
  '(': ['\u207D', '\u208D'],
  ')': ['\u207E', '\u208E'],
};

/// Maps Phases to their String variants.
Map<Phase, String> phaseToString = {
  Phase.solid: '(s)',
  Phase.liquid: '(l)',
  Phase.gas: '(g)',
  Phase.aqueous: '(aq)'
};

/// Maps Types (for Equations) to their String variants.
Map<Type, String> typeToString = {
  Type.comp: 'Simple Composition',
  Type.compAcid: 'Composition of an Acid',
  Type.compBase: 'Composition of a Base',
  Type.compSalt: 'Composition of a Salt',
  Type.decomp: 'Simple Decomposition',
  Type.decompAcid: 'Decomposition of an Acid',
  Type.decompBase: 'Decomposition of a Base',
  Type.decompSalt: 'Decomposition of a Salt',
  Type.combustion: 'Hydrocarbon Combustion',
  Type.singleReplacement: 'Single Replacement',
  Type.doubleReplacement: 'Double Replacement',
  Type.neutralization: 'Double Replacement (Neutralization)'
};

/// Maps ions to ions they combine with to become solid in water.
Map<List<String>, List<String>> ionToSolid = {
  [
    'H',
    'Li',
    'Na',
    'K',
    'Rb',
    'Cs',
    'Fr',
    'NH4',
    'NO3',
    'ClO3',
    'ClO4',
    'CH3COO'
  ]: [],
  ['F']: ['Li', 'Mg', 'Ca', 'Sr', 'Ba', 'Fe2+', 'Hg22+', 'Pb2+'],
  ['Cl', 'Br', 'I']: ['Cu+', 'Ag', 'Hg22+', 'Pb2+', 'Tl+'],
  ['SO4']: ['Ca', 'Sr', 'Ba', 'Ag', 'Hg22+', 'Pb2+', 'Ra']
};

/// Maps ions to ions they combine with to become aqueous in water.
Map<List<String>, List<String>> ionToAqueous = {
  ['CO3', 'PO4', 'SO3']: ['H', 'Li', 'Na', 'K', 'Rb', 'Cs', 'Fr', 'NH4'],
  ['IO3', 'OOCCOO']: ['H', 'Li', 'Na', 'K', 'Rb', 'Cs', 'Fr', 'NH4'],
  ['OH']: ['H', 'Li', 'Na', 'K', 'Rb', 'Cs', 'Fr', 'NH4']
};

/// List of formulas of compounds that are solid in water.
List<String> solidCompounds = [
  'RbClO4',
  'CsClO4',
  'AgCH3COO',
  'Hg2(CH3COO)2'
];

/// List of formulas of compounds that are aqueous in water.
List<String> aqueousCompounds = ['Co(IO3)2', 'Fe2(OOCCOO)3'];

/// Returns `true` if [c] is `Hg₂2+`.
bool isHg22plus(MapEntry<CompoundUnit, int> c) {
  return c.key.equals('Hg') && c.value == 2 && c.key.charge == 2;
}

/// Returns `true` if [s] contains a number.
bool isNumeric(String s) => double.tryParse(s) != null;

/// Returns the least common multiple of [a] and [b].
int lcm(int a, int b) => (a * b) ~/ gcd(a, b);

/// Returns the greatest common divisor of [a] and [b].
int gcd(int a, int b) {
  while (b != 0) {
    var t = b;
    b = a % t;
    a = t;
  }
  return a;
}
