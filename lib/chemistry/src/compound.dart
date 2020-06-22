part of chemistry;

/// Enum for each possible state of compounds.
enum Phase { solid, liquid, gas, aqueous }

/// A class that represents a chemical compound.
class Compound with CompoundUnit, EquationUnit {
  List<MapEntry<CompoundUnit, int>> compoundUnits;
  bool ionic;
  Phase state;
  String formula;
  int charge;

  /// Constructs a compound from its chemical [formula].
  Compound(String formula, {bool nested = false, int charge}) {
    this.formula = formula;
    this.charge = charge;
    compoundUnits = [];
    ionic = false;
    bool containsMetal = false;
    bool containsNonmetal = false;
    int i = 0;
    Element current;
    bool hasState = formula[formula.length - 1].compareTo(')') == 0;
    while (i <
        formula.length -
            (nested
                ? 0
                : hasState
                    ? formula[formula.length - 2].compareTo('q') == 0 ? 4 : 3
                    : 0)) {
      if (i == formula.length - 1) {
        current = Element.from(formula[i]);
        i++;
      } else if (formula[i].compareTo('(') != 0) {
        if (Element.exists(formula.substring(i, i + 2))) {
          current = Element.from(formula.substring(i, i + 2));
          i += 2;
        } else {
          current = Element.from(formula[i]);
          i++;
        }
      } else {
        int j = formula.indexOf(')', i);
        int k = j + 1;
        while (k < formula.length && isNumeric(formula[k])) k++;
        Compound c = Compound(formula.substring(i + 1, j), nested: true);
        if (k == j + 1)
          compoundUnits.add(MapEntry(c, 1));
        else
          compoundUnits
              .add(MapEntry(c, int.parse(formula.substring(j + 1, k))));
        for (MapEntry cu in c.compoundUnits) {
          if (cu.key.metal)
            containsMetal = true;
          else if (!cu.key.metal) containsNonmetal = true;
        }
        if (c.formula.compareTo('NH4') == 0) containsMetal = true;
        i = k;
        continue;
      }
      if (current.metal)
        containsMetal = true;
      else if (!current.metal) containsNonmetal = true;
      int j = i;
      while (j < formula.length && isNumeric(formula[j])) j++;
      if (i == j)
        compoundUnits.add(MapEntry(current, 1));
      else
        compoundUnits
            .add(MapEntry(current, int.parse(formula.substring(i, j))));
      current = null;
      i = j;
    }
    if (!nested && hasState) {
      switch (formula[formula.length - 2]) {
        case 's':
          this.state = Phase.solid;
          break;
        case 'l':
          this.state = Phase.liquid;
          break;
        case 'g':
          this.state = Phase.gas;
          break;
        case 'q':
          this.state = Phase.aqueous;
          break;
      }
    } else
      state = null;
    if (containsMetal && containsNonmetal) ionic = true;
    _multivalent();
  }

  /// Contructs a compound from its individual [units] and its [state].
  Compound.fromUnits(List<MapEntry<CompoundUnit, int>> units,
      [Phase state]) {
    this.compoundUnits = units;
    List<bool> temp = _ionicHelper(compoundUnits);
    ionic = temp[0] == true && temp[1] == true;
    this.state = state;
    _multivalent();
    formula = '';
    for (MapEntry<CompoundUnit, int> c in this.compoundUnits) {
      if (c.key.isElement())
        formula += c.key.formula;
      else
        formula += '(${c.key.formula})';
      if (c.value != 1) formula += c.value.toString();
    }
  }

  /// Helps determine whether or not the compound with [units] is ionic.
  List<bool> _ionicHelper(List<MapEntry<CompoundUnit, int>> units,
      [bool _containsMetal = false, bool _containsNonmetal = false]) {
    for (MapEntry c in units) {
      if (c.key.isElement()) {
        if (c.key.metal)
          _containsMetal = true;
        else
          _containsNonmetal = true;
      } else {
        List<bool> temp = _ionicHelper(
            c.key.compoundUnits, _containsMetal, _containsNonmetal);
        _containsMetal = temp[0];
        _containsNonmetal = temp[1];
      }
    }
    return [_containsMetal, _containsNonmetal];
  }

  /// Determines the charge of a multivalent metal if this compound is ionic.
  void _multivalent() {
    if (ionic) {
      CompoundUnit first = compoundUnits[0].key;
      if (first.isElement() && first.getCharge() == null) {
        int negative =
            compoundUnits[1].key.getCharge() * compoundUnits[1].value;
        compoundUnits[0].key.charge = -(negative ~/ compoundUnits[0].value);
      }
    }
  }

  /// Returns the String representation of this compound.
  @override
  String toString() {
    String result = '';
    for (MapEntry<CompoundUnit, int> c in this.compoundUnits) {
      if (c.key.isElement())
        result += c.key.formula;
      else {
        if (c.value != 1)
          result += '(${c.key.toString()})';
        else
          result += '${c.key.toString()}';
      }
      String intString = c.value.toString();
      String specialString = '';
      for (int i = 0; i < intString.length; i++)
        specialString += '${changeScript[intString[i]][1]}';
      if (c.value != 1) result += specialString;
    }
    if (this.state != null) result += cPhaseToString[this.state];
    return result;
  }

  /// Returns `true` if this element has the formula [formula].
  @override
  bool equals(String formula) {
    return this.formula.compareTo(formula) == 0;
  }

  /// Returns `true` if this compound contains [substance].
  bool contains(String substance) {
    return this.formula.contains(substance);
  }

  /// Returns `true` if this compound is an acid.
  ///
  /// Checks if the first element is `H` and the phase is `Phase.aqueous`.
  bool isAcid() {
    return this.compoundUnits[0].key.equals('H') &&
        this.state == Phase.aqueous;
  }

  /// Returns `true` is this compound is a base.
  ///
  /// Checks is this is ammonia (`NH3`), or is ionic and contains hydroxide
  /// (`OH`) or carbonate (`CO3`).
  bool isBase() {
    return this.equals('NH₃') ||
        (this.ionic && (this.contains('OH') || this.contains('CO₃')));
  }

  /// Prints the individual units of this compound.
  void printElements() {
    for (MapEntry c in compoundUnits) {
      if (c.key.isElement())
        print('${c.key.name}: ${c.value}');
      else
        print('${c.key.formula}: ${c.value}');
    }
  }

  /// Prints the formula, category, and state of this compound.
  void printInfo() {
    print('Compound: ${this.toString()}');
    print('Category: ${(ionic) ? 'Ionic' : 'Molecular'}');
    print(
        'State: ${(state == Phase.solid) ? 'Solid' : (state == Phase.liquid) ? 'Liquid' : (state == Phase.gas) ? 'Gas' : 'Aqueous'}');
  }
}
