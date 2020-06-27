part of chemistry;

/// Enum for each possible state of compounds.
enum Phase { solid, liquid, gas, aqueous }

/// A class that represents a chemical compound.
class Compound with CompoundUnit {
  /// A list of MapEntries that map each unit to the number of molecules
  /// present.
  List<MapEntry<CompoundUnit, int>> compoundUnits;

  /// A Boolean value that represents whether or not this compound is
  /// ionic.
  bool ionic;

  /// The state of this compound.
  Phase state;

  /// The chemical formula of this compound.
  String formula;

  /// The charge of this compound.
  int charge;

  /// Constructs a compound from its chemical [formula].
  ///
  /// ```dart
  /// Compound c = new Compound('H2O(l)');
  /// ```
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
        current = new Element(formula[i]);
        i++;
      } else if (formula[i].compareTo('(') != 0) {
        if (Element.exists(formula.substring(i, i + 2))) {
          current = new Element(formula.substring(i, i + 2));
          i += 2;
        } else {
          current = new Element(formula[i]);
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
    _commonIonCharge();
    _multivalent();
  }

  /// Contructs a compound from its individual [units] and its [state].
  ///
  /// ```dart
  /// List<MapEntry<CompoundUnit, int>> units = [
  ///   MapEntry(new Element('Na'), 2),
  ///   MapEntry(Compound('SO3'), 1)
  /// ];
  /// Compound c = Compound.fromUnits(units, Phase.solid);
  /// ```
  Compound.fromUnits(List<MapEntry<CompoundUnit, int>> units,
      [Phase state]) {
    this.compoundUnits = units;
    this.state = state;
    formula = '';
    for (MapEntry<CompoundUnit, int> c in this.compoundUnits) {
      if (c.key.isElement() || c.value == 1)
        formula += c.key.formula;
      else
        formula += '(${c.key.formula})';
      if (c.value != 1) formula += c.value.toString();
    }
    ionic = this.isIonic();
    _commonIonCharge();
    _multivalent();
  }

  /// Returns true if the compound with [units] is ionic.
  bool isIonic() {
    if (this.equals('H2O')) return false;
    bool _containsMetal = false;
    bool _containsNonmetal = false;
    for (MapEntry c in compoundUnits) {
      if (c.key.isElement()) {
        if (c.key.metal)
          _containsMetal = true;
        else
          _containsNonmetal = true;
      } else {
        if (c.key.getCharge() > 0)
          _containsMetal = true;
        else
          _containsNonmetal = true;
      }
    }
    return _containsMetal && _containsNonmetal;
  }

  /// Determines the charge of a multivalent metal if this compound is ionic.
  ///
  /// To do so, it uses the anion in the compound and assumes the compound is
  /// properly balanced.
  /// For example, to find the charge of `Fe` in `Fe₂(SO₃)₃`, the following
  /// process is used:
  ///
  /// 1. Charge of SO₃ = -2
  /// 2. ∴ Charge of (SO₃)₃ = -2 * 3 = -6
  /// 3. ∴ Charge of Fe₂ = -6 * -1 = 6
  /// 4. ∴ Charge of Fe = 6 / 2 = +3
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

  /// Determines the charge of this compound if it is a common ion.
  ///
  /// This uses the [commonIons] map of common polyatomic ions.
  void _commonIonCharge() {
    if (this.getCharge() == null) {
      if (commonIons.containsKey(this.formula)) {
        this.charge = commonIons[this.formula];
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
    if (this.state != null) result += phaseToString[this.state];
    return result;
  }

  /// Returns `true` if this element has the formula [formula].
  ///
  /// ```dart
  /// Compound c = new Compound('H2O(l)');
  /// print(c.equals('H2O2(l)')); // false
  /// print(c.equals('H2O(l)')); // true
  /// ```
  @override
  bool equals(String formula) {
    return this.formula.compareTo(formula) == 0;
  }

  /// Returns `true` if this compound contains [substance].
  ///
  /// ```dart
  /// Compound c = new Compound('H2O(l)');
  /// print(c.contains('H')); // true
  /// print(c.contains('Ca')); // false
  /// ```
  bool contains(String substance) {
    return this.formula.contains(substance);
  }

  /// Returns `true` if this compound is an acid.
  ///
  /// Checks if the first element is `H` and the phase is `Phase.aqueous`.
  /// ```dart
  /// Compound c = new Compound('H2O(l)');
  /// Compound d = new Compound('H2CO3(aq)');
  /// print(c.isAcid()); // false
  /// print(d.isAcid()); // true
  /// ```
  bool isAcid() {
    return this.compoundUnits[0].key.equals('H') &&
        this.state == Phase.aqueous;
  }

  /// Returns `true` is this compound is a base.
  ///
  /// Checks is this is ammonia (`NH3`), or is ionic and contains hydroxide
  /// (`OH`) or carbonate (`CO3`).
  /// ```dart
  /// Compound c = new Compound('H2O(l)');
  /// Compound d = new Compound('NaOH(aq)');
  /// print(c.isBase()); // false
  /// print(d.isBase()); // true
  /// ```
  bool isBase() {
    return this.equals('NH₃') ||
        (this.ionic && (this.contains('OH') || this.contains('CO₃')));
  }

  /// Returns the state of this compound when in water.
  ///
  /// This method uses data from the solubility chart.
  Phase getWaterState() {
    Phase result;
    for (int i = 0; i < 2; i++) {
      Map<List<String>, List<String>> ionMap = [ionToSolid, ionToAqueous][i];
      ionMap.forEach((List<String> first, List<String> second) {
        for (String f in first) {
          if (this.compoundUnits[0].key.equals(f)) {
            for (String s in second) {
              if (this.compoundUnits[1].key.equals(s)) {
                result = (i == 0) ? Phase.solid : Phase.aqueous;
                break;
              }
            }
            if (result == null) {
              result = (i == 0) ? Phase.aqueous : Phase.solid;
              break;
            }
          } else if (this.compoundUnits[1].key.equals(f)) {
            for (String s in second) {
              if (this.compoundUnits[0].key.equals(s)) {
                result = (i == 0) ? Phase.solid : Phase.aqueous;
                break;
              }
            }
            if (result == null) {
              result = (i == 0) ? Phase.aqueous : Phase.solid;
              break;
            }
          }
        }
      });
    }
    // Exceptions to the above.
    solidCompounds.forEach((String s) {
      if (this.equals(s)) result = Phase.solid;
    });
    aqueousCompounds.forEach((String s) {
      if (this.equals(s)) result = Phase.aqueous;
    });
    if (result == null) result = Phase.solid;
    return result;
  }

  /// Prints the individual units of this compound.
  void printUnits() {
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
