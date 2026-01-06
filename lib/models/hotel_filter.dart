import 'package:flutter/material.dart';

enum HotelSort {
  relevance,
  priceLowHigh,
  priceHighLow,
  ratingHighLow,
  nameAZ,
}

class HotelFilter {
  final int? minPrice; 
  final int? maxPrice; 
  final double minRating; 
  final Set<String> facilities;
  final Set<String> services;
  final HotelSort sort;

  const HotelFilter({
    this.minPrice,
    this.maxPrice,
    this.minRating = 0,
    this.facilities = const {},
    this.services = const {},
    this.sort = HotelSort.relevance,
  });

  HotelFilter copyWith({
    int? minPrice,
    int? maxPrice,
    double? minRating,
    Set<String>? facilities,
    Set<String>? services,
    HotelSort? sort,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
  }) {
    return HotelFilter(
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      minRating: minRating ?? this.minRating,
      facilities: facilities ?? this.facilities,
      services: services ?? this.services,
      sort: sort ?? this.sort,
    );
  }

  HotelFilter reset() => const HotelFilter();

  bool get isActive =>
      minPrice != null ||
      maxPrice != null ||
      minRating > 0 ||
      facilities.isNotEmpty ||
      services.isNotEmpty ||
      sort != HotelSort.relevance;
}
