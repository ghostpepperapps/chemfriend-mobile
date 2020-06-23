part of chemistry;

/// A class representing a chemical element.
class Element extends ChemicalElement with CompoundUnit {
  /// The state of this element.
  MatterPhase state;

  /// A Boolean value that represents whether or not this element is a metal.
  bool metal;

  /// The charge of this element.
  int charge;

  /// The number of atoms this element needs to have in order to be stable.
  int count;

  /// The number of this element in the periodic table.
  int number;

  /// Constructs an element from the properties of [other].
  Element.clone(ChemicalElement other) {
    this.name = other.name;
    this.formula = other.symbol;
    this.category = other.category;
    this.state = other.stpPhase;
    this.number = other.number;
    this.shells = other.shells;
  }

  /// Returns the String representation of this element.
  @override
  String toString() {
    String result = this.formula;
    if (this.count != 1) result += changeScript[this.count.toString()][1];
    result += ePhaseToString[this.state];
    return result;
  }

  /// Returns `true` if this element's formula is [symbol].
  ///
  /// ```dart
  /// Element e = Element.from('H');
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

  /// Returns an element with the symbol [symbol] and charge [_charge].
  ///
  /// ```dart
  /// Element e = Element.from('Ca');
  /// Element f = Element.from('Fe', 3);
  /// ```
  static Element from(String symbol, [int _charge]) {
    Element result;
    for (ChemicalElement e in periodicTable) {
      if (e.symbol.compareTo(symbol) == 0) {
        result = Element.clone(e);
        break;
      }
    }
    if (result.category.contains('metal'))
      result.metal = !(result.category.contains('nonmetal'));
    else
      result.metal = false;
    if (result.category.contains('diatomic'))
      result.count = 2;
    else if (result.formula.compareTo('P') == 0)
      result.count = 4;
    else if (result.formula.compareTo('S') == 0)
      result.count = 8;
    else
      result.count = 1;
    if (result.equals('H'))
      result.charge = 1;
    else if (_charge == null) {
      int valence = result.shells[result.shells.length - 1];
      if (valence < 5)
        result.charge = valence;
      else
        result.charge = valence - 8;
    } else
      result.charge = _charge;
    return result;
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
