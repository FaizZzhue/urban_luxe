import 'package:flutter/material.dart';
import 'package:urban_luxe/models/hotel.dart';
import 'package:urban_luxe/data/hotel_detail_data.dart';
import 'package:urban_luxe/widgets/expandable_text.dart';
import 'package:urban_luxe/widgets/facility_chip.dart';

class AboutTab extends StatelessWidget {
  final Hotel hotel;
  final HotelDetailExtra extra;

  const AboutTab({super.key, required this.hotel, required this.extra});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: [
        const Text("Description",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        ExpandableText(text: hotel.description, trimLines: 4),
        const SizedBox(height: 18),

        const Text("Contact Details",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        _contactRow(Icons.phone, extra.phone.isEmpty ? "+62 - (belum tersedia)" : extra.phone),
        const SizedBox(height: 8),
        _contactRow(Icons.email, extra.email.isEmpty ? "email@belum-tersedia.com" : extra.email),
        const SizedBox(height: 18),

        const Text("Fasilitas",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: hotel.facilities.isEmpty
              ? const [FacilityChip(name: "Tidak ada data", icon: Icons.info_outline)]
              : hotel.facilities.map((f) => FacilityChip.fromName(f)).toList(),
        ),
      ],
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade800),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}