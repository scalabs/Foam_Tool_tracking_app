class Tool {
  final String name;
  final String status;
  final DateTime dateAdded; // Add dateAdded property for emails
  double rotationAngle; // Add rotation angle property

  Tool(this.name, this.status, this.dateAdded, {this.rotationAngle = 0});
}
