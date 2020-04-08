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
      expect(c.toString(), equals('C\u2086H\u2081\u2082O\u2086\u208D\u209b\u208E'));
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
}
