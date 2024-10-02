
class Tool {
  final String name;
  final String status;
  final DateTime dateAdded; // Add dateAdded property for emails
  double rotationAngle; // Add rotation angle property

  Tool(this.name, this.status, this.dateAdded, {this.rotationAngle = 0});
}

class ToolAllocation {
  final String name;
  final int position;

  ToolAllocation({
    required this.name,
    required this.position,
  });

  Map<String, dynamic> toMap() => {
    'name':name,
    'position':position,
  };

  factory ToolAllocation.fromMap(Map<String, dynamic> map){
    return ToolAllocation(
      name: map['name'] as String,
      position: map['position'] as int,
    );
  }
}