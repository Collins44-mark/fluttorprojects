class AlertModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String title;
  final String? emergencyType;
  final String description;
  final String cause;
  final String location;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;
  final String
  status; // 'pending', 'accepted', 'assigned', 'in_progress', 'completed'
  final String departmentId;
  final String departmentName;
  final String? assignedEmployeeId;
  final String? assignedEmployeeName;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? assignedAt;
  final DateTime? completedAt;
  final String? completionProof;
  final String? completionNotes;

  AlertModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.title,
    this.emergencyType,
    required this.description,
    required this.cause,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    required this.status,
    required this.departmentId,
    required this.departmentName,
    this.assignedEmployeeId,
    this.assignedEmployeeName,
    required this.createdAt,
    this.acceptedAt,
    this.assignedAt,
    this.completedAt,
    this.completionProof,
    this.completionNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'title': title,
      'emergencyType': emergencyType,
      'description': description,
      'cause': cause,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
      'status': status,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'assignedEmployeeId': assignedEmployeeId,
      'assignedEmployeeName': assignedEmployeeName,
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'assignedAt': assignedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'completionProof': completionProof,
      'completionNotes': completionNotes,
    };
  }

  factory AlertModel.fromMap(Map<String, dynamic> map) {
    return AlertModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      title: map['title'] ?? '',
      emergencyType: map['emergencyType'],
      description: map['description'] ?? '',
      cause: map['cause'] ?? '',
      location: map['location'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      status: map['status'] ?? '',
      departmentId: map['departmentId'] ?? '',
      departmentName: map['departmentName'] ?? '',
      assignedEmployeeId: map['assignedEmployeeId'],
      assignedEmployeeName: map['assignedEmployeeName'],
      createdAt: DateTime.parse(map['createdAt']),
      acceptedAt: map['acceptedAt'] != null
          ? DateTime.parse(map['acceptedAt'])
          : null,
      assignedAt: map['assignedAt'] != null
          ? DateTime.parse(map['assignedAt'])
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      completionProof: map['completionProof'],
      completionNotes: map['completionNotes'],
    );
  }
}
