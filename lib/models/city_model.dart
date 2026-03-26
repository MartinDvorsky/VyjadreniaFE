class City {
  final int id;
  final String name;
  final String district;
  final String region;
  final bool isCity;

  City({
    required this.id,
    required this.name,
    required this.district,
    required this.region,
    required this.isCity,
  });

  // Vytvor City objekt z JSON
  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as int,
      name: json['name'] as String,
      district: json['district'] as String,
      region: json['region'] as String,
      isCity: json['is_city'] as bool,
    );
  }

  // Konvertuj City objekt na JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'district': district,
      'region': region,
      'is_city': isCity,
    };
  }

  @override
  String toString() {
    return 'City(id: $id, name: $name, district: $district, region: $region, isCity: $isCity)';
  }
}