part of chemistry;

// TODO: Make compAcid product have (aq) state
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
    this.products =
        (this.products == null) ? _getProducts(reactants, type) : this.products;
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
        this.products[0] =
            MapEntry(this.products[0].key, counts[counts.length - 1].toInt());
        break;
      case Type.compAcid: // No balancing required
        break;
      case Type.compBase:
        this.reactants[0] =
            MapEntry(reactants[0].key, reactants[1].key.compoundUnits[1].value);
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
          this.products[i] = MapEntry(this.products[i].key, counts[i].toInt());
        this.reactants[0] =
            MapEntry(this.reactants[0].key, counts[counts.length - 1].toInt());
        break;
      case Type.decompAcid: // No balancing required
        break;
      case Type.decompBase:
        this.reactants[0] = MapEntry(
            this.reactants[0].key, products[1].key.compoundUnits[0].value);
        this.products[0] = MapEntry(this.products[0].key,
            reactants[0].value * reactants[0].key.compoundUnits[1].value ~/ 2);
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
        // TODO: Handle this case.
        break;
      case Type.doubleReplacement:
        // TODO: Handle this case.
        break;
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
              ]),
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
              ]),
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
              Element.from(reactants[0].key.compoundUnits[0].key.formula), 1),
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
                    (-lcmCharge ~/ reactants[0].key.compoundUnits[0].key.charge)
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
        if (reactants[0].key.metal)
          return [
            MapEntry(
                Compound.fromUnits([
                  MapEntry(reactants[0].key,
                      reactants[1].key.compoundUnits[0].value),
                  MapEntry(reactants[1].key.compoundUnits[1].key,
                      reactants[1].key.compoundUnits[1].value)
                ]),
                1),
            MapEntry(reactants[1].key.compoundUnits[0].key, 1),
          ];
        else
          return [
            MapEntry(reactants[1].key.compoundUnits[1].key, 1),
            MapEntry(
                Compound.fromUnits([
                  MapEntry(reactants[1].key.compoundUnits[0].key,
                      reactants[1].key.compoundUnits[0].value),
                  MapEntry(reactants[0].key,
                      reactants[1].key.compoundUnits[1].value),
                ]),
                1),
          ];
        break;
      case Type.doubleReplacement:
        var counts = [new List(2), new List(2)];
        var charges = [
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
                MapEntry(reactants[0].key.compoundUnits[0].key, counts[0][0]),
                MapEntry(reactants[1].key.compoundUnits[1].key, counts[0][1]),
              ]),
              1),
          MapEntry(
              Compound.fromUnits([
                MapEntry(reactants[1].key.compoundUnits[0].key, counts[1][0]),
                MapEntry(reactants[1].key.compoundUnits[0].key, counts[1][1]),
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
          if (reactants[0].key.compoundUnits[1].key.formula.compareTo('OH') ==
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
    } else if (reactants[0].key.isCompound() && reactants[1].key.isCompound()) {
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
