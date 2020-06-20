part of chemistry;

/// A class that represents one unit of a chemical compound.
///
/// This can either be an element or another compound.
abstract class CompoundUnit {
  String formula;
  String category;
  String name;
  bool metal;
  int count;
  int charge;
  List<int> shells;
  List<MapEntry<CompoundUnit, int>> compoundUnits;

  /// Returns `true` if this unit has the formula or symbol [s].
  bool equals(String s);

  /// Returns `true` if this unit is an element.
  bool isElement() {
    return this.runtimeType == Element;
  }

  /// Returns `true` if this unit is a compound.
  bool isCompound() {
    return this.runtimeType == Compound;
  }

  /// Returns the charge of this unit.
  int getCharge() {
    if (this.isCompound()) {
      for (Compound c in polyatomicIons) {
        if (this.equals(c.formula)) return c.charge;
      }
    }
    if (this.equals('H')) return 1;
    if (this.isElement() &&
        this.category.compareTo('transition metal') != 0) {
      int valence = this.shells[this.shells.length - 1];
      if (valence < 5) return valence;
      return valence - 8;
    }
    return this.charge;
  }
}
