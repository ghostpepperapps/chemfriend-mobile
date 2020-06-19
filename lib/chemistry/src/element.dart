part of chemistry;

class Element extends ChemicalElement with CompoundUnit, EquationUnit {
  MatterPhase state;
  bool metal;
  int charge;
  int count;
  Element(
      String name,
      String formula,
      String category,
      String appearance,
      MatterPhase stpPhase,
      int number,
      period,
      int row,
      column,
      List<int> shells,
      num atomicMass,
      num molecularDensity,
      num heatCapacity,
      num meltingPoint,
      num boilingPoint)
      : super(
            name: name,
            symbol: formula,
            category: category,
            appearance: appearance,
            stpPhase: stpPhase,
            number: number,
            period: period,
            row: row,
            column: column,
            shells: shells,
            atomicMass: atomicMass,
            molecularDensity: molecularDensity,
            heatCapacity: heatCapacity,
            meltingPoint: meltingPoint,
            boilingPoint: boilingPoint);
  Element.clone(ChemicalElement e) {
    this.name = e.name;
    this.formula = e.symbol;
    this.category = e.category;
    this.state = e.stpPhase;
    this.number = e.number;
    this.shells = e.shells;
  }

  @override
  String toString() {
    String result = this.formula;
    if (this.count != 1) result += changeScript[this.count.toString()][1];
    result += ePhaseToString[this.state];
    return result;
  }

  @override
  bool equals(String s) {
    return this.formula.compareTo(s) == 0;
  }

  String getName() {
    return this.name;
  }

  static Element from(String formula, [int _charge]) {
    Element result;
    for (ChemicalElement e in periodicTable) {
      if (e.symbol.compareTo(formula) == 0) {
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

  static bool exists(String formula) {
    for (ChemicalElement e in periodicTable) {
      if (e.symbol.compareTo(formula) == 0) return true;
    }
    return false;
  }
}
