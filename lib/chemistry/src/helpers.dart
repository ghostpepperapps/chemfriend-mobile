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
  Type.doubleReplacement: 'Double Replacement'
};

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
