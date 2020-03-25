import 'dart:core';
import 'element.dart';
import 'compound.dart';
import 'common_ions.dart' as CI;

class CompoundUnit {
	Element element;
	Compound compound;
	CompoundUnit.fromElement(Element e) {
		this.element = e;
	}
	CompoundUnit.fromCompound(Compound c) {
		this.compound = c;
	}

	int getCharge() {
		if(this.element == null) {
			for(Compound c in CI.polyatomicIons) {
				if(c.formula.compareTo(this.compound.formula) == 0) return c.charge;
			}
		}
		if(this.element.equals('H')) return 1;
		if(this.element.category.compareTo('transition metal') != 0) {
			int valence = this.element.shells[this.element.shells.length - 1];
			if(valence < 5) return valence;
			return valence - 8;
		}
		return this.element.charge;
	}
	@override
	String toString() {
		if(this.element != null) return this.element.toString();
		return this.compound.toString();
	}
}