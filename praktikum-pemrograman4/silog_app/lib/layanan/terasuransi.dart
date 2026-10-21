
mixin Terasuransi {
  double persentasePremi = 0.015;

  double hitungPremi(double nilaiBarang) {
    return nilaiBarang * persentasePremi;
  }
}
