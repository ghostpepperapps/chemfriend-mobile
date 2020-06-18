part of chemistry;

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

Map<MatterPhase, String> phaseToString = {
  MatterPhase.solid: '\u208D\u209b\u208E',
  MatterPhase.liquid: '\u208D\u2097\u208E',
  MatterPhase.gas: '\u208D\u1d67\u208E',
};

Map<Phase, String> stateToString = {
  Phase.solid: '\u208D\u209b\u208E',
  Phase.liquid: '\u208D\u2097\u208E',
  Phase.gas: '\u208D\u1d67\u208E',
  Phase.aqueous: '\u208D\u2090\u208E'
};

Map typeToString = {
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

bool isNumeric(String s) => double.tryParse(s) != null;

int lcm(int a, int b) => (a * b) ~/ gcd(a, b);

int gcd(int a, int b) {
  while (b != 0) {
    var t = b;
    b = a % t;
    a = t;
  }
  return a;
}
