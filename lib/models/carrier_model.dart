class Carrier {
  final String name;
  final String status;
  final DateTime dateAdded; // Add dateAdded property for emails
  double rotationAngle; // Add rotation angle property

  Carrier(this.name, this.status, this.dateAdded, {this.rotationAngle = 0});
}

class CarrierToolAllocation {
  final String name;
  final int position;

  CarrierToolAllocation({
    required this.name,
    required this.position,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'position': position,
      };

  factory CarrierToolAllocation.fromMap(Map<String, dynamic> map) {
    return CarrierToolAllocation(
      name: map['name'] as String,
      position: map['position'] as int,
    );
  }
}
