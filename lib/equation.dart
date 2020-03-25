import 'package:chemfriend/equation_unit.dart';
import 'element.dart';
import 'compound_unit.dart';
import 'compound.dart';

void main() {
	Equation f = Equation('H2O(l) + BaO(s)');
	f.solve();
	print('Reaction Type: ${typeToString[f.type]}');
	print(f.toString());
}

enum Type { comp, compAcid, compBase, compSalt, decomp, decompAcid, decompBase, decompSalt, combustion, singleReplacement, doubleReplacement }
Map<Type, String> typeToString = { Type.comp: 'Simple Composition', Type.compAcid: 'Composition of an Acid', Type.compBase: 'Composition of a Base', Type.compSalt: 'Composition of a Salt',
	Type.decomp: 'Simple Decomposition', Type.decompAcid: 'Decomposition of an Acid', Type.decompBase: 'Decomposition of a Base', Type.decompSalt: 'Decomposition of a Salt',
	Type.combustion: 'Hydrocarbon Combustion', Type.singleReplacement: 'Single Replacement', Type.doubleReplacement: 'Double Replacement'};


bool isNumeric(String s) => double.parse(s, (e) => null) != null;

int lcm(int a, int b) => (a * b) ~/ gcd(a, b);

int gcd(int a, int b) {
	while (b != 0) {
		var t = b;
		b = a % t;
		a = t;
	}
	return a;
}

class Equation {
	List<EquationUnit> reactants;
	List<EquationUnit> products;
	bool inWater;
	Type type;

	Equation(String s) {
		List<EquationUnit> reactants= [];
		List<EquationUnit> products = [];
		String reactantStr;
		String productStr;
		reactantStr = (s.contains('=>')) ? s.split(' => ')[0] : s;
		productStr = (s.contains('=>')) ? s.split(' => ')[1] : null;
		for(String r in reactantStr.split(' + ')) {
			int i = 0;
			while(isNumeric(r[i])) i++;
			int j = r.length;
			while(isNumeric(r[j - 1])) j--;
			int number = (i != 0) ? int.parse(r.substring(0, i)) : 1;
			if(Element.isElement(r.substring(i, j))) reactants.add(EquationUnit.fromElement(Element.from(r.substring(i, j))));
			else reactants.add(EquationUnit.fromCompound(Compound(r.substring(i)), number));
		}
		if(productStr != null) {
			for(String p in productStr.split(' + ')) {
				int i = 0;
				while(isNumeric(p[i])) i++;
				int j = p.length - 1;
				while(isNumeric(p[j])) j--;
				int number = (i != 0) ? int.parse(p.substring(0, i)) : 1;
				if(Element.isElement(p.substring(i, j))) products.add(EquationUnit.fromElement(Element.from(p.substring(i, j))));
				else products.add(EquationUnit.fromCompound(Compound(p.substring(i)), number));
			}
		}
		else products = null;
		this.reactants = reactants;
		this.products = products;
	}

	Equation.fromUnits(List<EquationUnit> reactants, [List<EquationUnit> products]) {
		this.reactants = reactants;
		this.products = products;
	}

	void solve() {
		type = getType(this.reactants);
		this.products = (this.products == null) ? getProducts(reactants, type) : this.products;
		switch(type) {
			case Type.comp:
				List<double> counts = [1, 1, 1];
				bool halfElement = false;
				for(int i = 0; i < counts.length - 1; i++) {
					counts[i] = this.products[0].compound.compoundUnits.entries.toList()[i].value / this.reactants[i].element.count;
					if(counts[i] != counts[i].toInt()) halfElement = true;
				}
				if(halfElement) counts = counts.map((count) => count *= 2).toList();
				for(int i = 0; i < this.reactants.length; i++) this.reactants[i].number = counts[i].toInt();
				this.products[0].number = counts[counts.length - 1].toInt();
				break;

			case Type.compAcid: // No balancing required
				break;
			case Type.compBase: // No balancing required
				List<int> counts = [1, 1, 1];
				for(int i = 0; i < counts.length - 1; i++) {

				}
				break;
			case Type.compSalt:
			// TODO: Handle this case.
				break;
			case Type.decomp:
			// TODO: Handle this case.
				break;
			case Type.decompAcid:
			// TODO: Handle this case.
				break;
			case Type.decompBase:
			// TODO: Handle this case.
				break;
			case Type.decompSalt:
			// TODO: Handle this case.
				break;
			case Type.combustion:
			// TODO: Handle this case.
				break;
			case Type.singleReplacement:
			// TODO: Handle this case.
				break;
			case Type.doubleReplacement:
			// TODO: Handle this case.
				break;
		}
	}

	@override
	String toString() {
		String result = '';
		for(int i = 0; i < this.reactants.length; i++) {
			EquationUnit r = this.reactants[i];
			if(r.number != 1) result += r.number.toString();
			if(r.element != null) result += r.element.toString();
			else result += r.compound.toString();
			if(i < this.reactants.length - 1) result += ' + ';
			else result += ' => ';
		}
		for(int i = 0; i < this.products.length; i++) {
			EquationUnit p = this.products[i];
			if(p.number != 1) result += p.number.toString();
			if(p.element != null) result += p.element.toString();
			else result += p.compound.toString();
			if(i < this.products.length - 1) result += ' + ';
		}
		return result;
	}

	static List<EquationUnit> getProducts(List<EquationUnit> reactants, Type type) {
		switch(type) {
			case Type.comp:
				bool ionic = false;
				if(reactants[0].element.metal != reactants[1].element.metal) ionic = true;
				int count0;
				int count1;
				if(ionic) {
					int lcmCharge = lcm(reactants[0].element.charge, reactants[1].element.charge).abs();
					count0 = lcmCharge ~/ ((reactants[0].element.charge == 0) ? 1 : reactants[0].element.charge);
					count1 = -lcmCharge ~/ ((reactants[1].element.charge == 0) ? 1 : reactants[1].element.charge);
				} else {
					count0 = reactants[0].element.count;
					count1 = reactants[0].element.count;
				}
				return [EquationUnit.fromCompound(Compound.fromUnits({
					CompoundUnit.fromElement(reactants[0].element): count0,
					CompoundUnit.fromElement(reactants[1].element): count1,
				}))];
				break;
		  case Type.compAcid:
				return [EquationUnit.fromCompound(Compound.fromUnits({
					CompoundUnit.fromElement(Element.from('H')): 2,
					CompoundUnit.fromElement(reactants[1].compound.compoundUnits.keys.toList()[0].element): 1,
					CompoundUnit.fromElement(Element.from('O')): reactants[1].compound.compoundUnits.values.toList()[0] + 1,
				}), 1)];
		    break;
		  case Type.compBase:
				return [EquationUnit.fromCompound(Compound.fromUnits({
					CompoundUnit.fromElement(reactants[1].compound.compoundUnits.keys.toList()[0].element): 1,
					CompoundUnit.fromCompound(Compound('OH')): reactants[1].compound.compoundUnits.values.toList()[0] + 1,
				}), 1)];
		    break;
		  case Type.compSalt:
		    // TODO: Handle this case.
		    break;
		  case Type.decomp:
		    // TODO: Handle this case.
		    break;
		  case Type.decompAcid:
		    // TODO: Handle this case.
		    break;
		  case Type.decompBase:
		    // TODO: Handle this case.
		    break;
		  case Type.decompSalt:
		    // TODO: Handle this case.
		    break;
		  case Type.combustion:
		    // TODO: Handle this case.
		    break;
		  case Type.singleReplacement:
		    // TODO: Handle this case.
		    break;
		  case Type.doubleReplacement:
		    // TODO: Handle this case.
		    break;
		}
		return null;
	}
	
	static Type getType(List<EquationUnit> reactants) {
		if(reactants[0].element != null && reactants[1].element != null) return Type.comp;
		else if(reactants[0].compound != null && reactants[1].compound != null) {
			if(reactants[0].compound.formula.compareTo('H2O(l)') == 0) {
				if(reactants[1].compound.compoundUnits.keys.toList()[1].element.equals('O')) {
					if(!reactants[1].compound.compoundUnits.keys.toList()[0].element.metal) return Type.compAcid;
					return Type.compBase;
				}
			}
		}
		return null;
	}
}