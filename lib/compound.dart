import 'element.dart';
import 'compound_unit.dart';

void main() {
	Compound c = Compound('Fe(NO3)3(g)');
	c.printInfo();
}

enum State { solid, liquid, gas, aqueous }
Map<String, List<String>> changeScript = {
	'0'        : ['\u2070',   '\u2080'      ],
	'1'        : ['\u00B9',   '\u2081'      ],
	'2'        : ['\u00B2',   '\u2082'      ],
	'3'        : ['\u00B3',   '\u2083'      ],
	'4'        : ['\u2074',   '\u2084'      ],
	'5'        : ['\u2075',   '\u2085'      ],
	'6'        : ['\u2076',   '\u2086'      ],
	'7'        : ['\u2077',   '\u2087'      ],
	'8'        : ['\u2078',   '\u2088'      ],
	'9'        : ['\u2079',   '\u2089'      ],
	's'        : ['\u02e2',   '\u209b'      ],
	'l'        : ['\u02e1',   '\u2097'      ],
	'g'        : ['\u1d4d',   '?'           ],
	'a'        : ['\u1d43',   '\u2090'      ],
	'q'        : ['?',        '?'           ],
	'('        : ['\u207D',   '\u208D'      ],
	')'        : ['\u207E',   '\u208E'      ],
};
Map<State, String> stateToString = {
	State.solid:   '\u208D\u209b\u208E',
	State.liquid:  '\u208D\u2097\u208E',
	State.gas:     '\u208D\u1d67\u208E',
	State.aqueous: '\u208D\u2090\u208E',
};

bool isNumeric(String s) {
	return double.parse(s, (e) => null) != null;
}
class Compound {
	Map<CompoundUnit, int> compoundUnits;
	bool ionic;
	State state;
	String formula;
	int charge;
	Compound(String formula, {bool nested = false, int charge}) {
		this.formula = formula;
		this.charge = charge;
		compoundUnits = {};
		ionic = false;
		bool containsMetal = false;
		bool containsNonmetal = false;
		int i = 0;
		Element current;
		bool hasState = formula[formula.length - 1].compareTo(')') == 0;
		while(i < formula.length - (nested ? 0 : hasState ? formula[formula.length - 2].compareTo('q') == 0 ? 4 : 3 : 0)) {
			if (i == formula.length - 1) {
				current = Element.from(formula[i]);
				i++;
			}
			else if (formula[i].compareTo('(') != 0) {
				if (Element.isElement(formula.substring(i,i+2))) {
					current = Element.from(formula.substring(i,i+2));
					i+=2;
				}
				else {
					current = Element.from(formula[i]);
					i++;
				}
			} else {
				int j = formula.indexOf(')', i);
				int k = j + 1;
				while (k < formula.length && isNumeric(formula[k])) k++;
				Compound c = Compound(formula.substring(i + 1, j), nested: true);
				if(k==j + 1) compoundUnits[CompoundUnit.fromCompound(c)] = 1;
				else compoundUnits[CompoundUnit.fromCompound(c)] = int.parse(formula.substring(j + 1, k));
				for (CompoundUnit cu in c.compoundUnits.keys) {
					if(cu.element.metal) containsMetal = true;
					else if(!cu.element.metal) containsNonmetal = true;
				}
				if(c.formula.compareTo('NH4')==0) containsMetal = true;
				i = k;
				continue;
			}
			if(current.metal) containsMetal = true;
			else if(!current.metal) containsNonmetal = true;
			int j = i;
			while (j < formula.length && isNumeric(formula[j])) j++;
			if(i==j) compoundUnits[CompoundUnit.fromElement(current)] = 1;
			else compoundUnits[CompoundUnit.fromElement(current)] = int.parse(formula.substring(i, j));
			current = null;
			i = j;
		}
		if(!nested && hasState) {
			switch(formula[formula.length - 2]) {
				case 's': this.state = State.solid; break;
				case 'l': this.state = State.liquid; break;
				case 'g': this.state = State.gas; break;
				case 'q': this.state = State.aqueous; break;
			}
		}
		else state = null;
		if(containsMetal && containsNonmetal) ionic = true;
		_multivalent();
	}
	Compound.fromUnits(Map<CompoundUnit, int> units, [State state]) {
		this.compoundUnits = units;
		List<bool> temp = _ionicHelper(compoundUnits.keys.toList());
		ionic = temp[0] == true && temp[1] == true;
		this.state = state;
		_multivalent();
		formula = '';
		for(MapEntry<CompoundUnit, int> c in this.compoundUnits.entries) {
			if(c.key.compound == null) formula += c.key.element.symbol;
			else formula += '(${c.key.compound.formula})';
			if(c.value != 1) formula += c.value.toString();
		}
	}

	List<bool> _ionicHelper(List<CompoundUnit> units, [bool _containsMetal = false, bool _containsNonmetal = false]) {
		for(CompoundUnit c in units) {
			if (c.compound == null) {
				if(c.element.metal) _containsMetal = true;
				else _containsNonmetal = true;
			} else {
				List<bool> temp = _ionicHelper(c.compound.compoundUnits.keys.toList(), _containsMetal, _containsNonmetal);
				_containsMetal = temp[0];
				_containsNonmetal = temp[1];
			}
		}
		return [_containsMetal, _containsNonmetal];
	}
	void _multivalent() {
		if(ionic) {
			CompoundUnit first = compoundUnits.keys.toList()[0];
			if(first.element != null && first.getCharge() == null) {
				int negative = compoundUnits.keys.toList()[1].getCharge() * compoundUnits.values.toList()[1];
				compoundUnits.keys.toList()[0].element.charge = -(negative ~/ compoundUnits.values.toList()[0]);
			}
		}
	}
	@override
	String toString() {
		String result = '';
		for(MapEntry<CompoundUnit, int> c in this.compoundUnits.entries) {
			if(c.key.compound == null) result += c.key.element.symbol;
			else result += '(${c.key.compound.toString()})';
			if(c.value != 1) result += changeScript[c.value.toString()][1];
		}
		if (this.state != null) result += stateToString[this.state];
		return result;
	}
	void printElements() {
		for (var compoundUnit in compoundUnits.entries) {
			if (compoundUnit.key.compound == null) print('${compoundUnit.key.element.name}: ${compoundUnit.value}');
			else print('${compoundUnit.key.compound.formula}: ${compoundUnit.value}');
		}
	}
	void printInfo() {
		print('Compound: ${this.toString()}');
		print('Category: ${(ionic) ? 'Ionic' : 'Molecular'}');
		print('State: ${(state == State.solid) ? 'Solid' : (state == State.liquid) ? 'Liquid' : (state == State.gas) ? 'Gas' : 'Aqueous'}');
	}

}