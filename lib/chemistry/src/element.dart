part of chemistry;

/// A class representing a chemical element.
class Element extends ChemicalElement with CompoundUnit {
  /// The state of this element.
  Phase state;

  /// A Boolean value that represents whether or not this element is a metal.
  bool metal;

  /// The charge of this element.
  int charge;

  /// The number of atoms this element needs to have in order to be stable.
  int count;

  /// The number of this element in the periodic table.
  int number;

  /// Constructs an element with the symbol [symbol] and charge [_charge].
  ///
  /// ```dart
  /// Element e = new Element('Ca');
  /// Element f = new Element('Fe', 3);
  /// ```
  Element(String symbol, [int _charge]) {
    for (ChemicalElement e in periodicTable) {
      if (e.symbol.compareTo(symbol) == 0) {
        this.name = e.name;
        this.formula = e.symbol;
        this.category = e.category;
        this.state = mPhaseToPhase[e.stpPhase];
        this.number = e.number;
        this.shells = e.shells;
        break;
      }
    }
    if (this.category.contains('metal'))
      this.metal = !(this.category.contains('nonmetal'));
    else
      this.metal = false;
    if (this.category.contains('diatomic'))
      this.count = 2;
    else if (this.formula.compareTo('P') == 0)
      this.count = 4;
    else if (this.formula.compareTo('S') == 0)
      this.count = 8;
    else
      this.count = 1;
    if (this.equals('H'))
      this.charge = 1;
    else if (_charge == null) {
      int valence = this.shells[this.shells.length - 1];
      if (valence < 5)
        this.charge = valence;
      else
        this.charge = valence - 8;
    } else
      this.charge = _charge;
  }

  /// Returns the String representation of this element.
  @override
  String toString() {
    String result = this.formula;
    if (this.count != 1) result += changeScript[this.count.toString()][1];
    result += phaseToString[this.state];
    return result;
  }

  /// Returns `true` if this element's formula is [symbol].
  ///
  /// ```dart
  /// Element e = new Element('H');
  /// print(e.equals('H')); // true
  /// print(e.equals('Ca')); // false
  /// ```
  @override
  bool equals(String symbol) {
    return this.formula.compareTo(symbol) == 0;
  }

  /// Returns the name of this element.
  String getName() {
    return this.name;
  }

  /// Returns `true` if an element with the symbol [symbol] exists.
  ///
  /// ```dart
  /// print(Element.exists('Na')); // true
  /// print(Element.exists('Rr')); // false
  /// ```
  static bool exists(String symbol) {
    for (ChemicalElement e in periodicTable) {
      if (e.symbol.compareTo(symbol) == 0) return true;
    }
    return false;
  }
}
