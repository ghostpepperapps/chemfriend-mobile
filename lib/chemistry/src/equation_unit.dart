part of chemistry;

/// A class that represents one unit of a chemical equation.
///
/// This can either be an element or a compound.
abstract class EquationUnit {
  String formula;
  String category;
  String name;
  bool metal;
  int count;
  int charge;
  List<int> shells;
  List<MapEntry<CompoundUnit, int>> compoundUnits;

  CompoundUnit compoundUnit;
  int number;

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
}
