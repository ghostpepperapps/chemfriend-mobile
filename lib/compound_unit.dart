import 'dart:core';
import 'element.dart';
import 'compound.dart';
import 'common_ions.dart' as CI;

abstract class CompoundUnit {
  String formula;
  String category;
  String name;
  bool metal;
  int count;
  int charge;
  List<int> shells;
  Map<CompoundUnit, int> compoundUnits;

  bool equals(String s);
  bool isElement() { return this.runtimeType == Element; }
  bool isCompound() { return this.runtimeType == Compound; }
	int getCharge() {
		if(this.isCompound()) {
			for(Compound c in CI.polyatomicIons) {
				if(this.equals(c.formula)) return c.charge;
			}
		}
		if(this.equals('H')) return 1;
		if(this.isElement() && this.category.compareTo('transition metal') != 0) {
			int valence = this.shells[this.shells.length - 1];
			if(valence < 5) return valence;
			return valence - 8;
		}
		return this.charge;
	}
}