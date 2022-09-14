

class FileEntity {
  final String name;
  final int lastUpdated;
  final int size;
  final bool isDirectory;
  final String? path;

  const FileEntity({
    required this.name,
    required this.lastUpdated,
    required this.size,
    required this.isDirectory,
    this.path,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'updated': lastUpdated,
    'size': size,
    'is_directory': isDirectory,
    if (path != null)
      'path': path,
  };

  FileEntity.fromJson(Map<String, dynamic> json): this(
    name: json['name']!,
    lastUpdated: json['updated']!,
    size: json['size']!,
    isDirectory: json['is_directory']!,
    path: json['path'],
  );
}
