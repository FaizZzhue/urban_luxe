class CartItem {
  final String hotelId;
  final int nights; 

  CartItem({
    required this.hotelId,
    required this.nights,
  });

  CartItem copyWith({int? nights}) {
    return CartItem(
      hotelId: hotelId,
      nights: nights ?? this.nights,
    );
  }

  Map<String, dynamic> toMap() => {
        "hotelId": hotelId,
        "nights": nights,
      };

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      hotelId: map["hotelId"] as String,
      nights: (map["nights"] as num?)?.toInt() ?? 1,
    );
  }
}