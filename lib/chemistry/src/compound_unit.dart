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
  bool ionic;
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

  /// Returns `true` if this unit is an acid.
  ///
  /// Checks if the first element is `H` and the phase is `Phase.aqueous`.
  bool isAcid() {
    return this.isCompound() && this.isAcid();
  }

  /// Returns `true` is this unit is a base.
  ///
  /// Checks is this is ammonia (`NH3`), or is ionic and contains hydroxide
  /// (`OH`) or carbonate (`CO3`).
  bool isBase() {
    return this.isCompound() && this.isBase();
  }

  /// Returns the charge of this unit.
  ///
  /// ```dart
  /// Compound c = new Compound('SO4');
  /// print(c.getCharge()); // -2
  ///
  /// Element e = Element.from('Na');
  /// print(e.getCharge()); // 1
  /// ```
  int getCharge() {
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
