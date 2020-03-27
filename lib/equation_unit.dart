import 'element.dart';
import 'compound.dart';
import 'compound_unit.dart';

abstract class EquationUnit {
  String formula;
  String category;
  String name;
  bool metal;
  int count;
  int charge;
  List<int> shells;
  Map<CompoundUnit, int> compoundUnits;

  CompoundUnit compoundUnit;
	int number;

  bool equals(String s);
  bool isElement() { return this.runtimeType == Element; }
  bool isCompound() { return this.runtimeType == Compound; }
}