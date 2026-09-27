// Stand-in for dart:io on the web, where 3D models load from data addresses
// and files are never written. Only the names used behind `kIsWeb` checks.
class File {
  File(this.path);
  final String path;
  Future<File> writeAsBytes(List<int> bytes) async => this;
}

class Platform {
  static Map<String, String> get environment => const {};
}
