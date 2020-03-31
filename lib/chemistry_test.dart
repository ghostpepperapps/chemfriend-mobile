import 'package:chemfriend/chemistry/chemistry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Element', () {
    test('.getName() returns the name', () {
      Element e = Element.from('O');
      expect(e.getName(), equals('Oxygen'));
    });
    test('.toString() returns the subscript', () {
      Element e = Element.from('S');
      expect(e.toString(), equals('S\u2088'));
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
}
