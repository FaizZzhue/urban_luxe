class PriceRange {
  final int minIdr;
  final int maxIdr;
  final String currency;
  final String note;

  PriceRange({
    required this.minIdr,
    required this.maxIdr,
    required this.currency,
    required this.note,
  });

  factory PriceRange.fromMap(Map<String, dynamic> map) {
    return PriceRange(
      minIdr: (map['minIdr'] as num).toInt(),
      maxIdr: (map['maxIdr'] as num).toInt(),
      currency: (map['currency'] ?? 'IDR') as String,
      note: (map['note'] ?? '') as String,
    );
  }
}
