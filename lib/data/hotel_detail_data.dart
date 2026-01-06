class HotelDetailExtra {
  final String address;
  final String phone;
  final String email;
  final List<String> gallery;

  const HotelDetailExtra({
    this.address = '',
    this.phone = '',
    this.email = '',
    this.gallery = const [],
  });

  static const Map<String, HotelDetailExtra> _byId = {
    'santika_premiere_bandara_plg': HotelDetailExtra(
      address: 'Jl. Gubernur H. A. Bastari No. 1, Jakabaring, Seberang Ulu I, Kota Palembang, Sumatera Selatan 30257, Indonesia',
      phone: '+62 711 5640000',
      email: 'reservation@palembangpremiere.santika.com',
      gallery: [
        'assets/hotels/santika1.jpg',
        'assets/hotels/santika2.jpg',
        'assets/hotels/santika3.jpg',
      ],
    ),

    'ibis_sanggar_plg': HotelDetailExtra(
      address: 'Jl. Letkol Iskandar No. 120, Palembang 30125, Sumatera Selatan, Indonesia',
      phone: '+62 711 5719999',
      email: 'H9504@accor.com',
      gallery: [
        'assets/hotels/ibis1.jpg',
        'assets/hotels/ibis2.jpg',
        'assets/hotels/ibis3.jpg',
      ],
    ),

    'novotel_plg': HotelDetailExtra(
      address: 'Jalan R. Sukamto No. 8A, Palembang 30127, Sumatera Selatan, Indonesia',
      phone: '+62 711 373173',
      email: 'H6020@accor.com',
      gallery: [
        'assets/hotels/novotel1.jpg',
        'assets/hotels/novotel2.jpg',
        'assets/hotels/novotel3.jpg',
      ],
    ),

    'aryaduta_plg': HotelDetailExtra(
      address: 'Jl. POM IX, Palembang Square, Palembang 30137, Sumatera Selatan, Indonesia',
      phone: '+62 711 5909999',
      email: 'reservation.palembang@aryaduta.com',
      gallery: [
        'assets/hotels/aryaduta1.jpg',
        'assets/hotels/aryaduta2.jpg',
        'assets/hotels/aryaduta3.jpg',
      ],
    ),

    'excelton_plg': HotelDetailExtra(
      address: 'Jl. Demang Lebar Daun No. 58B, Ilir Barat I, Kota Palembang, Sumatera Selatan 30137, Indonesia',
      phone: '+62 711 3111000', 
      email: 'info@exceltonhotel.com', 
      gallery: [
        'assets/hotels/excelton1.jpg',
        'assets/hotels/excelton2.jpg',
        'assets/hotels/excelton3.jpg',
      ],
    ),

    'wyndham_opi_plg': HotelDetailExtra(
      address: 'Komplek OPI Mall, Jl. Gubernur H. A. Bastari, Jakabaring, Palembang, Sumatera Selatan, Indonesia',
      phone: '+62 711 0000000',
      email: 'reservation@wyndhamopi.com', 
      gallery: [
        'assets/hotels/wyndham1.jpg',
        'assets/hotels/wyndham2.jpg',
        'assets/hotels/wyndham3.jpg',
      ],
    ),

    'alts_hotel_plg': HotelDetailExtra(
      address: 'Jl. Rajawali No. 8, 9 Ilir, Ilir Timur II, Kota Palembang, Sumatera Selatan, Indonesia',
      phone: '+62 711 0000000', 
      email: 'info@alts-hotel.com', 
      gallery: [
        'assets/hotels/alts1.jpg',
        'assets/hotels/alts2.jpg',
        'assets/hotels/alts3.jpg',
      ],
    ),

    'aston_plg': HotelDetailExtra(
      address: 'Jl. Jend. Basuki Rachmat No. 189, Kemuning, Kota Palembang, Sumatera Selatan, Indonesia',
      phone: '+62 711 0000000',
      email: 'reservation@astonpalembang.com', 
      gallery: [
        'assets/hotels/aston1.jpg',
        'assets/hotels/aston2.jpg',
        'assets/hotels/aston3.jpg',
      ],
    ),

    'arista_plg': HotelDetailExtra(
      address: 'Jl. Kapten A. Rivai No. 1, Sungai Pangeran, Ilir Timur I, Kota Palembang, Sumatera Selatan, Indonesia',
      phone: '+62 711 0000000', 
      email: 'reservation@aristahotel.com', 
      gallery: [
        'assets/hotels/arista1.jpg',
        'assets/hotels/arista2.jpg',
        'assets/hotels/arista3.jpg',
      ],
    ),
  };

  static const HotelDetailExtra _empty = HotelDetailExtra();

  static HotelDetailExtra byId(String id) => _byId[id] ?? _empty;
}
