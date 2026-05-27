class RequestModel {
  final String id;
  final String parentId;
  final String parentName;
  final String caregiverId;
  final String message;
  final DateTime createdAt;
  final String status; // 'pending', 'accepted', 'declined'

  RequestModel({
    required this.id,
    required this.parentId,
    required this.parentName,
    required this.caregiverId,
    required this.message,
    required this.createdAt,
    required this.status,
  });

  factory RequestModel.fromMap(Map<String, dynamic> map, String id) {
    return RequestModel(
      id: id,
      parentId: map['parentId'] ?? '',
      parentName: map['parentName'] ?? '',
      caregiverId: map['caregiverId'] ?? '',
      message: map['message'] ?? '',
      createdAt: (map['createdAt'] as dynamic).toDate(),
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parentId': parentId,
      'parentName': parentName,
      'caregiverId': caregiverId,
      'message': message,
      'createdAt': createdAt,
      'status': status,
    };
  }
}
