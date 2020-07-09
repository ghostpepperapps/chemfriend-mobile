import 'package:chemfriend/chemistry/chemistry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Equation.getExplanation() works for simple composition', () {
    Equation e = new Equation('Na(s) + O2(g)');
    e.balance();
    print(e.getExplanation());
  });
  test('Equation.getExplanation() works for composition of an acid', () {
    Equation e = new Equation('H2O(l) + CO2(g)');
    e.balance();
    print(e.getExplanation());
  });
  test('Equation.getExplanation() works for composition of a base', () {
    Equation e = new Equation('H2O(l) + Na2O(s)');
    e.balance();
    print(e.getExplanation());
    print(e);
  });
  test('Equation.getExplanation() works for composition of a salt', () {
    Equation e = new Equation('Na2O(s) + CO2(g)');
    e.balance();
    print(e.getExplanation());
    print(e);
  });
  test('Equation.getExplanation() works for simple decomposition', () {
    Equation e = new Equation('Na2O(s)');
    e.balance();
    print(e.getExplanation());
    print(e);
  });
  test('Equation.getExplanation() works for decomposition of an acid', () {
    Equation e = new Equation('H2CO3(aq)');
    e.balance();
    print(e.getExplanation());
    print(e);
  });
  test('Equation.getExplanation() works for decomposition of a base', () {
    Equation e = new Equation('NaOH(aq)');
    e.balance();
    print(e.getExplanation());
    print(e);
  });
}
