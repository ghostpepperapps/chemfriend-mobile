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
    Equation e = new Equation('H2O(l) + Al2O3(s)');
    e.balance();
    print(e.getExplanation());
    print(e);
  });
  test('Equation.getExplanation() works for composition of a salt', () {
    Equation e = new Equation('Al2O3(s) + CO2(g)');
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
  test('Equation.getExplanation() works for decomposition of a salt', () {
    Equation e = new Equation('MgCO3(aq)');
    e.balance();
    print(e.getExplanation());
    print(e);
  });
  test('Equation.getExplanation() works for combustion', () {
    Equation e = new Equation('C4H10(s) + O2(g)');
    e.balance();
    print(e.getExplanation());
    print(e);
  });
  test(
      'Equation.getExplanation() works correctly for single replacement of metal',
      () {
    Equation e = Equation('Ga(s) + Ca3P2(s)');
    e.balance();
    print(e.getExplanation());
    print(e);
  });
  test(
      'Equation.getExplanation() works correctly for single replacement of nonmetal',
      () {
    Equation e = Equation('S8(s) + GaF3(s)');
    e.balance();
    print(e.getExplanation());
    print(e);
  });
  test('Equation.getExplanation() works correctly for double replacement',
      () {
    Equation e = Equation('Na3P(aq) + CaCl2(aq)');
    e.balance();
    print(e.getExplanation());
    print(e);
  });
  test(
      'Equation.getExplanation() works correctly for double replacement with coinciding charges',
      () {
    Equation e = Equation('Na2O + CaF2');
    e.balance();
    print(e.getExplanation());
    print(e);
  });
  test(
      'Equation.getExplanation() works correctly for double replacement of polyatomic ions',
      () {
    Equation e = Equation('NH4NO3(aq) + CaSO3(aq)');
    e.balance();
    print(e.getExplanation());
    print(e);
  });
  test('Equation.getExplanation() works correctly for neutralization', () {
    Equation e = Equation('H2CO3(aq) + Al(OH)3(aq)');
    e.balance();
    print(e.getExplanation());
    print(e);
  });
  test('Equation.getExplanation() works correctly for gas formation', () {
    Equation e = Equation('(NH4)2S(aq) + Al(OH)3(aq)');
    e.balance();
    print(e.getExplanation());
    print(e);
  });
}
