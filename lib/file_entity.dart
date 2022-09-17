
enum EntityType {
  unknown,
  folder,
  doc,
  sheet,
  slide,
}

class FileEntity {
  final String name;
  final int lastUpdated;
  final int size;
  final EntityType type;
  final String? path;

  const FileEntity({
    required this.name,
    required this.lastUpdated,
    required this.size,
    required this.type,
    this.path,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'updated': lastUpdated,
    'size': size,
    'type': type.name,
    if (path != null)
      'path': path,
  };

  static EntityType of(String? name) {
    return EntityType.values.firstWhere((e) => e.name == name,
      orElse: () => EntityType.unknown,
    );
  }

  FileEntity.fromJson(dynamic json): this(
    name: json['name']!,
    lastUpdated: json['updated']!,
    size: json['size']!,
    type: of(json['type']!),
    path: json['path'],
  );
}
