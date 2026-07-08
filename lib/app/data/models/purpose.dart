class Purpose {
  final int id;
  final String name;

  Purpose({required this.id, required this.name});

  factory Purpose.fromJson(Map<String, dynamic> json) {
    return Purpose(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
