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
    this.productSteps.add("So, the equation (before balancing) is: $this.");
    // Balancing
    switch (this.type) {
      case Type.comp:

        // A list to keep track of the count of each reactant/product.
        List<List<double>> counts = [
          [1, 1],
          [1]
        ];

        // Loop through each reactant and find the counts needed to make the
        // total number of each element the same on both sides.
        for (int i = 0; i < 2; i++) {
          counts[0][i] = this.products[0].key.compoundUnits[i].value /
              this.reactants[i].key.count;
          this.balanceSteps.add(
              "Since the number of ${this.reactants[i].key} on the reactants side is ${this.reactants[i].key.count} and the number on the products side is ${this.products[0].key.compoundUnits[i].value}, the count of ${this.reactants[i].key.formula} will be ${counts[0][i] == counts[0][i].toInt() ? counts[0][i].toInt() : counts[0][i]}.");
        }
        // If the counts of the elements are not whole, multiply everything by
        // 2.
        while (counts[0][0] != counts[0][0].toInt()) {
          counts[0][0] *= 2;
          counts[0][1] *= 2;
          counts[1][0] *= 2;
          this.balanceSteps.add(
              "Since the count of ${this.reactants[0].key} is not a whole number, we multiply the counts of both reactants and the product by 2.");
        }
        while (counts[0][1] != counts[0][1].toInt()) {
          counts[0][0] *= 2;
          counts[0][1] *= 2;
          counts[1][0] *= 2;
          this.balanceSteps.add(
              "Since the count of ${this.reactants[1].key} is not a whole number, we multiply the counts of both reactants and the product by 2.");
        }

        // Set the counts of the reactants and product.
        for (int i = 0; i < this.reactants.length; i++)
          this.reactants[i] =
              MapEntry(this.reactants[i].key, counts[0][i].toInt());
        this.products[0] =
            MapEntry(this.products[0].key, counts[1][0].toInt());
        break;
      case Type.compAcid: // No balancing required
        this.balanceSteps.add(
            "Since this is the composition of an acid, balancing is not required.");
        break;
      case Type.compBase:
        // Match each water molecule to one oxygen from the metal oxide.
        this.reactants[0] = MapEntry(
            reactants[0].key, reactants[1].key.compoundUnits[1].value);
        this.balanceSteps.add(
            "In order to form the hydroxide for the base, we need to match each water molecule with one oxygen atom from the metal oxide. Since there ${this.reactants[0].value == 1 ? 'is' : 'are'} ${this.reactants[0].value} oxygen atom${this.reactants[0].value == 1 ? '' : 's'}, the count of water will also be ${this.reactants[0].value}.");
        // Set the number of base molecules to be the number of molecules of
        // metal in the metal oxide.
        this.products[0] = MapEntry(
            this.products[0].key, reactants[1].key.compoundUnits[0].value);
        this.balanceSteps.add(
            "In order for the count of ${this.reactants[1].key.compoundUnits[0].key.formula} (the metal) to be the same on both sides, the count of ${this.products[0].key} (the base) should be the the same as the count of ${this.reactants[1].key.compoundUnits[0].key.formula} in ${this.reactants[1].key} (the metal oxide). So, the count of ${this.products[0].key} is ${this.products[0].value}.");
        break;
      case Type.compSalt: // No balancing required
        this.balanceSteps.add(
            "Since this is the composition of a salt, balancing is not required.");
        break;
      case Type.decomp:
        // The same method used for Simple Composition, but reversed.
        List<List<double>> counts = [
          [1],
          [1, 1]
        ];
        for (int i = 0; i < 2; i++) {
          counts[1][i] = this.reactants[0].key.compoundUnits[i].value /
              this.products[i].key.count;
          this.balanceSteps.add(
              "Since the number of ${this.products[i].key.formula} on the reactants side is ${this.reactants[0].key.compoundUnits[i].value} and the number on the products side is ${this.products[i].key.count}, the count of ${this.products[i].key} will be ${counts[1][i] == counts[1][i].toInt() ? counts[1][i].toInt() : counts[1][i]}.");
        }
        while (counts[1][0] != counts[1][0].toInt()) {
          counts[0][0] *= 2;
          counts[1][0] *= 2;
          counts[1][1] *= 2;
          this.balanceSteps.add(
              "Since the count of ${this.products[0].key} is not a whole number, we multiply the counts of both reactants and the product by 2.");
        }
        while (counts[1][1] != counts[1][1].toInt()) {
          counts[0][0] *= 2;
          counts[1][0] *= 2;
          counts[1][1] *= 2;
          this.balanceSteps.add(
              "Since the count of ${this.products[1].key} is not a whole number, we multiply the counts of both reactants and the product by 2.");
        }
        for (int i = 0; i < this.products.length; i++)
          this.products[i] =
              MapEntry(this.products[i].key, counts[1][i].toInt());
        this.reactants[0] =
            MapEntry(this.reactants[0].key, counts[0][0].toInt());
        break;
      case Type.decompAcid: // No balancing required
        this.balanceSteps.add(
            "Since this is the decomposition of an acid, balancing is not required.");
        break;
      case Type.decompBase:
        // The same method used for Composition of a Base, but reversed.
        this.reactants[0] = MapEntry(
            this.reactants[0].key, products[1].key.compoundUnits[0].value);
        this.balanceSteps.add(
            "In order for the count of ${this.products[1].key.compoundUnits[0].key.formula} (the metal) to be the same on both sides, the count of ${this.reactants[0].key} (the base) should be the the same as the count of ${this.products[1].key.compoundUnits[0].key.formula} in ${this.products[1].key} (the metal oxide). So, the count of ${this.reactants[0].key} is ${this.reactants[0].value}.");
        this.products[0] = MapEntry(
            this.products[0].key,
            reactants[0].value *
                reactants[0].key.compoundUnits[1].value ~/
                2);
        this.balanceSteps.add(
            "In order to form the hydroxide for the base, we need to match each water molecule with one oxygen atom from the metal oxide. Since there ${this.products[0].value == 1 ? 'is' : 'are'} ${this.products[0].value} oxygen atom${this.products[0].value == 1 ? '' : 's'}, the count of water will also be ${this.products[0].value}.");
        break;
      case Type.decompSalt: // No balancing required
        this.balanceSteps.add(
            "Since this is the decomposition of a salt, balancing is not required.");
        break;
      case Type.combustion:
        // A list to keep track of the count of each reactant/product.
        List<List<double>> counts = [
          [1, 1],
          [1, 1]
        ];
        // Set the count of carbon dioxide to the number of carbons in the
        // hydrocarbon.
        counts[1][1] = reactants[0].key.compoundUnits[0].value.toDouble();
        this.balanceSteps.add(
            "Since there are ${counts[1][1].toInt()} carbons in ${reactants[0].key}, there will also be ${counts[1][1].toInt()} CO₂(g) molecule${counts[1][1] == 1 ? '' : 's'}. This is because each CO₂(g) molecule has 1 carbon atom.");
        // Set the count of water to the number of hydrogens in the
        // hydrocarbon divided by 2 since H₂O has 2 hydrogens.
        counts[1][0] = (reactants[0].key.compoundUnits[1].value) / 2;
        this.balanceSteps.add(
            "Since there are ${reactants[0].key.compoundUnits[1].value} hydrogens in ${reactants[0].key}, there will be ${reactants[0].key.compoundUnits[1].value} / 2 = ${counts[1][0].toInt()} H₂O(g) molecule${counts[1][0] == 1 ? '' : 's'}. This is because each H₂O(g) molecule has 2 hydrogen atoms.");
        // Set the count of oxygen to be the total number of oxygen in the
        // products, minus the number of oxygens in the hydrocarbon, divided
        // by two since there are two oxygens in O₂.
        counts[0][1] =
            (products[0].key.compoundUnits[1].value * counts[1][0] +
                    products[1].key.compoundUnits[1].value * counts[1][1])
                .toDouble();
        this.balanceSteps.add(
            "Since there are ${products[0].key.compoundUnits[1].value} * ${counts[1][0].toInt()} + ${products[1].key.compoundUnits[1].value} * ${counts[1][1].toInt()} = ${counts[0][1].toInt()} oxygen atoms on the products side, there should be ${counts[0][1].toInt()} oxygen atoms on the reactants side.");
        if (reactants[0].key.compoundUnits.length > 2) {
          counts[0][1] -=
              (reactants[0].key.compoundUnits[2].value * counts[0][0]);
          this.balanceSteps.add(
              "Since ${reactants[0].key} contains oxygen, the count of oxygen atoms in the molecules of oxygen plus the count of oxygen in ${reactants[0].key} needs to add up to the count of oxygen on the products side. In other words, the number of oxygen atoms in O₂(g) needs to be ${(products[0].key.compoundUnits[1].value * counts[1][0] + products[1].key.compoundUnits[1].value * counts[1][1]).toInt()} - ${reactants[0].key.compoundUnits[2].value} = ${counts[0][1].toInt()}.");
        }

        counts[0][1] /= 2;
        this.balanceSteps.add(
            "Because there are two oxygen atoms in each molecule of O₂(g), the count of O₂(g) should be ${(counts[0][1] * 2).toInt()} / 2 = ${counts[0][1] == counts[0][1].toInt() ? counts[0][1].toInt() : counts[0][1]}.");

        // If the count of oxygen is non-whole, multiply each count by 2.
        if (counts[0][1] != counts[0][1].toInt()) {
          this.balanceSteps.add(
              "So, the count of ${this.reactants[0].key} is ${counts[0][0].toInt()}, the count of ${this.reactants[1].key} is ${counts[0][1]}, the count of ${this.products[0].key} is ${counts[1][0].toInt()}, and the count of ${this.products[1].key} is ${counts[1][1].toInt()}.");
          counts[0][0] *= 2;
          counts[0][1] *= 2;
          counts[1][0] *= 2;
          counts[1][1] *= 2;
          this.balanceSteps.add(
              "Since ${counts[0][1] / 2} is not a whole number, we multiply the count of each reactant and each product by 2 so that the count of O₂(g) becomes whole.");
        }

        // Set the counts of each reactant and product.
        reactants[0] = MapEntry(reactants[0].key, counts[0][0].toInt());
        reactants[1] = MapEntry(reactants[1].key, counts[0][1].toInt());
        products[0] = MapEntry(products[0].key, counts[1][0].toInt());
        products[1] = MapEntry(products[1].key, counts[1][1].toInt());
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

        // Find the least common multiple of the count of the element that
        // stays in the compound.
        int lcmCount = lcm(c1.key.compoundUnits[sIndex].value,
                c2.key.compoundUnits[sIndex].value)
            .abs();
        this.balanceSteps.add(
            "First, we need to make the number of ${c1.key.compoundUnits[sIndex].key.formula} equal on both sides. To do this, we find the least common multiple of the number of ${c1.key.compoundUnits[sIndex].key.formula} atoms on both sides. The least common multiple of ${c1.key.compoundUnits[sIndex].value} (from ${c1.key}) and ${c2.key.compoundUnits[sIndex].value} (from ${c2.key}) is $lcmCount. We then divide this number by the number of ${c1.key.compoundUnits[sIndex].key.formula} atoms in each compound to get the counts of the compounds that will make the number of ${c1.key.compoundUnits[sIndex].key.formula} atoms the same on both sides.");
        int e2Count = e2.key.isElement() ? e2.key.count : 1;

        // Set the count of the compound in the reactants to be the least
        // common multiple divided by the count of the element that stays in
        // the compound on the reactants side and on the products side.
        counts[0][1] = lcmCount / c1.key.compoundUnits[sIndex].value;
        // Set the count of the compound in the products to be the least
        // common multiple divided by the count of the element that stays in
        // the compound.
        counts[1][1] = lcmCount / c2.key.compoundUnits[sIndex].value;
        this.balanceSteps.add(
            "So, the count of ${c1.key} should be $lcmCount / ${c1.key.compoundUnits[sIndex].value} = ${counts[0][1].toInt()} and the count of ${c2.key} should be $lcmCount / ${c2.key.compoundUnits[sIndex].value} = ${counts[1][1].toInt()}.");
        this.balanceSteps.add(
            "Next, we find the counts of the individual elements by dividing their count in the compound on the other side of the equation by their count as an element.");
        // Set the count of the element in the reactants to be the total
        // number of the element in the products side divided by the count of
        // the element.
        counts[0][0] = (counts[1][1] * c2.key.compoundUnits[rIndex].value) /
            e1.key.count;
        this.balanceSteps.add(
            "Since the number of ${e1.key.formula} atoms in ${c2.key} is ${c2.key.compoundUnits[rIndex].value} and the number of ${e1.key.formula} atoms in ${e1.key} is ${e1.key.count}, the count of ${e1.key} should be (${counts[1][1].toInt()} * ${c2.key.compoundUnits[rIndex].value}) / ${e1.key.count} = ${counts[0][0] == counts[0][0].toInt() ? counts[0][0].toInt() : counts[0][0]}.");
        // Set the count of the element in the products to be the total
        // number of the element in the reactants side divided by the count of
        // the element.
        counts[1][0] =
            (counts[0][1] * c1.key.compoundUnits[rIndex].value) / e2Count;
        this.balanceSteps.add(
            "Since the number of ${e2.key.formula} atoms in ${c1.key} is ${c1.key.compoundUnits[rIndex].value} and the number of ${e2.key.formula} atoms in ${e2.key} is $e2Count, the count of ${e2.key} should be (${counts[0][1].toInt()} * ${c1.key.compoundUnits[rIndex].value}) / $e2Count = ${counts[1][0] == counts[1][0].toInt() ? counts[1][0].toInt() : counts[1][0]}.");

        // If the counts of the elements are not whole, multiply everything by
        // 2.
        while (counts[0][0] != counts[0][0].toInt()) {
          this.balanceSteps.add(
              "So, the count of ${e1.key} is ${counts[0][0]}, the count of ${c1.key} is ${counts[0][1]}, the count of ${e2.key} is ${counts[1][0] == counts[1][0].toInt() ? counts[1][0].toInt() : counts[1][0]}, and the count of ${c2.key} is ${counts[1][1].toInt()}.");
          counts[0][0] *= 2;
          counts[0][1] *= 2;
          counts[1][0] *= 2;
          counts[1][1] *= 2;
          this.balanceSteps.add(
              "Since ${counts[0][0] / 2} is not a whole number, we multiply the count of each reactant and each product by 2 so that the count of ${e1.key} becomes whole.");
        }
        while (counts[1][0] != counts[1][0].toInt()) {
          this.balanceSteps.add(
              "So, the count of ${e1.key} is ${counts[0][0]}, the count of ${c1.key} is ${counts[0][1].toInt()}, the count of ${e2.key} is ${counts[1][0] == counts[1][0].toInt() ? counts[1][0].toInt() : counts[1][0]}, and the count of ${c2.key} is ${counts[1][1].toInt()}.");
          counts[0][0] *= 2;
          counts[0][1] *= 2;
          counts[1][0] *= 2;
          counts[1][1] *= 2;
          this.balanceSteps.add(
              "Since ${counts[1][0] / 2} is not a whole number, we multiply the count of each reactant and each product by 2 so that the count of ${e2.key} becomes whole.");
        }

        // Set the counts of each reactant and product.
        reactants[0] = MapEntry(e1.key, counts[0][0].toInt());
        reactants[1] = MapEntry(c1.key, counts[0][1].toInt());
        products[0] = MapEntry(e2.key, counts[1][0].toInt());
        products[1] = MapEntry(c2.key, counts[1][1].toInt());
        break;
      case Type.doubleReplacement:
        // 2-dimensional list to hold number of each molecule.
        List<List<int>> counts = [
          [1, 1],
          [1, 1]
        ];
        Compound r1 = reactants[0].key;
        Compound r2 = reactants[1].key;
        Compound p1 = products[0].key;
        Compound p2 = products[1].key;

        // For each element, find the count of the element on each side, then
        // multiply the counts on each side in order to make the count of the
        // element the same.
        this.balanceSteps.add(
            "In order to balance this equation, we will go through each element and find the number of atoms of the element on each side of the equation. Then, we will multiply the counts of the compounds that contain the element in such a way that the total number of atoms of the element is the same on both sides. We can do this using the following formula for each compound: new count = old count * (least common multiple / number of atoms of the element).");

        // Find the least common multiple of the count of the first element on
        // both sides.
        int lcmCountA =
            lcm(r1.compoundUnits[0].value, p1.compoundUnits[0].value).abs();
        counts[0][0] *= lcmCountA ~/ r1.compoundUnits[0].value;
        counts[1][0] *= lcmCountA ~/ p1.compoundUnits[0].value;
        this.balanceSteps.add(
            "Starting with ${r1.compoundUnits[0].key.formula}, its count in $r1 is ${r1.compoundUnits[0].value} and its count in $p1 is ${p1.compoundUnits[0].value}. The least common multiple of ${r1.compoundUnits[0].value} and ${p1.compoundUnits[0].value} is $lcmCountA. So, the count of $r1 is multiplied by $lcmCountA / ${r1.compoundUnits[0].value} = ${counts[0][0].toInt()} and the count of $p1 is multiplied by $lcmCountA / ${p1.compoundUnits[0].value} = ${counts[1][0].toInt()}. So, the new count of $r1 is 1 * ${counts[0][0].toInt()} = ${counts[0][0].toInt()} and the new count of $p1 is 1 * ${counts[1][0].toInt()} = ${counts[1][0].toInt()}.");

        // Find the least common multiple of the count of the second element on
        // both sides.
        int lcmCountB = lcm(counts[0][0] * r1.compoundUnits[1].value,
                p2.compoundUnits[1].value)
            .abs();
        this.balanceSteps.add(
            "The count of ${r1.compoundUnits[1].key.formula} in $r1 is ${counts[0][0]} * ${r1.compoundUnits[1].value} = ${counts[0][0] * r1.compoundUnits[1].value} and its count in $p2 is 1 * ${p2.compoundUnits[1].value} = ${p2.compoundUnits[1].value}. The least common multiple of ${counts[0][0] * r1.compoundUnits[1].value} and ${p2.compoundUnits[1].value} is $lcmCountB. So, the count of $r1 is multiplied by $lcmCountB / ${counts[0][0] * r1.compoundUnits[1].value} = ${lcmCountB ~/ (counts[0][0] * r1.compoundUnits[1].value)} and the count of $p2 is multiplied by $lcmCountB / ${p2.compoundUnits[1].value} = ${lcmCountB ~/ p2.compoundUnits[1].value}. The new count of $r1 is ${counts[0][0].toInt()} * ${lcmCountB ~/ (counts[0][0] * r1.compoundUnits[1].value)} = ${counts[0][0].toInt() * lcmCountB ~/ (counts[0][0] * r1.compoundUnits[1].value)}, and the new count of $p2 is 1 * ${lcmCountB ~/ p2.compoundUnits[1].value} = ${lcmCountB ~/ p2.compoundUnits[1].value}.");
        counts[0][0] *=
            lcmCountB ~/ (counts[0][0] * r1.compoundUnits[1].value);
        counts[1][1] *= lcmCountB ~/ p2.compoundUnits[1].value;

        // Find the least common multiple of the count of the third element on
        // both sides.
        int lcmCountC = lcm(r2.compoundUnits[0].value,
                counts[1][1] * p2.compoundUnits[0].value)
            .abs();
        this.balanceSteps.add(
            "The count of ${r2.compoundUnits[0].key.formula} in $r2 is 1 * ${r2.compoundUnits[0].value} = ${r2.compoundUnits[0].value} and its count in $p2 is ${counts[1][1]} * ${p2.compoundUnits[0].value} = ${counts[1][1] * p2.compoundUnits[0].value}. The least common multiple of ${r2.compoundUnits[0].value} and ${counts[1][1] * p2.compoundUnits[0].value} is $lcmCountC. So, the count of $r2 is multiplied by $lcmCountC / ${r2.compoundUnits[0].value} = ${lcmCountC ~/ r2.compoundUnits[0].value} and the count of $p2 is multiplied by $lcmCountC / ${counts[1][1] * p2.compoundUnits[0].value} = ${lcmCountC ~/ (counts[1][1] * p2.compoundUnits[0].value)}. The new count of $r2 is 1 * ${lcmCountC ~/ r2.compoundUnits[0].value} = ${lcmCountC ~/ r2.compoundUnits[0].value}, and the new count of $p2 is ${counts[1][1]} * ${lcmCountC ~/ (counts[1][1] * p2.compoundUnits[0].value)} = ${lcmCountC ~/ (counts[1][1] * p2.compoundUnits[0].value)}.");
        counts[0][1] *= lcmCountC ~/ r2.compoundUnits[0].value;
        counts[1][1] *=
            lcmCountC ~/ (counts[1][1] * p2.compoundUnits[0].value);

        // Find the least common multiple of the count of the fourth element
        // on both sides.
        int lcmCountD = lcm(counts[0][1] * r2.compoundUnits[1].value,
                counts[1][0] * p1.compoundUnits[1].value)
            .abs();
        this.balanceSteps.add(
            "The count of ${r2.compoundUnits[1].key.formula} in $r2 is ${counts[0][1]} * ${r2.compoundUnits[1].value} = ${counts[0][1] * r2.compoundUnits[1].value} and its count in $p1 is ${counts[1][0]} * ${p1.compoundUnits[1].value} = ${counts[1][0] * p1.compoundUnits[1].value}. The least common multiple of ${counts[0][1] * r2.compoundUnits[1].value} and ${counts[1][0] * p1.compoundUnits[1].value} is $lcmCountD. So, the count of $r2 is multiplied by $lcmCountD / ${counts[0][1] * r2.compoundUnits[1].value} = ${lcmCountD ~/ (counts[0][1] * r2.compoundUnits[1].value)} and the count of $p1 is multiplied by $lcmCountD / ${counts[1][0] * p1.compoundUnits[1].value} = ${lcmCountD ~/ (counts[1][0] * p1.compoundUnits[1].value)}. The new count of $r2 is ${counts[0][1]} * ${lcmCountD ~/ (counts[0][1] * r2.compoundUnits[1].value)} = ${counts[0][1] * (lcmCountD ~/ (counts[0][1] * r2.compoundUnits[1].value))}, and the new count of $p1 is ${counts[1][0]} * ${lcmCountD ~/ (counts[1][0] * p1.compoundUnits[1].value)} = ${counts[1][0] * (lcmCountD ~/ (counts[1][0] * p1.compoundUnits[1].value))}.");
        counts[0][1] *=
            lcmCountD ~/ (counts[0][1] * r2.compoundUnits[1].value);
        counts[1][0] *=
            lcmCountD ~/ (counts[1][0] * p1.compoundUnits[1].value);

        // Set the counts of each reactant and product.
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

        // Find the least common multiple of the charges of the nonmetal oxide
        // in the acid and the charge of the metal in the base.
        int lcmCharge = lcm(acid.compoundUnits[0].value,
                base.compoundUnits[0].key.charge)
            .abs();
        this.balanceSteps.add(
            "First, we balance the acid and the base by making sure that the number of H atoms and OH ions are the same on both sides. To do this, we need to make sure that the number of H atoms in $acid, the number of OH ions in $base, and the number of H₂O(l) molecules are equal to each other. To do this, we use the least common multiple of the number of H atoms and the number of OH ions.");
        this.balanceSteps.add(
            "The least common multiple of ${acid.compoundUnits[0].value} and ${base.compoundUnits[0].key.charge} is $lcmCharge.");

        // Set the counts of the acid and base so that the charges of the
        // elements in the salt will be balanced.
        counts[0][acidIndex] = lcmCharge / acid.compoundUnits[0].value;
        counts[0][baseIndex] = lcmCharge / base.compoundUnits[0].key.charge;

        // Set the count of water so that it has the same number of hydrogens
        // as the acid.
        counts[1][0] = lcmCharge.toDouble();
        this.balanceSteps.add(
            "The count of $acid will be $lcmCharge / ${acid.compoundUnits[0].value} =  ${lcmCharge ~/ acid.compoundUnits[0].value}, and the count of $base will be $lcmCharge / ${base.compoundUnits[0].key.charge} =  ${lcmCharge ~/ base.compoundUnits[0].key.charge}. Since there are now $lcmCharge H atoms and $lcmCharge OH ions on the reactants side, and each molecule of H₂O(l) is made of 1 H atom and 1 OH ion, the count of H₂O(l) will also be $lcmCharge.");

        // Set the count of the salt so that the count of the metal is the
        // same on both sides.
        counts[1][1] = (counts[0][baseIndex] * base.compoundUnits[0].value) /
            p2.compoundUnits[0].value;
        this.balanceSteps.add(
            "We determine the count of $p2 by making sure that the number of ${p2.compoundUnits[0].key.formula} atoms is the same on both sides. Since there are ${counts[0][baseIndex].toInt()} $base molecules, and ${base.compoundUnits[0].value} ${p2.compoundUnits[0].key.formula} atom${base.compoundUnits[0].value == 1 ? '' : 's'} per molecule, there are a total of ${counts[0][baseIndex].toInt()} * ${base.compoundUnits[0].value} = ${(counts[0][baseIndex] * base.compoundUnits[0].value).toInt()} ${p2.compoundUnits[0].key.formula} atoms in the reactants. Since there are ${p2.compoundUnits[0].value} ${p2.compoundUnits[0].key.formula} atom${p2.compoundUnits[0].value == 1 ? '' : 's'} per $p2 molecule, and ${(counts[0][baseIndex] * base.compoundUnits[0].value).toInt()} ${p2.compoundUnits[0].key.formula} atom${(counts[0][baseIndex] * base.compoundUnits[0].value).toInt() == 1 ? '' : 's'}, there must be ${(counts[0][baseIndex] * base.compoundUnits[0].value).toInt()} / ${p2.compoundUnits[0].value} = ${counts[1][1].toInt()} $p2 molecule${counts[1][1] == 1 ? '' : 's'}.");

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
        this.balanceSteps.add(
            "Since one of the products of this equation is H₂CO₃, it decomposes into H₂O(l) and CO₂(g). The counts of these compounds are the same as the count of H₂CO₃ in the original equation.");
      } else if (products[i].key.equals('H2SO3')) {
        products[i] = MapEntry(Compound('H2O(l)'), products[i].value);
        products.insert(
            i + 1, MapEntry(Compound('SO2(g)'), products[i].value));
        this.balanceSteps.add(
            "Since one of the products of this equation is H₂SO₃, it decomposes into H₂O(l) and SO₂(g). The counts of these compounds are the same as the count of H₂SO₃ in the original equation.");
      } else if (products[i].key.equals('NH4OH')) {
        products[i] = MapEntry(Compound('H2O(l)'), products[i].value);
        products.insert(
            i + 1, MapEntry(Compound('NH3(g)'), products[i].value));
        this.balanceSteps.add(
            "Since one of the products of this equation is NH₄OH, it decomposes into H₂O(l) and NH₃(g). The counts of these compounds are the same as the count of NH₄OH in the original equation.");
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
              "Since one of the reactants is a metal and the other is a nonmetal, the product of this equation is an ionic compound.");
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
              "Since the product of this equation is an ionic compound, the charges of each of its elements must add up to 0. First, we find the least common multiple of the charges of the elements. The least common multiple of ${this.reactants[0].key.charge} and ${this.reactants[1].key.charge} is $lcmCharge. ");
          this.productSteps.add(
                  "To find the count of each element, we divide the least common multiple by the charge of each element and take the absolute value. The count of ${this.reactants[0].key.formula} is |$lcmCharge / ${this.reactants[0].key.charge}|, which equals $count0. Similarly, the count of ${this.reactants[1].key.formula} is |$lcmCharge / ${this.reactants[1].key.charge}|, which equals $count1. So, the product of this equation is: ${Compound.fromUnits([
                MapEntry(reactants[0].key, count0),
                MapEntry(reactants[1].key, count1),
              ]).toString()}. Since $count0 * ${this.reactants[0].key.charge} and $count1 * ${this.reactants[1].key.charge} add up to 0, the counts have been calculated properly.");
        } else {
          count0 = reactants[0].key.count;
          count1 = reactants[0].key.count;
          this.productSteps.add(
                  "Since the product of this equation is a molecular compound, and it was not given in the equation, we just assume that the product will be: ${Compound.fromUnits([
                MapEntry(reactants[0].key, count0),
                MapEntry(reactants[1].key, count1),
              ]).toString()}.");
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
            "Since the product of this equation is an acid, it will be made of H and ${reactants[1].key} with one extra oxygen from the water and the state will be aqueous. For the product to be balanced, the count of H needs to be enough for its charge and the charge of the other compound to add up to 0.");
        this.productSteps.add(
            "Since the charge of $nmOxide is ${nmOxide.getCharge()}, the count of H must be ${nmOxide.getCharge().abs()}. So, the product will be: ${result[0].key}.");
        break;
      case Type.compBase:
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
            "Since the product of this equation is a base, it will be made of ${reactants[1].key.compoundUnits[0].key.formula} and OH (hydroxide). For the product to be balanced, the count of OH needs to be enough for its charge and the charge of the other compound to add up to 0.");
        this.productSteps.add(
            "Since the charge of ${reactants[1].key.compoundUnits[0].key.formula} is ${reactants[1].key.compoundUnits[0].key.charge} and the charge of OH is -1, the count of OH must be ${reactants[1].key.compoundUnits[0].key.charge}. So, the product (without the state) will be: ${result[0].key}.");
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
            "Since the product of this equation is a salt, it will be made of ${reactants[0].key.compoundUnits[0].key.formula}, ${reactants[1].key.compoundUnits[0].key.formula} (whose counts are the same as their counts in the reactants), and O (whose count is the sum of the counts of oxygen in the reactants).");
        this.productSteps.add(
            "So, the product (without the state) will be: ${result[0].key}.");
        break;
      case Type.decomp:
        result = [
          MapEntry(
              new Element(reactants[0].key.compoundUnits[0].key.formula), 1),
          MapEntry(
              new Element(reactants[0].key.compoundUnits[1].key.formula), 1)
        ];
        this.productSteps.add(
            "Since this is the decomposition of a compound with 2 elements, ${reactants[0].key.compoundUnits[0].key.formula} and ${reactants[0].key.compoundUnits[1].key.formula}, the first product will be ${reactants[0].key.compoundUnits[0].key} and the second product will be ${reactants[0].key.compoundUnits[1].key}.");
        break;
      case Type.decompAcid:
        result = [
          MapEntry(Compound('H2O(l)'), 1),
          MapEntry(
              Compound.fromUnits([
                MapEntry(
                    reactants[0]
                        .key
                        .compoundUnits[1]
                        .key
                        .compoundUnits[0]
                        .key,
                    reactants[0].key.compoundUnits[1].value),
                MapEntry(
                    new Element('O'),
                    reactants[0]
                            .key
                            .compoundUnits[1]
                            .key
                            .compoundUnits[1]
                            .value -
                        1),
              ]),
              1)
        ];
        this.productSteps.add(
            "Since this is the decomposition of an acid, the first product will be H₂O(l) and the second product will be a compound with ${reactants[0].key.compoundUnits[1].key.formula} and O with a count of 1 less than the count of O in the acid. So, the second product (without the state) will be ${result[1].key}.");
        break;
      case Type.decompBase:
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
        this.productSteps.add(
            "Since this is the decomposition of a base, the first product will be H₂O(l) and the second product will be a compound with ${reactants[0].key.compoundUnits[0].key.formula} and O with a count of 1 less than the count of OH in the base. So, the second product (without the state) will be ${result[1].key}.");
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
          MapEntry(
              reactants[0].key.compoundUnits[1].key.compoundUnits[0].key,
              reactants[0].key.compoundUnits[1].key.compoundUnits[0].value),
          MapEntry(
              new Element('O'),
              reactants[0].key.compoundUnits[1].key.compoundUnits[1].value -
                  metalOxide.compoundUnits[1].value),
        ]);
        result = [MapEntry(metalOxide, 1), MapEntry(nonmetalOxide, 1)];
        this.productSteps.add(
            "Since this is the decomposition of a salt, the first product will be a metal oxide (the combination of the metal and oxygen) and the second product will be a nonmetal oxide (the combination of the nonmetal and oxygen).");
        this.productSteps.add(
            "To find the count of oxygen in the metal oxide we take the absolute value of the charge of the metal (${reactants[0].key.compoundUnits[0].key.charge}) divided by the charge of O (-2) to get ${metalOxide.compoundUnits[1].value}.");
        this.productSteps.add(
            "We then add the remaining oxygens to the nonmetal oxide by subtracting the count of the oxygen in the metal oxide from the count of the oxygen in the salt: ${reactants[0].key.compoundUnits[1].key.compoundUnits[1].value} - ${metalOxide.compoundUnits[1].value} = ${nonmetalOxide.compoundUnits[1].value}.");
        break;
      case Type.combustion:
        result = [
          MapEntry(Compound('H2O(g)'), 1),
          MapEntry(Compound('CO2(g)'), 1)
        ];
        this.productSteps.add(
            "Since this is a hydrocarbon combustion reaction, the products will be H₂O(g) (water vapour) and CO₂(g) (carbon dioxide).");
        break;
      case Type.singleReplacement:
        this.productSteps.add(
            "Since this reaction is single replacement, the first product will be an element and the second product will be a compound. ");
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
          this.productSteps.add(
              "Since one reactant is an ionic compound, the product which will be a compound must also be ionic. Since ${c.compoundUnits[rIndex].key.formula} is being replaced with ${e.formula}, the ionic compound will be made of ${c.compoundUnits[sIndex].key.formula} and ${e.formula}.");
          this.productSteps.add(
              "To find the counts of each of the elements, we first find the least common multiple of the absolute value of the charges of the elements. In this case, the least common multiple of ${charges[1][0].abs()} and ${charges[0][0].abs()} is $lcmCharge.");
          this.productSteps.add(
              "We then divide this number by the absolute value of the charge of each element to find the count of each element. So, the count of ${c.compoundUnits[sIndex].key.formula} is $lcmCharge / ${charges[1][0].abs()} = ${counts[0]}. Similarly, the count of ${e.formula} is $lcmCharge / ${charges[0][0].abs()} = ${counts[1]}.");
          this.productSteps.add(
              "As a result, the charges of each element multiplied by their counts now sum to 0.");
        } else {
          counts[0] = c.compoundUnits[0].key.count;
          counts[1] = e.count;
          this.productSteps.add(
              "Since one reactant is a molecular compound, the product which will be a compound must also be molecular. As a result, the charges do not need to be balanced.");
          this.productSteps.add(
              "So, we assume that the count of ${c.compoundUnits[1].key.formula} is ${c.compoundUnits[1].value} and the count of ${e.formula} is ${e.count}.");
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
        this.productSteps.add(
            "As a result, the first product is ${result[0].key} and the second product (without the state) is ${result[1].key}.");
        break;
      case Type.doubleReplacement:
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
          this.productSteps.add(
              "Since the reactants are ionic, the products will also be ionic. The first product will be made of ${reactants[0].key.compoundUnits[0].key.formula} and ${reactants[1].key.compoundUnits[1].key.formula} and the second product will be made of ${reactants[1].key.compoundUnits[0].key.formula} and ${reactants[0].key.compoundUnits[1].key.formula}.");
          this.productSteps.add(
              "To find the counts of the first product, we find the least common multiple of the absolute values of the charges of ${reactants[0].key.compoundUnits[0].key.formula} and ${reactants[1].key.compoundUnits[1].key.formula}. The least common multiple of ${reactants[0].key.compoundUnits[0].key.charge.abs()} and ${reactants[1].key.compoundUnits[1].key.charge.abs()} is $lcmCharge1.");
          this.productSteps.add(
              "We then divide the least common multiple by the charges of ${reactants[0].key.compoundUnits[0].key.formula} and ${reactants[1].key.compoundUnits[1].key.formula} and then take the absolute value to get their counts. The count of ${reactants[0].key.compoundUnits[0].key.formula} is |$lcmCharge1 / ${reactants[0].key.compoundUnits[0].key.charge}| = ${counts[0][0]}. Similarly, the count of ${reactants[1].key.compoundUnits[1].key.formula} is |$lcmCharge1 / ${reactants[1].key.compoundUnits[1].key.charge}| = ${counts[0][1]}.");
          this.productSteps.add(
              "Similarly for the second product, we find that the least common multiple of the absolute values of the charges of ${reactants[1].key.compoundUnits[0].key.formula} and ${reactants[0].key.compoundUnits[1].key.formula} is $lcmCharge2.");
          this.productSteps.add(
              "Again, we divide the least common multiple by the charges of ${reactants[1].key.compoundUnits[0].key.formula} and ${reactants[0].key.compoundUnits[1].key.formula} and then take the absolute value. The count of ${reactants[1].key.compoundUnits[0].key.formula} is |$lcmCharge2 / ${reactants[1].key.compoundUnits[0].key.charge}| = ${counts[1][0]}. Similarly, the count of ${reactants[0].key.compoundUnits[1].key.formula} is |$lcmCharge2 / ${reactants[0].key.compoundUnits[1].key.charge}| = ${counts[1][1]}.");
          this.productSteps.add(
              "Using this method, we can ensure that the charges of the anion and the cation in each ionic compound sum to 0.");
        } else {
          counts[0] = [
            reactants[0].key.compoundUnits[0].value,
            reactants[0].key.compoundUnits[1].value
          ];
          counts[1] = [
            reactants[1].key.compoundUnits[0].value,
            reactants[1].key.compoundUnits[1].value
          ];
          this.productSteps.add(
              "Since the reactants are molecular compounds, the products will also be molecular compounds. We assume that the counts of each element will stay the same as they were before the reaction.");
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
        this.productSteps.add(
            "As a result, the first product (without the state) is ${result[0].key} and the second product (without the state) is ${result[1].key}.");
        break;
      case Type.neutralization:
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
        this.productSteps.add(
            "Since this is a neutralization reaction, the first product will be H₂O(l) and the second product will be the combination of the cation of the base (${base.compoundUnits[0].key.formula}) and the anion from the acid (${acid.compoundUnits[1].key.formula}).");
        this.productSteps.add(
            "Since the second product will be ionic, we must calculate the least common multiple of the absolute values of the charges of ${base.compoundUnits[0].key.formula} and ${acid.compoundUnits[1].key.formula}. The least common multiple of ${base.compoundUnits[0].key.charge} and $otherCharge is $lcmCharge.");
        this.productSteps.add(
            "We then divide the least common multiple by the charges of the cation and anion, then take the absolute value to find the counts. The count of ${base.compoundUnits[0].key.formula} will be |$lcmCharge / ${base.compoundUnits[0].key.charge}| = ${result[1].key.compoundUnits[0].value}. Similarly, the count of ${acid.compoundUnits[1].key.formula} will be |$lcmCharge / ${acid.compoundUnits[1].key.charge}| = ${result[1].key.compoundUnits[1].value}.");
        this.productSteps.add(
            "As a result, the first product is H₂O(l) and the second product (without the state) is ${result[1].key}.");
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
    _fixPolyatomicIons();
    if (reactants.length == 1) {
      // Decomposition
      if (reactants[0].key.isElement()) return null;
      if (reactants[0].key.compoundUnits.length == 2 &&
          reactants[0].key.compoundUnits[0].key.isElement() &&
          reactants[0].key.compoundUnits[1].key.isElement()) {
        typeSteps.add(
            "Since this equation has one reactant with two elements, it must be Simple Decomposition.");
        return Type.decomp;
      }
      if (reactants[0].key.isAcid()) {
        typeSteps.add(
            "Since this equation has one reactant which is an acid, it must be Decomposition of an Acid.");
        return Type.decompAcid;
      } else if (reactants[0].key.compoundUnits[0].key.metal) {
        if (reactants[0].key.compoundUnits[1].key.equals('OH')) {
          typeSteps.add(
              "Since this equation has one reactant which is a base, it must be Decomposition of a Base.");
          return Type.decompBase;
        }
        if (!reactants[0]
            .key
            .compoundUnits[1]
            .key
            .compoundUnits[0]
            .key
            .metal) {
          if (reactants[0]
              .key
              .compoundUnits[1]
              .key
              .compoundUnits[1]
              .key
              .equals('O')) {
            typeSteps.add(
                "Since this equation has one reactant which is a combination of a metal, nonmetal, and oxygen, it must be Decomposition of a Salt.");
            return Type.decompSalt;
          }
        }
      }
    }
    if (reactants[0].key.isElement() && reactants[1].key.isElement()) {
      typeSteps.add(
          "Since this equation has two reactants, each of which are elements, it must be Simple Composition.");
      return Type.comp; // Simple Composition
    } else if (reactants[0].key.isCompound() &&
        reactants[1].key.isElement() &&
        reactants[0].key.compoundUnits[0].key.equals('C') &&
        reactants[0].key.compoundUnits[1].key.equals('H') &&
        reactants[1].key.equals('O')) {
      typeSteps.add(
          "Since this equation has two reactants, one of which has carbon and hydrogen, and the other of which is oxygen, it must be Hydrocarbon Combustion.");
      return Type.combustion; // Hydrocarbon Combustion
    } else if ((reactants[0].key.isElement() &&
            reactants[1].key.isCompound()) ||
        (reactants[0].key.isCompound() && reactants[1].key.isElement())) {
      typeSteps.add(
          "Since this equation has two reactants, one of which is an element and one of which is a compound, it must be Single Replacement.");
      return Type.singleReplacement;
    } else if (reactants[0].key.isAcid() && reactants[1].key.isBase() ||
        reactants[0].key.isBase() && reactants[1].key.isAcid()) {
      typeSteps.add(
          "Since this equation has two reactants, one of which is an acid and the other of which is a base, it must be Double Replacement (Neutralization).");
      return Type.neutralization;
    } else if (reactants[0].key.isCompound() &&
        reactants[1].key.isCompound()) {
      if (reactants[0].key.formula.compareTo('H2O(l)') == 0) {
        if (reactants[1].key.compoundUnits[1].key.equals('O')) {
          if (!reactants[1].key.compoundUnits[0].key.metal) {
            typeSteps.add(
                "Since this equation has two reactants, one of which is water and the other of which is the combination of a nonmetal and oxygen (making it a nonmetal oxide), it must be Composition of an Acid.");
            return Type.compAcid;
          }
          typeSteps.add(
              "Since this equation has two reactants, one of which is water and the other of which is the combination of a metal and oxygen (making it a metal oxide), it must be Composition of a Base.");
          return Type.compBase;
        }
      } else if (reactants[0].key.compoundUnits[1].key.equals('O') &&
          reactants[1].key.compoundUnits[1].key.equals('O')) {
        typeSteps.add(
            "Since this equation has two reactants, one of which is the combination of metal and oxygen (making it a metal oxide) and the other of which is the combination of a nonmetal and oxygen (making it a nonmetal oxide), it must be Composition of a Salt.");
        return Type.compSalt;
      }
      typeSteps.add(
          "Since this equation has two reactants, both of which are compounds, it must be Double Replacement.");
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
      List<Compound> ionicReactants = this
          .reactants
          .map((r) => r.key)
          .where((cu) => (cu.isCompound() && cu.ionic))
          .map((cu) => cu.toCompound())
          .toList();
      if (ionicReactants.length > 0)
        this.productSteps.add(
            "Since the type of this equation is ${typeToString[this.type]}, the reactants are in water.");
      this.reactants.forEach((r) {
        if (r.key.isCompound() && r.key.ionic) {
          Compound c = r.key.toCompound().withoutState();
          this.productSteps.add(
              "Since $c is ionic and one of the reactants of this equation, we need to check the solubility chart for its state.");
          r.key.state = c.getWaterState();
          this.productSteps.add(
              "From the solubility chart, we can see that the state of $c should be ${phaseToString[r.key.state]}.");
        }
      });
    } else {
      this.productSteps.add(
          "Since the type of this equation is ${typeToString[this.type]}, the reactants are not in water; so, each of the ionic reactants must be solid.");
      for (Compound c in reactants
          .map((r) => r.key)
          .where((cu) => (cu.isCompound() && cu.ionic)))
        c.state = Phase.solid;
    }
    if (this.pInWater) {
      List<Compound> ionicProducts = products
          .map((p) => p.key)
          .where((cu) => (cu.isCompound() && cu.ionic))
          .map((cu) => cu.toCompound())
          .toList();
      if (ionicProducts.length > 0)
        this.productSteps.add(
            "Since the type of this equation is ${typeToString[this.type]}, the products are in water.");
      products.forEach((p) {
        if (p.key.isCompound() && p.key.ionic) {
          Compound c = p.key.toCompound().withoutState();
          this.productSteps.add(
              "Since $c is ionic and one of the products of this equation, we need to check the solubility chart for its state.");
          p.key.state = c.getWaterState();
          this.productSteps.add(
              "From the solubility chart, we can see that the state of $c should be ${phaseToString[p.key.state]}.");
        }
      });
    } else {
      this.productSteps.add(
          "Since the type of this equation is ${typeToString[this.type]}, the products are not in water; so, each of the ionic products must be solid.");
      for (Compound c in products
          .map((p) => p.key)
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
        if (r.key.compoundUnits.length > 2 &&
            !(r.key.compoundUnits[0].key.equals('C') &&
                r.key.compoundUnits[1].key.equals('H') &&
                r.key.compoundUnits[2].key.equals('O')))
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
    result += this.typeSteps.join('\n');
    result += '\n\nProduct(s)\n';
    result += this.productSteps.join('\n');
    result += '\n\nBalancing\n';
    result += this.balanceSteps.join('\n');
    result += '\n\nSo, the final equation after balancing is:';
    result += '\n$this';
    return result;
  }
}
