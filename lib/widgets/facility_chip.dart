import 'package:flutter/material.dart';

class FacilityChip extends StatelessWidget {
  final String name;
  final IconData icon;

  const FacilityChip({super.key, required this.name, required this.icon});

  factory FacilityChip.fromName(String name) {
    final lower = name.toLowerCase();

    if (lower.contains('wi')) return const FacilityChip(name: "Wi-Fi", icon: Icons.wifi);
    if (lower.contains('spa')) return const FacilityChip(name: "Spa", icon: Icons.spa);
    if (lower.contains('gym') || lower.contains('kebugaran')) {
      return const FacilityChip(name: "Gym", icon: Icons.fitness_center);
    }
    if (lower.contains('kolam') || lower.contains('swim')) {
      return const FacilityChip(name: "Pool", icon: Icons.pool);
    }
    if (lower.contains('resto') || lower.contains('restoran')) {
      return const FacilityChip(name: "Restaurant", icon: Icons.restaurant);
    }
    if (lower.contains('parkir')) {
      return const FacilityChip(name: "Parking", icon: Icons.local_parking);
    }
    if (lower.contains('sauna')) {
      return const FacilityChip(name: "Sauna", icon: Icons.hot_tub);
    }

    return FacilityChip(name: name, icon: Icons.check_circle_outline);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 5),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade100,
            child: Icon(icon, size: 18, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}