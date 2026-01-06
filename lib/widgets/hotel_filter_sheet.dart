import 'package:flutter/material.dart';
import 'package:urban_luxe/models/hotel.dart';
import 'package:urban_luxe/models/hotel_filter.dart';

class HotelFilterSheet extends StatefulWidget {
  final HotelFilter initial;
  final List<Hotel> hotels;

  const HotelFilterSheet({
    super.key,
    required this.initial,
    required this.hotels,
  });

  static Future<HotelFilter?> open(
    BuildContext context, {
    required HotelFilter initial,
    required List<Hotel> hotels,
  }) {
    return showModalBottomSheet<HotelFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        top: false,
        child: HotelFilterSheet(initial: initial, hotels: hotels),
      ),
    );
  }

  @override
  State<HotelFilterSheet> createState() => _HotelFilterSheetState();
}

class _HotelFilterSheetState extends State<HotelFilterSheet> {
  late HotelFilter _f;

  late int _minBound;
  late int _maxBound;

  late double _minRating;

  late Set<String> _selectedFacilities;
  late Set<String> _selectedServices;

  late HotelSort _sort;

  @override
  void initState() {
    super.initState();
    _f = widget.initial;

    // batas price dari data
    final prices = widget.hotels
        .map((h) => h.priceRange.minIdr)
        .where((p) => p > 0)
        .toList();

    if (prices.isEmpty) {
      _minBound = 0;
      _maxBound = 1000000;
    } else {
      prices.sort();
      _minBound = prices.first;
      _maxBound = prices.last;
      if (_minBound == _maxBound) _maxBound = _minBound + 100000; 
    }

    _minRating = _f.minRating;
    _selectedFacilities = {..._f.facilities};
    _selectedServices = {..._f.services};
    _sort = _f.sort;
  }

  String _idr(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write('.');
    }
    return "Rp$buf";
  }

  List<String> _allFacilities() {
    final set = <String>{};
    for (final h in widget.hotels) {
      set.addAll(h.facilities);
    }
    final list = set.toList()..sort();
    return list;
  }

  List<String> _allServices() {
    final set = <String>{};
    for (final h in widget.hotels) {
      set.addAll(h.services);
    }
    final list = set.toList()..sort();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final allFacilities = _allFacilities();
    final allServices = _allServices();

    final currentMin = (_f.minPrice ?? _minBound).clamp(_minBound, _maxBound);
    final currentMax = (_f.maxPrice ?? _maxBound).clamp(_minBound, _maxBound);

    RangeValues range = RangeValues(
      currentMin.toDouble(),
      currentMax.toDouble(),
    );

    if (range.start > range.end) {
      range = RangeValues(range.end, range.start);
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (ctx, controller) {
        return SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // grab handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // header
              Row(
                children: [
                  const Text(
                    "Filter",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _f = _f.reset();
                        _minRating = 0;
                        _selectedFacilities.clear();
                        _selectedServices.clear();
                        _sort = HotelSort.relevance;
                      });
                    },
                    child: const Text("Reset"),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // PRICE
              const Text(
                "Price Range",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                "${_idr(range.start.round())} - ${_idr(range.end.round())}",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              RangeSlider(
                values: range,
                min: _minBound.toDouble(),
                max: _maxBound.toDouble(),
                divisions: 30,
                onChanged: (v) {
                  setState(() {
                    _f = _f.copyWith(
                      minPrice: v.start.round(),
                      maxPrice: v.end.round(),
                    );
                  });
                },
              ),

              const SizedBox(height: 10),

              // RATING
              const Text(
                "Minimum Rating",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _minRating.clamp(0, 5),
                      min: 0,
                      max: 5,
                      divisions: 10,
                      label: _minRating.toStringAsFixed(1),
                      onChanged: (v) => setState(() {
                        _minRating = v;
                        _f = _f.copyWith(minRating: v);
                      }),
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text(
                      _minRating.toStringAsFixed(1),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // SORT
              const Text(
                "Sort",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SortChip(
                    label: "Relevance",
                    selected: _sort == HotelSort.relevance,
                    onTap: () => setState(() {
                      _sort = HotelSort.relevance;
                      _f = _f.copyWith(sort: _sort);
                    }),
                  ),
                  _SortChip(
                    label: "Low-High",
                    selected: _sort == HotelSort.priceLowHigh,
                    onTap: () => setState(() {
                      _sort = HotelSort.priceLowHigh;
                      _f = _f.copyWith(sort: _sort);
                    }),
                  ),
                  _SortChip(
                    label: "High-Low",
                    selected: _sort == HotelSort.priceHighLow,
                    onTap: () => setState(() {
                      _sort = HotelSort.priceHighLow;
                      _f = _f.copyWith(sort: _sort);
                    }),
                  ),
                  _SortChip(
                    label: "Rating",
                    selected: _sort == HotelSort.ratingHighLow,
                    onTap: () => setState(() {
                      _sort = HotelSort.ratingHighLow;
                      _f = _f.copyWith(sort: _sort);
                    }),
                  ),
                  _SortChip(
                    label: "Name A-Z",
                    selected: _sort == HotelSort.nameAZ,
                    onTap: () => setState(() {
                      _sort = HotelSort.nameAZ;
                      _f = _f.copyWith(sort: _sort);
                    }),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // FACILITIES
              const Text(
                "Facilities",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              if (allFacilities.isEmpty)
                Text(
                  "Tidak ada data fasilitas",
                  style: TextStyle(color: Colors.grey.shade600),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allFacilities.map((f) {
                    final selected = _selectedFacilities.contains(f);
                    return FilterChip(
                      label: Text(f),
                      selected: selected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _selectedFacilities.add(f);
                          } else {
                            _selectedFacilities.remove(f);
                          }
                          _f = _f.copyWith(facilities: {..._selectedFacilities});
                        });
                      },
                    );
                  }).toList(),
                ),

              const SizedBox(height: 14),

              // SERVICES
              const Text(
                "Services",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              if (allServices.isEmpty)
                Text(
                  "Tidak ada data layanan",
                  style: TextStyle(color: Colors.grey.shade600),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allServices.map((s) {
                    final selected = _selectedServices.contains(s);
                    return FilterChip(
                      label: Text(s),
                      selected: selected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _selectedServices.add(s);
                          } else {
                            _selectedServices.remove(s);
                          }
                          _f = _f.copyWith(services: {..._selectedServices});
                        });
                      },
                    );
                  }).toList(),
                ),

              const SizedBox(height: 18),

              // APPLY
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, _f),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008A4E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _f.isActive ? "Apply Filter" : "Close",
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF008A4E) : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}