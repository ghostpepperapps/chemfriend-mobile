import 'element.dart';
import 'compound.dart';

class EquationUnit {
	Element element;
	Compound compound;
	int number;
	EquationUnit.fromElement(Element e, [int number]) {
		this.number = number;
		this.element = e;
	}
	EquationUnit.fromCompound(Compound c, [int number]) {
		this.number = number;
		this.compound = c;
	}
	@override
	String toString() {
		if(this.element != null) return this.element.toString();
		return this.compound.toString();
	}
}