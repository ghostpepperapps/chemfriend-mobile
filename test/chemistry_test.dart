import 'package:chemfriend/chemistry/chemistry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Element', () {
    test('.getName() returns the name', () {
      Element e = new Element('O');
      expect(e.getName(), equals('Oxygen'));
    });
    test('.toString() returns the subscripted name', () {
      Element e = new Element('S');
      expect(e.toString(), equals('S₈(s)'));
    });
    test('.equals() returns equality to another element', () {
      Element e = new Element('Mn');
      expect(e.equals('Mn'), equals(true));
    });
    test('.getCharge() returns the charge', () {
      Element e = new Element('Al');
      expect(e.getCharge(), equals(e.charge));
    });
  });
  group('Compound', () {
    test('.isCompound() returns true', () {
      Compound c = Compound('H2O');
      expect(c.isCompound(), equals(true));
    });
    test('.toString() returns the subscripted name', () {
      Compound c = Compound('C6H12O6(s)');
      expect(c.toString(), equals('C₆H₁₂O₆(s)'));
    });
    test('.equals() returns equality to another compound', () {
      Compound c = Compound('Al2O3(s)');
      expect(c.equals('Al2O3(s)'), equals(true));
    });
    test('.getCharge() returns the charge', () {
      Compound c = Compound('NO3');
      expect(c.getCharge(), equals(-1));
    });
  });
  group('Equation', () {
    test('constructor  works regardless of indentation', () {
      Equation e = Equation('H2(g)  +O2(g)   => H2O(l)\n ');
      expect(e.toString(), equals('H₂(g) + O₂(g) → H₂O(l)'));
    });
    test('.balance() works correctly for simple composition', () {
      Equation e = Equation('H2(g) + O2(g)');
      e.balance();
      expect(e.toString(), equals('H₂(g) + O₂(g) → H₂O₂'));
    });
    test('.balance() works correctly for composition of an acid', () {
      Equation e = Equation('H2O(l) + CO2(g)');
      e.balance();
      expect(e.toString(), equals('H₂O(l) + CO₂(g) → H₂CO₃(aq)'));
    });
    test('.balance() works correctly for composition of a base', () {
      Equation e = Equation('H2O(l) + Na2O(aq)');
      e.balance();
      expect(e.toString(), equals('H₂O(l) + Na₂O(aq) → 2NaOH(aq)'));
    });
    test('.balance() works correctly for simple decomposition', () {
      Equation e = Equation('H2O2(l)');
      e.balance();
      expect(e.toString(), equals('H₂O₂(l) → H₂(g) + O₂(g)'));
    });
    test('.balance() works correctly for decomposition of an acid', () {
      Equation e = Equation('H2CO3(aq)');
      e.balance();
      expect(e.toString(), equals('H₂CO₃(aq) → H₂O(l) + CO₂'));
    });
    test('.balance() works correctly for decomposition of a base', () {
      Equation e = Equation('NaOH(aq)');
      e.balance();
      expect(e.toString(), equals('2NaOH(aq) → H₂O(l) + Na₂O'));
    });
    test('.balance() works correctly for combustion', () {
      Equation e = Equation('C6H12O6(s) + O2(g)');
      e.balance();
      expect(
          e.toString(), equals('C₆H₁₂O₆(s) + 6O₂(g) → 6H₂O(g) + 6CO₂(g)'));
    });
    test('.balance() works correctly for single replacement of nonmetal',
        () {
      Equation e = Equation('S8(s) + GaF3(s)');
      e.balance();
      expect(
          e.toString(), equals('3S₈(s) + 16GaF₃(aq) → 24F₂(g) + 8Ga₂S₃(s)'));
    });
    test('.balance() works correctly for single replacement of metal', () {
      Equation e = Equation('Na(s) + GaF3(s)');
      e.balance();
      expect(e.toString(), equals('3Na(s) + GaF₃(aq) → Ga(s) + 3NaF(aq)'));
    });
    test('.balance() works correctly for double replacement', () {
      Equation e = Equation('Na3P(aq) + CaCl2(aq)');
      e.balance();
      expect(e.toString(),
          equals('2Na₃P(aq) + 3CaCl₂(aq) → 6NaCl(aq) + Ca₃P₂(s)'));
    });
    test(
        '.balance() works correctly for double replacement of polyatomic ions',
        () {
      Equation e = Equation('NH4NO3(aq) + CaSO3(aq)');
      e.balance();
      expect(e.toString(),
          equals('2NH₄NO₃(aq) + CaSO₃(s) → (NH₄)₂SO₃(aq) + Ca(NO₃)₂(aq)'));
    });
    test('.balance() works correctly for neutralization', () {
      Equation e = Equation('H2CO3(aq) + Al(OH)3(aq)');
      e.balance();
      expect(e.toString(),
          equals('3H₂CO₃(aq) + 2Al(OH)₃(s) → 6H₂O(l) + Al₂(CO₃)₃(s)'));
    });
    test('.balance() works correctly for gas formation', () {
      Equation e = Equation('(NH4)2S(aq) + Al(OH)3(aq)');
      e.balance();
      expect(
          e.toString(),
          equals(
              '3(NH₄)₂S(aq) + 2Al(OH)₃(s) → 6H₂O(l) + 6NH₃(g) + Al₂S₃(s)'));
    });
  });
}
