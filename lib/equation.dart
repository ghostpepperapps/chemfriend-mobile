import 'package:chemfriend/equation_unit.dart';
import 'element.dart';
import 'compound_unit.dart';
import 'compound.dart';

void main() {
	Equation f = Equation('Cl2(g) + GaF3(aq)');
	print('Reaction Type: ${typeToString[Equation.getType(f.reactants)]}');
	f.solve();
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
	List<MapEntry<EquationUnit, int>> reactants;
	List<MapEntry<EquationUnit, int>> products;
	bool inWater;
	Type type;

	Equation(String s) {
		List<MapEntry<EquationUnit, int>> reactants;
		List<MapEntry<EquationUnit, int>> products;
		String reactantStr;
		String productStr;
		reactantStr = (s.contains('=>')) ? s.split(' => ')[0] : s;
		productStr = (s.contains('=>')) ? s.split(' => ')[1] : null;
		for(String r in reactantStr.split(' + ')) {
			int i = 0;
			while(isNumeric(r[i])) i++;
			bool hasState = r[r.length - 1].compareTo(')') == 0;
			int j = (hasState) ? r.length - 3 : r.length;
			while(isNumeric(r[j - 1])) j--;
			int number = (i != 0) ? int.parse(r.substring(0, i)) : 1;
			if(Element.exists(r.substring(i, j))) reactants.add({Element.from(r.substring(i, j)) :  1});
			else reactants.add({Compound(r.substring(i)) : number});
		}
		if(productStr != null) {
			for(String p in productStr.split(' + ')) {
				int i = 0;
				while(isNumeric(p[i])) i++;
				bool hasState = p[p.length - 1].compareTo(')') == 0;
				int j = (hasState) ? p.length - 3 : p.length;
				while(isNumeric(p[j - 1])) j--;
				int number = (i != 0) ? int.parse(p.substring(0, i)) : 1;
				if(Element().exists(p.substring(i, j))) products.add({Element.from(p.substring(i, j)) : 1});
				else products.add(MapEntry(Compound(p.substring(i)), number));
			}
		}
		else products = null;
		this.reactants = reactants;
		this.products = products;
	}

	Equation.fromUnits(Map<EquationUnit, int> reactants, [Map<EquationUnit, int> products]) {
		this.reactants = reactants;
		this.products = products;
	}

	void solve() {
		type = getType(this.reactants);
		this.products = (this.products == null) ? getProducts(reactants, type) : this.products;
		// Balancing
		switch(type) {
			case Type.comp:
				List<double> counts = [1, 1, 1];
				bool halfElement = false;
				for(int i = 0; i < counts.length - 1; i++) {
					counts[i] = this.products[0].compoundUnits.entries.toList()[i].value / this.reactants[i].count;
					if(counts[i] != counts[i].toInt()) halfElement = true;
				}
				if(halfElement) counts = counts.map((count) => count *= 2).toList();
				for(int i = 0; i < this.reactants.length; i++) this.reactants[i].number = counts[i].toInt();
				this.products[0].number = counts[counts.length - 1].toInt();
				break;
			case Type.compAcid: // No balancing required
				break;
			case Type.compBase:
				this.reactants.keys.toList()[0].number = reactants.keys.toList()[1].compoundUnits.values.toList()[1];
				this.products[0].number = reactants.keys.toList()[1].compoundUnits.values.toList()[0];
				break;
			case Type.compSalt: // No balancing required
				break;
			case Type.decomp:
				List<double> counts = [1, 1, 1];
				bool halfElement = false;
				for(int i = 0; i < counts.length - 1; i++) {
					counts[i] = this.reactants.keys.toList()[0].compoundUnits.entries.toList()[i].value / this.products[i].count;
					if(counts[i] != counts[i].toInt()) halfElement = true;
				}
				if(halfElement) counts = counts.map((count) => count *= 2).toList();
				for(int i = 0; i < this.products.length; i++) this.products[i].number = counts[i].toInt();
				this.reactants.keys.toList()[0].number = counts[counts.length - 1].toInt();
				break;
			case Type.decompAcid: // No balancing required
				break;
			case Type.decompBase:
				this.reactants.keys.toList()[0].number = products[1].compoundUnits.values.toList()[0];
				this.products[0].number = reactants.keys.toList()[0].number * reactants.keys.toList()[0].compoundUnits.values.toList()[1] ~/ 2;
				break;
			case Type.decompSalt: // No balancing required
				break;
			case Type.combustion:
				List<double> counts = [1, 1, 1, 1];
				counts[3] = reactants.keys.toList()[0].compoundUnits.values.toList()[0].toDouble();
				counts[2] = (reactants.keys.toList()[0].compoundUnits.values.toList()[1]) / 2;
				counts[1] = (products[0].compoundUnits.values.toList()[1] * counts[2] +
										products[1].compoundUnits.values.toList()[1] * counts[3]).toDouble();
				if(reactants.keys.toList()[0].compoundUnits.keys.toList().length > 2)
					counts[1] -= (reactants.keys.toList()[0].compoundUnits.values.toList()[2] * counts[0]);
				counts[1] /= 2;
				bool halfElement = false;
				for(double c in counts) if(c != c.toInt()) halfElement = true;
				if(halfElement) counts = counts.map((count) => count *= 2).toList();
				reactants.keys.toList()[0].number = counts[0].toInt();
				reactants.keys.toList()[1].number = counts[1].toInt();
				products[0].number = counts[2].toInt();
				products[1].number = counts[3].toInt();
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
		for(MapEntry<EquationUnit, int> r in this.reactants.entries) {
			if(r.value != 1) result += r.value.toString();
			result += r.key.toString();
      result += ' + ';
		}
    result = result.substring(0, result.length - 3);
		result += ' => ';
		for(MapEntry<EquationUnit, int> p in this.products.entries) {
			if(p.value != 1) result += p.value.toString();
			result += p.key.toString();
      result += ' + ';
		}
    result = result.substring(0, result.length - 3);
		return result;
	}

	static Map<EquationUnit, int> getProducts(Map<EquationUnit, int> reactants, Type type) {
		switch(type) {
			case Type.comp:
				bool ionic = false;
				if(reactants.keys.toList()[0].metal != reactants.keys.toList()[1].metal) ionic = true;
				int count0;
				int count1;
				if(ionic) {
					int lcmCharge = lcm(reactants.keys.toList()[0].charge, reactants.keys.toList()[1].charge).abs();
					count0 = lcmCharge ~/ ((reactants.keys.toList()[0].charge == 0) ? 1 : reactants.keys.toList()[0].charge);
					count1 = -lcmCharge ~/ ((reactants.keys.toList()[1].charge == 0) ? 1 : reactants.keys.toList()[1].charge);
				} else {
					count0 = reactants.keys.toList()[0].count;
					count1 = reactants.keys.toList()[0].count;
				}
				return {Compound.fromUnits({
					reactants.keys.toList()[0]: count0,
					reactants.keys.toList()[1]: count1,
				}): 1};
				break;
		  case Type.compAcid:
				return {Compound().fromUnits({
					Element().from('H'): 2,
					reactants.keys.toList()[1].compoundUnits.keys.toList()[0]: 1,
					Element().from('O'): reactants.keys.toList()[1].compoundUnits.values.toList()[1] + 1,
				}): 1};
		    break;
		  case Type.compBase:
				return {Compound.fromUnits({
					reactants.keys.toList()[1].compoundUnits.keys.toList()[0]): 1,
					Compound('OH'): reactants.keys.toList()[1].compoundUnits.keys.toList()[0].charge,
				}), 1)};
		    break;
		  case Type.compSalt:
				return [Compound.fromUnits({
					reactants.keys.toList()[0].compoundUnits.keys.toList()[0]): reactants.keys.toList()[0].compoundUnits.values.toList()[0],
					reactants.keys.toList()[1].compoundUnits.keys.toList()[0]): reactants.keys.toList()[1].compoundUnits.values.toList()[0],
					Element.from('O')): reactants.keys.toList()[0].compoundUnits.values.toList()[1] + reactants.keys.toList()[1].compoundUnits.values.toList()[1],
				}), 1)];
		    break;
		  case Type.decomp:
				return [reactants.keys.toList()[0].compoundUnits.keys.toList()[0]),
								reactants.keys.toList()[0].compoundUnits.keys.toList()[1])];
		    break;
		  case Type.decompAcid:
				return [Compound('H2O(l)'), 1),
								Compound.fromUnits({
								reactants.keys.toList()[0].compoundUnits.keys.toList()[1]): reactants.keys.toList()[0].compoundUnits.values.toList()[1],
								Element.from('O')): reactants.keys.toList()[0].compoundUnits.values.toList()[2] - 1,
					}, State.gas), 1)];
		    break;
		  case Type.decompBase:
				int lcmCharge = lcm(reactants.keys.toList()[0].compoundUnits.keys.toList()[0].charge, 2);
				return [Compound('H2O(l)'), 1),
								Compound.fromUnits({
								reactants.keys.toList()[0].compoundUnits.keys.toList()[0]): (-lcmCharge ~/ reactants.keys.toList()[0].compoundUnits.keys.toList()[0].charge).abs(),
								Element.from('O')): lcmCharge.abs() ~/ 2,
					}, State.gas), 1)];
				break;
		  case Type.decompSalt:
		  	Compound metalOxide = Compound.fromUnits({
					reactants.keys.toList()[0].compoundUnits.keys.toList()[0]): reactants.keys.toList()[0].compoundUnits.values.toList()[0],
					Element.from('O')): (reactants.keys.toList()[0].compoundUnits.values.toList()[0] * reactants.keys.toList()[0].compoundUnits.keys.toList()[0].charge) ~/ 2,
				});
				Compound nonmetalOxide = Compound.fromUnits({
					reactants.keys.toList()[0].compoundUnits.keys.toList()[1]): reactants.keys.toList()[0].compoundUnits.values.toList()[1],
					Element.from('O')): reactants.keys.toList()[0].compoundUnits.values.toList()[2] - metalOxideUnits.values.toList()[1],
				});
				return [metalOxide, 1), nonmetalOxide, 1)];
		    break;
		  case Type.combustion:
		    return [Compound('H2O(g)'), 1), Compound('CO2(g)'), 1)];
		    break;
		  case Type.singleReplacement:
		    if(reactants.keys.toList()[0].metal) return [
		    	Compound.fromUnits({
						reactants.keys.toList()[0]): reactants.keys.toList()[1].compoundUnits.values.toList()[0],
						reactants.keys.toList()[1].compoundUnits.keys.toList()[1]): reactants.keys.toList()[1].compoundUnits.values.toList()[1]})),
					reactants.keys.toList()[1].compoundUnits.keys.toList()[0]),
				];
		    else return [
					reactants.keys.toList()[1].compoundUnits.keys.toList()[1]),
					Compound.fromUnits({
						reactants.keys.toList()[1].compoundUnits.keys.toList()[0]): reactants.keys.toList()[1].compoundUnits.values.toList()[0],
						reactants.keys.toList()[0]): reactants.keys.toList()[1].compoundUnits.values.toList()[1]})),
				];
		    break;
		  case Type.doubleReplacement:
		    // TODO: Handle this case.
		    break;
		}
		return null;
	}
	
	static Type getType(Map<EquationUnit, int> reactants) {
		if(reactants.length == 1) { // Decomposition
			if(reactants.keys.toList()[0].isElement()) return null;
				if(reactants.keys.toList()[0].compoundUnits.keys.toList()[0].equals('H')) {
					if(reactants.keys.toList()[0].compoundUnits.keys.toList()[2].equals('O')) {
						if(!reactants.keys.toList()[0].compoundUnits.keys.toList()[1].metal) return Type.decompAcid;
					}
				}
				else if(reactants.keys.toList()[0].compoundUnits.keys.toList()[0].metal) {
					if(reactants.keys.toList()[0].compoundUnits.keys.toList()[1].isCompound()) {
						if(reactants.keys.toList()[0].compoundUnits.keys.toList()[1].formula.compareTo('OH') == 0) return Type.decompBase;
					}
					if(!reactants.keys.toList()[0].compoundUnits.keys.toList()[1].metal) {
						if(reactants.keys.toList()[0].compoundUnits.keys.toList()[2].equals('O')) {
							return Type.decompSalt;
						}
					}
				}
			if(reactants.keys.toList()[0].compoundUnits.keys.length == 2) return Type.decomp;
		}
		if(reactants.keys.toList()[0].isElement() && reactants.keys.toList()[1].isElement()) return Type.comp; // Simple Composition
		else if(reactants.keys.toList()[0].isElement() && reactants.keys.toList()[1].isCompound()) {
			if(reactants.keys.toList()[0].compoundUnits.keys.toList()[0].isElement()) {
				if(reactants.keys.toList()[0].compoundUnits.keys.toList()[0].equals('C') &&
						reactants.keys.toList()[0].compoundUnits.keys.toList()[1].equals('H') &&
						reactants.keys.toList()[1].equals('O')) return Type.combustion; // Hydrocarbon Combustion
			}
			return Type.singleReplacement;
		}
		else if(reactants.keys.toList()[0].isCompound() && reactants.keys.toList()[1].isCompound()) {
			if(reactants.keys.toList()[0].formula.compareTo('H2O(l)') == 0) {
				if(reactants.keys.toList()[1].compoundUnits.keys.toList()[1].equals('O')) {
					if(!reactants.keys.toList()[1].compoundUnits.keys.toList()[0].metal) return Type.compAcid;
					return Type.compBase;
				}
			}
			else if(reactants.keys.toList()[0].compoundUnits.keys.toList()[1].equals('O') && reactants.keys.toList()[1].compoundUnits.keys.toList()[1].equals('O')) {
				return Type.compSalt;
			}
			return Type.doubleReplacement;
		}
		return null;
	}
}