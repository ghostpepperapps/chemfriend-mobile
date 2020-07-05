part of chemistry;

/// Enum for each possible type of reaction.
enum Type {
  comp,
  compAcid,
  compBase,
  compSalt,
  decomp,
  decompAcid,
  decompBase,
  decompSalt,
  combustion,
  singleReplacement,
  doubleReplacement,
  neutralization
}

/// A class representing a chemical equation.
class Equation {
  /// The reactants of this equation.
  List<MapEntry<CompoundUnit, int>> reactants;

  /// The products of this equation.
  List<MapEntry<CompoundUnit, int>> products;

  /// A Boolean that represents whether or not the reactants of this equation
  /// are in water.
  bool rInWater;

  /// A Boolean that represents whether or not the products of this equation
  /// are in water.
  bool pInWater;

  /// The type of this reaction.
  Type type;

  /// A list of Strings containing the steps of how to find the type of this
  /// reaction.
  List<String> typeSteps = [];

  /// A list of Strings containing the steps of how to find the products of
  /// this reaction.
  List<String> productSteps = [];

  /// A list of Strings containing the steps of how to balance this reaction.
  List<String> balanceSteps = [];

  /// Constructs an equation from a String.
  ///
  /// [s] contains the reactants and optionally the products as well.
  /// For example:
  /// ```dart
  /// Equation e = new Equation('H2O(l) + CO2(g)');
  /// Equation f = new Equation('H2(g) + O2(g) => H2O(l)');
  /// ```
  Equation(String s) {
    List<MapEntry<CompoundUnit, int>> reactants = [];
    List<MapEntry<CompoundUnit, int>> products = [];
    String reactantStr;
    String productStr;
    reactantStr = (s.contains('=>')) ? s.split('=>')[0].trim() : s;
    productStr = (s.contains('=>')) ? s.split('=>')[1].trim() : null;
    for (String r in reactantStr.split('+')) {
      r = r.trim();
      int i = 0;
      while (isNumeric(r[i])) i++;
      bool hasState = r[r.length - 1].compareTo(')') == 0;
      int j = (hasState) ? r.length - 3 : r.length;
      while (isNumeric(r[j - 1])) j--;
      int number = (i != 0) ? int.parse(r.substring(0, i)) : 1;
      if (Element.exists(r.substring(i, j)))
        reactants.add(MapEntry(new Element(r.substring(i, j)), 1));
      else
        reactants.add(MapEntry(Compound(r.substring(i)), number));
    }
    if (productStr != null) {
      for (String p in productStr.split('+')) {
        p = p.trim();
        int i = 0;
        while (isNumeric(p[i])) i++;
        bool hasState = p[p.length - 1].compareTo(')') == 0;
        int j = (hasState) ? p.length - 3 : p.length;
        while (isNumeric(p[j - 1])) j--;
        int number = (i != 0) ? int.parse(p.substring(0, i)) : 1;
        if (Element.exists(p.substring(i, j)))
          products.add(MapEntry(new Element(p.substring(i, j)), 1));
        else
          products.add(MapEntry(Compound(p.substring(i)), number));
      }
    } else
      products = null;
    this.reactants = reactants;
    this.products = products;
    this.type = this.getType();
    _getInWater();
  }

  /// Constructs an equation from the [reactants] and optionally the
  /// [products].
  ///
  /// ```dart
  /// List<MapEntry<CompoundUnit, int>> reactants = [
  ///   MapEntry(Compound('H2O(l)'), 1),
  ///   MapEntry(Compound('CO2(g)'), 1)
  /// ];
  /// List<MapEntry<CompoundUnit, int>> products = [
  ///   MapEntry(Compound('H2CO3(aq)'), 1)
  /// ];
  /// Equation e = new Equation.fromUnits(reactants);
  /// Equation f = new Equation.fromUnits(reactants, products);
  /// ```
  Equation.fromUnits(List<MapEntry<CompoundUnit, int>> reactants,
      [List<MapEntry<CompoundUnit, int>> products]) {
    this.reactants = reactants;
    this.products = products;
    this.type = this.getType();
    _getInWater();
  }

  /// Finds the products of this equation and balances it based on its type.
  ///
  /// ```dart
  /// Equation e = Equation('Na3P(aq) + CaCl2(aq)');
  /// e.balance();
  /// print(e); // 2Na₃P(aq) + 3CaCl₂(aq) → 6NaCl + Ca₃P₂
  ///
  /// Equation f = Equation('H2(g) + O2(g) => H2O(l)');
  /// f.balance();
  /// print(f); // 2H₂(g) + O₂(g) → 2H₂O(l)
  /// ```
  void balance() {
    this.products =
        (this.products == null) ? this.getProducts() : this.products;
    // Balancing
    switch (this.type) {
      case Type.comp:
        List<double> counts = [1, 1, 1];
        bool halfElement = false;
        for (int i = 0; i < counts.length - 1; i++) {
          counts[i] = this.products[0].key.compoundUnits[i].value /
              this.reactants[i].key.count;
          if (counts[i] != counts[i].toInt()) halfElement = true;
        }
        if (halfElement) counts = counts.map((count) => count *= 2).toList();
        for (int i = 0; i < this.reactants.length; i++)
          this.reactants[i] =
              MapEntry(this.reactants[i].key, counts[i].toInt());
        this.products[0] = MapEntry(
            this.products[0].key, counts[counts.length - 1].toInt());
        break;
      case Type.compAcid: // No balancing required
        break;
      case Type.compBase:
        this.reactants[0] = MapEntry(
            reactants[0].key, reactants[1].key.compoundUnits[1].value);
        this.products[0] = MapEntry(
            this.products[0].key, reactants[1].key.compoundUnits[0].value);
        break;
      case Type.compSalt: // No balancing required
        break;
      case Type.decomp:
        List<double> counts = [1, 1, 1];
        bool halfElement = false;
        for (int i = 0; i < counts.length - 1; i++) {
          counts[i] = this.reactants[0].key.compoundUnits[i].value /
              this.products[i].key.count;
          if (counts[i] != counts[i].toInt()) halfElement = true;
        }
        if (halfElement) counts = counts.map((count) => count *= 2).toList();
        for (int i = 0; i < this.products.length; i++)
          this.products[i] =
              MapEntry(this.products[i].key, counts[i].toInt());
        this.reactants[0] = MapEntry(
            this.reactants[0].key, counts[counts.length - 1].toInt());
        break;
      case Type.decompAcid: // No balancing required
        break;
      case Type.decompBase:
        this.reactants[0] = MapEntry(
            this.reactants[0].key, products[1].key.compoundUnits[0].value);
        this.products[0] = MapEntry(
            this.products[0].key,
            reactants[0].value *
                reactants[0].key.compoundUnits[1].value ~/
                2);
        break;
      case Type.decompSalt: // No balancing required
        break;
      case Type.combustion:
        List<double> counts = [1, 1, 1, 1];
        counts[3] = reactants[0].key.compoundUnits[0].value.toDouble();
        counts[2] = (reactants[0].key.compoundUnits[1].value) / 2;
        counts[1] = (products[0].key.compoundUnits[1].value * counts[2] +
                products[1].key.compoundUnits[1].value * counts[3])
            .toDouble();
        if (reactants[0].key.compoundUnits.length > 2)
          counts[1] -= (reactants[0].key.compoundUnits[2].value * counts[0]);
        counts[1] /= 2;
        bool halfElement = false;
        for (double c in counts) if (c != c.toInt()) halfElement = true;
        if (halfElement) counts = counts.map((count) => count *= 2).toList();
        reactants[0] = MapEntry(reactants[0].key, counts[0].toInt());
        reactants[1] = MapEntry(reactants[1].key, counts[1].toInt());
        products[0] = MapEntry(products[0].key, counts[2].toInt());
        products[1] = MapEntry(products[1].key, counts[3].toInt());
        break;
      case Type.singleReplacement:

        // 2-dimensional list to hold number of each molecule.
        List<List<double>> counts = [new List(2), new List(2)];
        MapEntry<CompoundUnit, int> e1 =
            (reactants[0].key.isElement()) ? reactants[0] : reactants[1];
        MapEntry<CompoundUnit, int> e2 = products[0];
        MapEntry<CompoundUnit, int> c1 =
            (reactants[0].key.isCompound()) ? reactants[0] : reactants[1];
        MapEntry<CompoundUnit, int> c2 = products[1];

        // The indices of the element being replaced and the one staying the same.
        int rIndex = e1.key.metal ? 0 : 1;
        int sIndex = 1 - rIndex;

        int lcmCount = lcm(c1.key.compoundUnits[sIndex].value,
                c2.key.compoundUnits[sIndex].value)
            .abs();
        int e2Count = e2.key.isElement() ? e2.key.count : 1;

        counts[0][1] = lcmCount / c1.key.compoundUnits[sIndex].value;
        counts[1][1] = lcmCount / c2.key.compoundUnits[sIndex].value;
        counts[0][0] = (counts[1][1] * c2.key.compoundUnits[rIndex].value) /
            e1.key.count;
        counts[1][0] =
            (counts[0][1] * c1.key.compoundUnits[rIndex].value) / e2Count;

        while (counts[0][0] != counts[0][0].toInt()) {
          counts[0][0] *= 2;
          counts[0][1] *= 2;
          counts[1][0] *= 2;
          counts[1][1] *= 2;
        }
        while (counts[1][0] != counts[1][0].toInt()) {
          counts[0][0] *= 2;
          counts[0][1] *= 2;
          counts[1][0] *= 2;
          counts[1][1] *= 2;
        }

        reactants[0] = MapEntry(e1.key, counts[0][0].toInt());
        reactants[1] = MapEntry(c1.key, counts[0][1].toInt());
        products[0] = MapEntry(e2.key, counts[1][0].toInt());
        products[1] = MapEntry(c2.key, counts[1][1].toInt());
        break;
      case Type.doubleReplacement:
        // 2-dimensional list to hold number of each molecule.
        List<List<double>> counts = [new List(2), new List(2)];
        Compound r1 = reactants[0].key;
        Compound r2 = reactants[1].key;
        Compound p1 = products[0].key;
        Compound p2 = products[1].key;

        int lcmCount1 =
            lcm(r1.compoundUnits[0].value, p1.compoundUnits[0].value).abs();
        int lcmCount2 =
            lcm(p1.compoundUnits[1].value, r2.compoundUnits[1].value).abs();
        counts[1][0] = (lcmCount1 / p1.compoundUnits[0].value) *
            (lcmCount2 / p1.compoundUnits[1].value);
        counts[0][0] = (counts[1][0] * p1.compoundUnits[0].value) /
            r1.compoundUnits[0].value;
        counts[0][1] = (counts[1][0] * p1.compoundUnits[1].value) /
            r2.compoundUnits[1].value;
        counts[1][1] = (counts[0][1] * r2.compoundUnits[0].value) /
            p2.compoundUnits[0].value;

        reactants[0] = MapEntry(r1, counts[0][0].toInt());
        reactants[1] = MapEntry(r2, counts[0][1].toInt());
        products[0] = MapEntry(p1, counts[1][0].toInt());
        products[1] = MapEntry(p2, counts[1][1].toInt());
        _gasFormation();
        break;
      case Type.neutralization:
        // 2-dimensional list to hold number of each molecule.
        List<List<double>> counts = [new List(2), new List(2)];
        Compound r1 = reactants[0].key;
        Compound r2 = reactants[1].key;
        Compound p1 = products[0].key;
        Compound p2 = products[1].key;

        int acidIndex = reactants[0].key.isAcid() ? 0 : 1;
        int baseIndex = 1 - acidIndex;
        Compound acid = reactants[acidIndex].key;
        Compound base = reactants[baseIndex].key;
        int lcmCharge = lcm(acid.compoundUnits[0].value,
                base.compoundUnits[0].key.charge)
            .abs();
        counts[0][acidIndex] = lcmCharge / acid.compoundUnits[0].value;
        counts[0][baseIndex] = lcmCharge / base.compoundUnits[0].key.charge;
        counts[1][0] = acid.compoundUnits[0].value * counts[0][acidIndex];
        counts[1][1] = (counts[0][baseIndex] * base.compoundUnits[0].value) /
            p2.compoundUnits[0].value;

        reactants[0] = MapEntry(r1, counts[0][0].toInt());
        reactants[1] = MapEntry(r2, counts[0][1].toInt());
        products[0] = MapEntry(p1, counts[1][0].toInt());
        products[1] = MapEntry(p2, counts[1][1].toInt());
        break;
    }
  }

  /// Converts the appropriate products of this equation to gases.
  /// ```
  /// H₂CO₃ → H₂O(l) + CO₂(g)
  /// H₂SO₃ → H₂O(l) + SO₂(g)
  /// NH₄OH → H₂O(l) + NH₃(g)
  /// ```
  /// For example:
  /// ```dart
  /// Equation e = Equation('(NH4)2S(aq) + Al(OH)3(aq)');
  /// e.balance();
  /// print(e); // 3(NH₄)₂S(aq) + 2Al(OH)₃(aq) → 6H₂O(l) + 6NH₃(g) + Al₂S₃
  /// ```
  void _gasFormation() {
    for (int i = 0; i < products.length; i++) {
      if (products[i].key.equals('H2CO3')) {
        products[i] = MapEntry(Compound('H2O(l)'), products[i].value);
        products.insert(
            i + 1, MapEntry(Compound('CO2(g)'), products[i].value));
      } else if (products[i].key.equals('H2SO3')) {
        products[i] = MapEntry(Compound('H2O(l)'), products[i].value);
        products.insert(
            i + 1, MapEntry(Compound('SO2(g)'), products[i].value));
      } else if (products[i].key.equals('NH4OH')) {
        products[i] = MapEntry(Compound('H2O(l)'), products[i].value);
        products.insert(
            i + 1, MapEntry(Compound('NH3(g)'), products[i].value));
      }
    }
  }

  /// Returns the String representation of this equation with the correct
  /// subscripts.
  @override
  String toString() {
    String result = '';
    for (MapEntry r in this.reactants) {
      if (r.value != 1) result += r.value.toString();
      result += r.key.toString();
      result += ' + ';
    }
    result = result.substring(0, result.length - 3);
    result += ' \u2192 ';
    for (MapEntry p in this.products) {
      if (p.value != 1) result += p.value.toString();
      result += p.key.toString();
      result += ' + ';
    }
    result = result.substring(0, result.length - 3);
    return result;
  }

  /// Returns the products of an equation based on its [reactants] and [type].
  ///
  /// The count of each product is 1 because the equation has not yet been
  /// balanced.
  /// ```dart
  /// Equation e = Equation('CaO(s) + Na3P(s)');
  /// print(e.getProducts()); // [MapEntry(Ca₃P₂: 1), MapEntry(Na₂O: 1)]
  /// ```
  List<MapEntry<CompoundUnit, int>> getProducts() {
    List<MapEntry<CompoundUnit, int>> result;
    switch (this.type) {
      case Type.comp:
        bool ionic = false;
        if (reactants[0].key.metal != reactants[1].key.metal) {
          this.productSteps.add(
              """Since one of the reactants is a metal and the other is a nonmetal, the product of this equation is an ionic compound.""");
          ionic = true;
        }
        int count0;
        int count1;
        if (ionic) {
          int lcmCharge =
              lcm(reactants[0].key.charge, reactants[1].key.charge).abs();
          count0 = lcmCharge ~/
              ((reactants[0].key.charge == 0) ? 1 : reactants[0].key.charge);
          count1 = -lcmCharge ~/
              ((reactants[1].key.charge == 0) ? 1 : reactants[1].key.charge);
          this.productSteps.add(
              """Since the product of this equation is an ionic compound, the charges of each of its elements must add up to 0. First, we find the least common multiple of the charges of the elements. The least common multiple of ${this.reactants[0].key.charge} and ${this.reactants[1].key.charge} is $lcmCharge. """);
          this.productSteps.add(
              """To find the count of each element, we divide the least common multiple by the charge of each element and take the absolute value. The count of ${this.reactants[0].key.formula} is |$lcmCharge / ${this.reactants[0].key.charge}|, which equals $count0. Similarly, the count of ${this.reactants[1].key.formula} is |$lcmCharge / ${this.reactants[1].key.charge}|, which equals $count1. So, the product of this equation is: ${Compound.fromUnits([
            MapEntry(reactants[0].key, count0),
            MapEntry(reactants[1].key, count1),
          ]).toString()}. Since $count0 * ${this.reactants[0].key.charge} and $count1 * ${this.reactants[1].key.charge} add up to 0, the counts have been calculated properly.""");
        } else {
          count0 = reactants[0].key.count;
          count1 = reactants[0].key.count;
          this.productSteps.add(
              """Since the product of this equation is a molecular compound, and it was not given in the equation, we just assume that the product will be: ${Compound.fromUnits([
            MapEntry(reactants[0].key, count0),
            MapEntry(reactants[1].key, count1),
          ]).toString()}.""");
        }
        result = [
          MapEntry(
              Compound.fromUnits([
                MapEntry(reactants[0].key, count0),
                MapEntry(reactants[1].key, count1),
              ]),
              1)
        ];
        break;
      case Type.compAcid:
        Compound nmOxide = Compound.fromUnits([
          MapEntry(reactants[1].key.compoundUnits[0].key, 1),
          MapEntry(
              new Element('O'), reactants[1].key.compoundUnits[1].value + 1),
        ]);
        result = [
          MapEntry(
              Compound.fromUnits([
                MapEntry(new Element('H'), nmOxide.getCharge().abs()),
                MapEntry(nmOxide, 1),
              ], Phase.aqueous),
              1)
        ];
        this.productSteps.add(
            """Since the product of this equation is an acid, it will be made of H and ${reactants[1].key} with one extra oxygen from the water and the state will be aqueous. For the product to be balanced, the count of H needs to be enough for its charge and the charge of the other compound to add up to 0.""");
        this.productSteps.add(
            """Since the charge of $nmOxide is ${nmOxide.getCharge()}, the count of H must be ${nmOxide.getCharge().abs()}. So, the product will be: ${result[0].key}.""");
        break;
      case Type.compBase:
        _fixPolyatomicIons();
        result = [
          MapEntry(
              Compound.fromUnits([
                MapEntry(reactants[1].key.compoundUnits[0].key, 1),
                MapEntry(Compound('OH'),
                    reactants[1].key.compoundUnits[0].key.charge),
              ]),
              1)
        ];
        this.productSteps.add(
            """Since the product of this equation is a base, it will be made of ${reactants[1].key.compoundUnits[0].key.formula} and OH (hydroxide). For the product to be balanced, the count of OH needs to be enough for its charge and the charge of the other compound to add up to 0.""");
        this.productSteps.add(
            """Since the charge of ${reactants[1].key.compoundUnits[0].key.formula} is ${reactants[1].key.compoundUnits[0].key.charge} and the charge of OH is -1, the count of OH must be ${reactants[1].key.compoundUnits[0].key.charge}. So, the product (without the state) will be: ${result[0].key}.""");
        break;
      case Type.compSalt:
        result = [
          MapEntry(
              Compound.fromUnits([
                MapEntry(reactants[0].key.compoundUnits[0].key,
                    reactants[0].key.compoundUnits[0].value),
                MapEntry(reactants[1].key.compoundUnits[0].key,
                    reactants[1].key.compoundUnits[0].value),
                MapEntry(
                    new Element('O'),
                    reactants[0].key.compoundUnits[1].value +
                        reactants[1].key.compoundUnits[1].value),
              ]),
              1)
        ];
        this.productSteps.add(
            """Since the product of this equation is a salt, it will be made of ${reactants[0].key.compoundUnits[0].key.formula}, ${reactants[1].key.compoundUnits[0].key.formula} (whose counts are the same as their counts in the reactants), and O (whose count is the sum of the counts of oxygen in the reactants).""");
        this.productSteps.add(
            """So, the product (without the state) will be: ${result[0].key}.""");
        break;
      case Type.decomp:
        result = [
          MapEntry(
              new Element(reactants[0].key.compoundUnits[0].key.formula), 1),
          MapEntry(
              new Element(reactants[0].key.compoundUnits[1].key.formula), 1)
        ];
        this.productSteps.add(
            """Since this is the decomposition of a compound with 2 elements, ${reactants[0].key.compoundUnits[0].key.formula} and ${reactants[0].key.compoundUnits[1].key.formula}, the first product will be ${reactants[0].key.compoundUnits[0].key} and the second product will be ${reactants[0].key.compoundUnits[1].key}.""");
        break;
      case Type.decompAcid:
        result = [
          MapEntry(Compound('H2O(l)'), 1),
          MapEntry(
              Compound.fromUnits([
                MapEntry(reactants[0].key.compoundUnits[1].key,
                    reactants[0].key.compoundUnits[1].value),
                MapEntry(new Element('O'),
                    reactants[0].key.compoundUnits[2].value - 1),
              ]),
              1)
        ];
        break;
      case Type.decompBase:
        _fixPolyatomicIons();
        int lcmCharge = lcm(reactants[0].key.compoundUnits[0].key.charge, 2);
        result = [
          MapEntry(Compound('H2O(l)'), 1),
          MapEntry(
              Compound.fromUnits([
                MapEntry(
                    reactants[0].key.compoundUnits[0].key,
                    (-lcmCharge ~/
                            reactants[0].key.compoundUnits[0].key.charge)
                        .abs()),
                MapEntry(new Element('O'), lcmCharge.abs() ~/ 2),
              ]),
              1)
        ];
        break;
      case Type.decompSalt:
        Compound metalOxide = Compound.fromUnits([
          MapEntry(reactants[0].key.compoundUnits[0].key,
              reactants[0].key.compoundUnits[0].value),
          MapEntry(
              new Element('O'),
              (reactants[0].key.compoundUnits[0].value *
                      reactants[0].key.compoundUnits[0].key.charge) ~/
                  2),
        ]);
        Compound nonmetalOxide = Compound.fromUnits([
          MapEntry(reactants[0].key.compoundUnits[1].key,
              reactants[0].key.compoundUnits[1].value),
          MapEntry(
              new Element('O'),
              reactants[0].key.compoundUnits[2].value -
                  metalOxide.compoundUnits[1].value),
        ]);
        result = [MapEntry(metalOxide, 1), MapEntry(nonmetalOxide, 1)];
        break;
      case Type.combustion:
        result = [
          MapEntry(Compound('H2O(g)'), 1),
          MapEntry(Compound('CO2(g)'), 1)
        ];
        break;
      case Type.singleReplacement:
        _fixPolyatomicIons();
        int eIndex = (reactants[0].key.isElement()) ? 0 : 1;
        Element e = reactants[eIndex].key;
        Compound c = reactants[1 - eIndex].key;
        // The indices of the element being replaced and the one staying the same.
        int rIndex = e.metal ? 0 : 1;
        int sIndex = 1 - rIndex;
        List<int> counts = new List(2);
        if (c.ionic) {
          List<List<int>> charges = [
            [
              e.charge,
            ],
            [
              c.compoundUnits[sIndex].key.charge,
              c.compoundUnits[rIndex].key.charge
            ]
          ];
          int lcmCharge = lcm(charges[0][0], charges[1][0]);
          counts[0] =
              (lcmCharge ~/ ((charges[1][0] == 0) ? 1 : charges[1][0]))
                  .abs();
          counts[1] =
              (lcmCharge ~/ ((charges[0][0] == 0) ? 1 : charges[0][0]))
                  .abs();
        } else {
          counts[0] = c.compoundUnits[0].key.count;
          counts[1] = e.count;
        }
        if (e.metal) {
          result = [
            MapEntry(c.compoundUnits[rIndex].key, 1),
            MapEntry(
                Compound.fromUnits([
                  MapEntry(e, counts[1]),
                  MapEntry(c.compoundUnits[sIndex].key, counts[0])
                ]),
                1)
          ];
        } else {
          result = [
            MapEntry(c.compoundUnits[rIndex].key, 1),
            MapEntry(
                Compound.fromUnits([
                  MapEntry(c.compoundUnits[sIndex].key, counts[0]),
                  MapEntry(e, counts[1]),
                ]),
                1)
          ];
        }
        break;
      case Type.doubleReplacement:
        _fixPolyatomicIons();
        List<List<int>> counts = [new List(2), new List(2)];
        List<List<int>> charges = [
          [
            reactants[0].key.compoundUnits[0].key.charge,
            reactants[0].key.compoundUnits[1].key.charge
          ],
          [
            reactants[1].key.compoundUnits[0].key.charge,
            reactants[1].key.compoundUnits[1].key.charge
          ]
        ];
        if (reactants[0].key.ionic && reactants[1].key.ionic) {
          int lcmCharge1 = lcm(charges[0][0], charges[1][1]).abs();
          int lcmCharge2 = lcm(charges[1][0], charges[0][1]).abs();
          counts[0][0] =
              lcmCharge1 ~/ ((charges[0][0] == 0) ? 1 : charges[0][0]);
          counts[0][1] =
              -lcmCharge1 ~/ ((charges[1][1] == 0) ? 1 : charges[1][1]);
          counts[1][0] =
              lcmCharge2 ~/ ((charges[1][0] == 0) ? 1 : charges[1][0]);
          counts[1][1] =
              -lcmCharge2 ~/ ((charges[0][1] == 0) ? 1 : charges[0][1]);
        } else {
          counts[0] = [
            reactants[0].key.compoundUnits[0].value,
            reactants[0].key.compoundUnits[1].value
          ];
          counts[1] = [
            reactants[1].key.compoundUnits[0].value,
            reactants[1].key.compoundUnits[1].value
          ];
        }
        result = [
          MapEntry(
              Compound.fromUnits([
                MapEntry(
                    reactants[0].key.compoundUnits[0].key, counts[0][0]),
                MapEntry(
                    reactants[1].key.compoundUnits[1].key, counts[0][1]),
              ]),
              1),
          MapEntry(
              Compound.fromUnits([
                MapEntry(
                    reactants[1].key.compoundUnits[0].key, counts[1][0]),
                MapEntry(
                    reactants[0].key.compoundUnits[1].key, counts[1][1]),
              ]),
              1),
        ];
        break;
      case Type.neutralization:
        _fixPolyatomicIons();
        Compound acid =
            reactants[0].key.isAcid() ? reactants[0].key : reactants[1].key;
        Compound base =
            reactants[0].key.isBase() ? reactants[0].key : reactants[1].key;
        int otherCharge =
            acid.compoundUnits[0].value ~/ acid.compoundUnits[1].value;
        int lcmCharge =
            lcm(otherCharge, base.compoundUnits[0].key.charge).abs();
        result = [
          MapEntry(Compound('H2O(l)'), 1),
          MapEntry(
              Compound.fromUnits([
                MapEntry(base.compoundUnits[0].key,
                    lcmCharge ~/ base.compoundUnits[0].key.charge),
                MapEntry(
                    acid.compoundUnits[1].key, lcmCharge ~/ otherCharge),
              ]),
              1),
        ];
    }
    result = _getStates(result);
    return result;
  }

  /// Returns the type of an equation based on its [reactants].
  ///
  /// ```dart
  /// Equation e = Equation('H2(g) + O2(g) => H2O(l)');
  /// print(e.getType()); // Type.comp
  /// ```
  Type getType() {
    if (reactants.length == 1) {
      // Decomposition
      if (reactants[0].key.isElement()) return null;
      if (reactants[0].key.compoundUnits.length == 2 &&
          reactants[0].key.compoundUnits[0].key.isElement() &&
          reactants[0].key.compoundUnits[1].key.isElement()) {
        typeSteps.add(
            """Since this equation has one reactant with two elements, it must be Simple Decomposition.""");
        return Type.decomp;
      }
      if (reactants[0].key.compoundUnits[0].key.equals('H')) {
        if (reactants[0].key.compoundUnits[2].key.equals('O')) {
          if (!reactants[0].key.compoundUnits[1].key.metal) {
            typeSteps.add(
                """Since this equation has one reactant which is an acid, it must be Decomposition of an Acid.""");
            return Type.decompAcid;
          }
        }
      } else if (reactants[0].key.compoundUnits[0].key.metal) {
        if (reactants[0].key.compoundUnits[1].key.formula.compareTo('O') ==
                0 &&
            reactants[0].key.compoundUnits[2].key.formula.compareTo('H') ==
                0) {
          typeSteps.add(
              """Since this equation has one reactant which is a base, is must be Decomposition of a Base.""");
          return Type.decompBase;
        }
        if (!reactants[0].key.compoundUnits[1].key.metal) {
          if (reactants[0].key.compoundUnits[2].key.equals('O')) {
            typeSteps.add(
                """Since this equation has one reactant which is a combination of a metal, nonmetal, and oxygen, it must be Decomposition of a Salt.""");
            return Type.decompSalt;
          }
        }
      }
    }
    if (reactants[0].key.isElement() && reactants[1].key.isElement()) {
      typeSteps.add(
          """Since this equation has two reactants, each of which are elements, it must be Simple Composition.""");
      return Type.comp; // Simple Composition
    } else if (reactants[0].key.isElement() &&
        reactants[1].key.isCompound()) {
      typeSteps.add(
          """Since this equation has two reactants, one of which is an element and one of which is a compound, it must be a Single Replacement.""");
      return Type.singleReplacement;
    } else if (reactants[0].key.isCompound() &&
        reactants[1].key.isElement()) {
      if (reactants[0].key.compoundUnits[0].key.isElement()) {
        if (reactants[0].key.compoundUnits[0].key.equals('C') &&
            reactants[0].key.compoundUnits[1].key.equals('H') &&
            reactants[1].key.equals('O')) {
          typeSteps.add(
              """Since this equation has two reactants, one of which has carbon and hydrogen, and the other of which is oxygen, it must be Hydrocarbon Combustion.""");
          return Type.combustion; // Hydrocarbon Combustion
        }
      }
    } else if (reactants[0].key.isAcid() && reactants[1].key.isBase() ||
        reactants[0].key.isBase() && reactants[1].key.isAcid()) {
      typeSteps.add(
          """Since this equation has two reactants, one of which is an acid and the other of which is a base, it must be Double Replacement (Neutralization).""");
      return Type.neutralization;
    } else if (reactants[0].key.isCompound() &&
        reactants[1].key.isCompound()) {
      if (reactants[0].key.formula.compareTo('H2O(l)') == 0) {
        if (reactants[1].key.compoundUnits[1].key.equals('O')) {
          if (!reactants[1].key.compoundUnits[0].key.metal) {
            typeSteps.add(
                """Since this equation has two reactants, one of which is water and the other of which is the combination of a nonmetal and oxygen (making it a nonmetal oxide), it must be Composition of an Acid.""");
            return Type.compAcid;
          }
          typeSteps.add(
              """Since this equation has two reactants, one of which is water and the other of which is the combination of a metal and oxygen (making it a metal oxide), it must be Composition of a Base.""");
          return Type.compBase;
        }
      } else if (reactants[0].key.compoundUnits[1].key.equals('O') &&
          reactants[1].key.compoundUnits[1].key.equals('O')) {
        typeSteps.add(
            """Since this equation has two reactants, one of which is the combination of metal and oxygen (making it a metal oxide) and the other of which is the combination of a nonmetal and oxygen (making it a nonmetal oxide), it must be Composition of a Salt.""");
        return Type.compSalt;
      }
      typeSteps.add(
          """Since this equation has two reactants, both of which are compounds, it must be Double Replacement.""");
      return Type.doubleReplacement;
    }
    return null;
  }

  /// Updates this equation's properties based on whether or not its reactants
  /// and products are in water.
  void _getInWater() {
    this.rInWater = [
      Type.decompBase,
      Type.decompSalt,
      Type.singleReplacement,
      Type.doubleReplacement,
      Type.neutralization
    ].contains(this.type);
    this.pInWater = [
      Type.compBase,
      Type.compSalt,
      Type.singleReplacement,
      Type.doubleReplacement,
      Type.neutralization
    ].contains(this.type);
  }

  /// Updates each reactant and product's state based on [rInWater] and
  /// [pInWater].
  List<MapEntry<CompoundUnit, int>> _getStates(
      List<MapEntry<CompoundUnit, int>> products) {
    if (this.rInWater) {
      for (Compound c in this
          .reactants
          .map((cu) => cu.key)
          .where((cu) => (cu.isCompound() && cu.ionic)))
        if (c.isCompound()) {
          c.state = c.getWaterState();
        }
    } else {
      for (Compound c in reactants
          .map((cu) => cu.key)
          .where((cu) => (cu.isCompound() && cu.ionic)))
        c.state = Phase.solid;
    }
    if (this.pInWater) {
      for (Compound c in products
          .map((cu) => cu.key)
          .where((cu) => (cu.isCompound() && cu.ionic)))
        if (c.isCompound()) {
          c.state = c.getWaterState();
        }
    } else {
      for (Compound c in products
          .map((cu) => cu.key)
          .where((cu) => (cu.isCompound() && cu.ionic)))
        c.state = Phase.solid;
    }
    return products;
  }

  /// Creates a separate compound unit for each polyatomic ion of the
  /// reactants at the [indices].
  ///
  /// ```dart
  /// Compound([MapEntry(N: 1), MapEntry(H: 3)])
  /// → Compound([MapEntry(NH₃: 1)])
  /// ```
  void _fixPolyatomicIons() {
    for (int i = 0; i < reactants.length; i++) {
      MapEntry<CompoundUnit, int> r = reactants[i];
      if (r.key.isCompound() && r.key.compoundUnits.length > 2) {
        if (r.key.compoundUnits[0].key.equals('N') &&
            r.key.compoundUnits[0].value == 1 &&
            r.key.compoundUnits[1].key.equals('H') &&
            r.key.compoundUnits[1].value == 4) {
          reactants[i] = MapEntry(
              Compound.fromUnits([
                MapEntry(Compound('NH4'), 1),
                MapEntry(
                    Compound.fromUnits(r.key.compoundUnits.sublist(2)), 1)
              ], r.key.state),
              1);
          r = reactants[i];
        }
        if (r.key.compoundUnits.length > 2)
          reactants[i] = MapEntry(
              Compound.fromUnits([
                MapEntry(r.key.compoundUnits[0].key,
                    r.key.compoundUnits[0].value),
                MapEntry(
                    Compound.fromUnits(r.key.compoundUnits.sublist(1)), 1)
              ], r.key.state),
              1);
      }
    }
  }

  /// Returns the formatted explanation of how to find the type and product(s)
  /// of this equation as well as how to balance it.
  String getExplanation() {
    String result = 'Type\n';
    this.typeSteps.forEach((String step) => result += (step + '\n'));
    result += '\nProduct(s)\n';
    this.productSteps.forEach((String step) => result += (step + '\n'));
    result += '\nBalancing\n';
    this.balanceSteps.forEach((String step) => result += (step + '\n'));
    return result;
  }
}
