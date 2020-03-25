import 'dart:convert';

import 'package:periodic_table/periodic_table.dart' as PT;

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
Map<PT.MatterPhase, String> stateToString = {
	PT.MatterPhase.solid:  '\u208D\u209b\u208E',
	PT.MatterPhase.liquid: '\u208D\u2097\u208E',
	PT.MatterPhase.gas:    '\u208D\u1d67\u208E',
};

class Element extends PT.ChemicalElement {
	bool metal;
	int charge;
	int count;
	Element(
			String name, String symbol, String category, String appearance,
			PT.MatterPhase stpPhase, int number, period, int row, column, List<int> shells,
			num atomicMass, num molecularDensity, num heatCapacity, num meltingPoint, num boilingPoint): super(
			name: name, symbol: symbol, category: category, appearance: appearance,
			stpPhase: stpPhase, number: number, period: period, row: row, column: column, shells: shells,
			atomicMass: atomicMass, molecularDensity: molecularDensity, heatCapacity: heatCapacity, meltingPoint: meltingPoint, boilingPoint: boilingPoint
	);
	bool equals(String s) {
		return this.symbol.compareTo(s) == 0;
	}
	@override
	String toString() {
		String result = this.symbol;
		if(this.count != 1) result += changeScript[this.count.toString()][1];
		result += stateToString[this.stpPhase];
		return result;
	}
	static Element clone(PT.ChemicalElement e) {
		return new Element(
				e.name, e.symbol, e.category, e.appearance,
				e.stpPhase, e.number, e.period, e.row, e.column, e.shells,
				e.atomicMass, e.molecularDensity, e.heatCapacity, e.meltingPoint, e.boilingPoint);
	}
	static Element from(String symbol, [int _charge = 0]) {
		Element result;
		for(PT.ChemicalElement e in PT.periodicTable) {
			if(e.symbol.compareTo(symbol) == 0) {
				result = clone(e);
				break;
			}
		}
		if(result.category.contains('metal')) result.metal = !(result.category.contains('nonmetal'));
		else result.metal = false;
		if(result.category.contains('diatomic')) result.count = 2;
		else if(result.symbol.compareTo('P') == 0) result.count = 4;
		else if(result.symbol.compareTo('S') == 0) result.count = 8;
		else result.count = 1;
		if(result.equals('H')) result.charge = 1;
		else if(result.category.compareTo('transition metal') != 0) {
			int valence = result.shells[result.shells.length - 1];
			if(valence < 5) result.charge = valence;
			else result.charge = valence - 8;
		}
		else result.charge = _charge;
		return result;
	}
	static bool isElement(String symbol) {
		for(PT.ChemicalElement e in PT.periodicTable) {
			if(e.symbol.compareTo(symbol) == 0) return true;
		}
		return false;
	}
}