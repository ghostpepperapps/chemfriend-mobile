part of chemistry;

// TODO: Add gas formation
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
  doubleReplacement
}

/// A class representing a chemical equation.
class Equation {
  List<MapEntry> reactants;
  List<MapEntry> products;
  bool inWater;
  Type type;

  /// Constructs an equation from a String.
  ///
  /// [s] contains the reactants and optionally the products as well.
  Equation(String s) {
    List<MapEntry> reactants = [];
    List<MapEntry> products = [];
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
        reactants.add(MapEntry(Element.from(r.substring(i, j)), 1));
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
          products.add(MapEntry(Element.from(p.substring(i, j)), 1));
        else
          products.add(MapEntry(Compound(p.substring(i)), number));
      }
    } else
      products = null;
    this.reactants = reactants;
    this.products = products;
  }

  /// Constructs an equation from the [reactants] and [products].
  Equation.fromUnits(List<MapEntry> reactants, [List<MapEntry> products]) {
    this.reactants = reactants;
    this.products = products;
  }

  /// Balances this equation based on its type.
  void balance() {
    type = _getType(this.reactants);
    this.products = (this.products == null)
        ? _getProducts(reactants, type)
        : this.products;
    // Balancing
    switch (type) {
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
              this.products[i].value;
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
        MapEntry<dynamic, dynamic> e1 =
            (reactants[0].key.isElement()) ? reactants[0] : reactants[1];
        MapEntry<dynamic, dynamic> e2 =
            (products[0].key.isElement()) ? products[0] : products[1];
        MapEntry<dynamic, dynamic> c1 =
            (reactants[0].key.isCompound()) ? reactants[0] : reactants[1];
        MapEntry<dynamic, dynamic> c2 =
            (products[0].key.isCompound()) ? products[0] : products[1];

        // The indices of the element being replaced and the one staying the same.
        int rIndex = e1.key.metal ? 0 : 1;
        int sIndex = 1 - rIndex;

        int lcmCount = lcm(c1.key.compoundUnits[sIndex].value,
                c2.key.compoundUnits[sIndex].value)
            .abs();

        counts[0][1] = lcmCount / c1.key.compoundUnits[sIndex].value;
        counts[1][1] = lcmCount / c2.key.compoundUnits[sIndex].value;
        counts[0][0] = (counts[1][1] * c2.key.compoundUnits[rIndex].value) /
            e1.key.count;
        counts[1][0] = (counts[0][1] * c1.key.compoundUnits[rIndex].value) /
            e2.key.count;

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

        if ((r1.isAcid() && r2.isBase()) || (r2.isAcid() && r1.isBase())) {
          int acidIndex = reactants[0].key.isAcid() ? 0 : 1;
          int baseIndex = 1 - acidIndex;
          Compound acid = reactants[acidIndex].key;
          Compound base = reactants[baseIndex].key;
          int otherCharge =
              acid.compoundUnits[0].value ~/ acid.compoundUnits[1].value;
          int lcmCharge = lcm(acid.compoundUnits[0].value,
                  base.compoundUnits[0].key.charge)
              .abs();
          counts[0][0] = lcmCharge / acid.compoundUnits[0].value;
          counts[0][1] = lcmCharge / base.compoundUnits[0].key.charge;
          counts[1][0] = acid.compoundUnits[0].value * counts[0][0];
          counts[1][1] = (counts[0][1] * base.compoundUnits[0].value) /
              p2.compoundUnits[0].value;
        } else {
          int lcmCount1 =
              lcm(r1.compoundUnits[0].value, p1.compoundUnits[0].value)
                  .abs();
          int lcmCount2 =
              lcm(p1.compoundUnits[1].value, r2.compoundUnits[1].value)
                  .abs();
          counts[1][0] = (lcmCount1 / p1.compoundUnits[0].value) *
              (lcmCount2 / p1.compoundUnits[1].value);
          counts[0][0] = (counts[1][0] * p1.compoundUnits[0].value) /
              r1.compoundUnits[0].value;
          counts[0][1] = (counts[1][0] * p1.compoundUnits[1].value) /
              r2.compoundUnits[1].value;
          counts[1][1] = (counts[0][1] * r2.compoundUnits[0].value) /
              p2.compoundUnits[0].value;
        }
        reactants[0] = MapEntry(r1, counts[0][0].toInt());
        reactants[1] = MapEntry(r2, counts[0][1].toInt());
        products[0] = MapEntry(p1, counts[1][0].toInt());
        products[1] = MapEntry(p2, counts[1][1].toInt());
        _gasFormation();
        break;
    }
  }

  /// Converts the appropriate products of this equation to gases.
  /// ```
  /// H₂CO₃ → H₂O(l) + CO₂(g)
  /// H₂SO₃ → H₂O(l) + SO₂(g)
  /// NH₄OH → H₂O(l) + NH₃(g)
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

  /// Returns the String representation of this equation.
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
  static List<MapEntry> _getProducts(List<MapEntry> reactants, Type type) {
    switch (type) {
      case Type.comp:
        bool ionic = false;
        if (reactants[0].key.metal != reactants[1].key.metal) ionic = true;
        int count0;
        int count1;
        if (ionic) {
          int lcmCharge =
              lcm(reactants[0].key.charge, reactants[1].key.charge).abs();
          count0 = lcmCharge ~/
              ((reactants[0].key.charge == 0) ? 1 : reactants[0].key.charge);
          count1 = -lcmCharge ~/
              ((reactants[1].key.charge == 0) ? 1 : reactants[1].key.charge);
        } else {
          count0 = reactants[0].key.count;
          count1 = reactants[0].key.count;
        }
        return [
          MapEntry(
              Compound.fromUnits([
                MapEntry(reactants[0].key, count0),
                MapEntry(reactants[1].key, count1),
              ]),
              1)
        ];
        break;
      case Type.compAcid:
        return [
          MapEntry(
              Compound.fromUnits([
                MapEntry(Element.from('H'), 2),
                MapEntry(reactants[1].key.compoundUnits[0].key, 1),
                MapEntry(Element.from('O'),
                    reactants[1].key.compoundUnits[1].value + 1),
              ], Phase.aqueous),
              1)
        ];
        break;
      case Type.compBase:
        return [
          MapEntry(
              Compound.fromUnits([
                MapEntry(reactants[1].key.compoundUnits[0].key, 1),
                MapEntry(Compound('OH'),
                    reactants[1].key.compoundUnits[0].key.charge),
              ], Phase.aqueous),
              1)
        ];
        break;
      case Type.compSalt:
        return [
          MapEntry(
              Compound.fromUnits([
                MapEntry(reactants[0].key.compoundUnits[0].key,
                    reactants[0].key.compoundUnits[0].value),
                MapEntry(reactants[1].key.compoundUnits[0].key,
                    reactants[1].key.compoundUnits[0].value),
                MapEntry(
                    Element.from('O'),
                    reactants[0].key.compoundUnits[1].value +
                        reactants[1].key.compoundUnits[1].value),
              ]),
              1)
        ];
        break;
      case Type.decomp:
        return [
          MapEntry(
              Element.from(reactants[0].key.compoundUnits[0].key.formula),
              1),
          MapEntry(
              Element.from(reactants[0].key.compoundUnits[1].key.formula), 1)
        ];
        break;
      case Type.decompAcid:
        return [
          MapEntry(Compound('H2O(l)'), 1),
          MapEntry(
              Compound.fromUnits([
                MapEntry(reactants[0].key.compoundUnits[1].key,
                    reactants[0].key.compoundUnits[1].value),
                MapEntry(Element.from('O'),
                    reactants[0].key.compoundUnits[2].value - 1),
              ], Phase.gas),
              1)
        ];
        break;
      case Type.decompBase:
        int lcmCharge = lcm(reactants[0].key.compoundUnits[0].key.charge, 2);
        return [
          MapEntry(Compound('H2O(l)'), 1),
          MapEntry(
              Compound.fromUnits([
                MapEntry(
                    reactants[0].key.compoundUnits[0].key,
                    (-lcmCharge ~/
                            reactants[0].key.compoundUnits[0].key.charge)
                        .abs()),
                MapEntry(Element.from('O'), lcmCharge.abs() ~/ 2),
              ], Phase.gas),
              1)
        ];
        break;
      case Type.decompSalt:
        Compound metalOxide = Compound.fromUnits([
          MapEntry(reactants[0].key.compoundUnits[0].key,
              reactants[0].key.compoundUnits[0].value),
          MapEntry(
              Element.from('O'),
              (reactants[0].key.compoundUnits[0].value *
                      reactants[0].key.compoundUnits[0].key.charge) ~/
                  2),
        ]);
        Compound nonmetalOxide = Compound.fromUnits([
          MapEntry(reactants[0].key.compoundUnits[1].key,
              reactants[0].key.compoundUnits[1].value),
          MapEntry(
              Element.from('O'),
              reactants[0].key.compoundUnits[2].value -
                  metalOxide.compoundUnits[1].value),
        ]);
        return [MapEntry(metalOxide, 1), MapEntry(nonmetalOxide, 1)];
        break;
      case Type.combustion:
        return [
          MapEntry(Compound('H2O(g)'), 1),
          MapEntry(Compound('CO2(g)'), 1)
        ];
        break;
      case Type.singleReplacement:
        Element e = (reactants[0].key.isElement())
            ? reactants[0].key
            : reactants[1].key;
        Compound c = (reactants[0].key.isCompound())
            ? reactants[0].key
            : reactants[1].key;
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
          return [
            MapEntry(c.compoundUnits[rIndex].key, 1),
            MapEntry(
                Compound.fromUnits([
                  MapEntry(e, counts[1]),
                  MapEntry(c.compoundUnits[sIndex].key, counts[0])
                ]),
                1)
          ];
        } else {
          return [
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
        if ((reactants[0].key.isAcid() && reactants[1].key.isBase()) ||
            (reactants[1].key.isAcid() && reactants[0].key.isBase())) {
          int acidIndex = reactants[0].key.isAcid() ? 0 : 1;
          int baseIndex = 1 - acidIndex;
          Compound acid = reactants[acidIndex].key;
          Compound base = reactants[baseIndex].key;
          if (acid.compoundUnits.length > 2) {
            reactants[acidIndex] = MapEntry(
                Compound.fromUnits([
                  MapEntry(acid.compoundUnits[0].key,
                      acid.compoundUnits[0].value),
                  MapEntry(
                      Compound.fromUnits(acid.compoundUnits.sublist(1)), 1)
                ], Phase.aqueous),
                1);
            acid = reactants[acidIndex].key;
          }
          if (base.compoundUnits.length > 2) {
            reactants[baseIndex] = MapEntry(
                Compound.fromUnits([
                  MapEntry(base.compoundUnits[0].key,
                      base.compoundUnits[0].value),
                  MapEntry(
                      Compound.fromUnits(base.compoundUnits.sublist(1)), 1)
                ], Phase.aqueous),
                1);
            acid = reactants[acidIndex].key;
          }
          int otherCharge =
              acid.compoundUnits[0].value ~/ acid.compoundUnits[1].value;
          int lcmCharge =
              lcm(otherCharge, base.compoundUnits[0].key.charge).abs();
          return [
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
        return [
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
    }
    return null;
  }

  /// Returns the type of an equation based on its [reactants].
  static Type _getType(List<MapEntry> reactants) {
    if (reactants.length == 1) {
      // Decomposition
      if (reactants[0].key.isElement()) return null;
      if (reactants[0].key.compoundUnits[0].key.equals('H')) {
        if (reactants[0].key.compoundUnits[2].key.equals('O')) {
          if (!reactants[0].key.compoundUnits[1].key.metal)
            return Type.decompAcid;
        }
      } else if (reactants[0].key.compoundUnits[0].key.metal) {
        if (reactants[0].key.compoundUnits[1].key.isCompound()) {
          if (reactants[0]
                  .key
                  .compoundUnits[1]
                  .key
                  .formula
                  .compareTo('OH') ==
              0) return Type.decompBase;
        }
        if (!reactants[0].key.compoundUnits[1].key.metal) {
          if (reactants[0].key.compoundUnits[2].key.equals('O')) {
            return Type.decompSalt;
          }
        }
      }
      if (reactants[0].key.compoundUnits.length == 2) return Type.decomp;
    }
    if (reactants[0].key.isElement() && reactants[1].key.isElement())
      return Type.comp; // Simple Composition
    else if (reactants[0].key.isElement() && reactants[1].key.isCompound())
      return Type.singleReplacement;
    else if (reactants[0].key.isCompound() && reactants[1].key.isElement()) {
      if (reactants[0].key.compoundUnits[0].key.isElement()) {
        if (reactants[0].key.compoundUnits[0].key.equals('C') &&
            reactants[0].key.compoundUnits[1].key.equals('H') &&
            reactants[1].key.equals('O'))
          return Type.combustion; // Hydrocarbon Combustion
      }
    } else if (reactants[0].key.isCompound() &&
        reactants[1].key.isCompound()) {
      if (reactants[0].key.formula.compareTo('H2O(l)') == 0) {
        if (reactants[1].key.compoundUnits[1].key.equals('O')) {
          if (!reactants[1].key.compoundUnits[0].key.metal)
            return Type.compAcid;
          return Type.compBase;
        }
      } else if (reactants[0].key.compoundUnits[1].key.equals('O') &&
          reactants[1].key.compoundUnits[1].key.equals('O')) {
        return Type.compSalt;
      }
      return Type.doubleReplacement;
    }
    return null;
  }
}
