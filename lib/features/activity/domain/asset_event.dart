class AssetEvent {
  const AssetEvent({
    required this.id,
    required this.assetId,
    required this.type,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  final String id;
  final String assetId;
  final String type;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
}
