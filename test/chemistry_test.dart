import 'package:chemfriend/chemistry/chemistry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Element', () {
    test('.getName() returns the name', () {
      Element e = Element.from('O');
      expect(e.getName(), equals('Oxygen'));
    });
    test('.toString() returns the subscripted name', () {
      Element e = Element.from('S');
      expect(e.toString(), equals('S\u2088\u208D\u209b\u208E'));
    });
    test('.equals() returns equality to another element', () {
      Element e = Element.from('Mn');
      expect(e.equals('Mn'), equals(true));
    });
    test('.getCharge() returns the charge', () {
      Element e = Element.from('Al');
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
      expect(c.toString(), equals('C₆H₁₂O₆₍ₛ₎'));
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
      expect(e.toString(), equals('H₂₍ᵧ₎ + O₂₍ᵧ₎ → H₂O₍ₗ₎'));
    });
    test('.solve() works correctly for simple composition', () {
      Equation e = Equation('H2(g) + O2(g)');
      e.balance();
      expect(e.toString(), equals('H₂₍ᵧ₎ + O₂₍ᵧ₎ → H₂O₂'));
    });
    test('.solve() works correctly for composition of an acid', () {
      Equation e = Equation('H2O(l) + CO2(g)');
      e.balance();
      expect(e.toString(), equals('H₂O₍ₗ₎ + CO₂₍ᵧ₎ → H₂CO₃'));
    });
    test('.solve() works correctly for combustion', () {
      Equation e = Equation('C6H12O6(s) + O2(g)');
      e.balance();
      expect(e.toString(), equals('C₆H₁₂O₆₍ₛ₎ + 6O₂₍ᵧ₎ → 6H₂O₍ᵧ₎ + 6CO₂₍ᵧ₎'));
    });
    /* test('.solve() works correctly for double replacement', () {
      Equation e = Equation('AlF3(aq) + CaCl2(aq)');
      e.balance();
      expect(e.toString(), equals('2AlF₃₍ₐ₎ + 3CaCl₂₍ₐ₎ → 2AlCl₃ + 3CaF₂'));
    }); */
  });
}
