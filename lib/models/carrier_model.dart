class Carrier {
  final String name;
  final String status;
  final DateTime dateAdded; // Add dateAdded property for emails
  double rotationAngle; // Add rotation angle property

  Carrier(this.name, this.status, this.dateAdded, {this.rotationAngle = 0});
}

