/// Display metadata for the existing backup/checkpoint cards. No filesystem IO.
class PreviewArchive {
  const PreviewArchive(this.name, this.modified, this.sizeBytes);
  final String name;
  final DateTime modified;
  final int sizeBytes;
  String get path => name;
}
