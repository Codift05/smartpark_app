class Prediction {
  final String level; // Rendah, Sedang, Tinggi
  final double low;
  final double medium;
  final double high;
  final DateTime timestamp;

  const Prediction({
    required this.level,
    required this.low,
    required this.medium,
    required this.high,
    required this.timestamp,
  });
}