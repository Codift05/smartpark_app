class ParkingSlot {
  final int id;
  final bool occupied;
  final DateTime lastUpdated;

  const ParkingSlot({
    required this.id,
    required this.occupied,
    required this.lastUpdated,
  });

  ParkingSlot copyWith({int? id, bool? occupied, DateTime? lastUpdated}) {
    return ParkingSlot(
      id: id ?? this.id,
      occupied: occupied ?? this.occupied,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}