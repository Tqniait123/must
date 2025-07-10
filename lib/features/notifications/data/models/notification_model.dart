class NotificationModel {
  final int id;
  final String message;
  final DateTime? readAt;
  final DateTime createdAt;

  NotificationModel({required this.id, required this.message, this.readAt, required this.createdAt});

  // Factory constructor لإنشاء NotificationModel من JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      message: json['message'] as String,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Method لتحويل NotificationModel إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Method للتحقق من قراءة الإشعار
  bool get isRead => readAt != null;

  // Method لتحديث حالة قراءة الإشعار
  NotificationModel markAsRead() {
    return NotificationModel(id: id, message: message, readAt: DateTime.now(), createdAt: createdAt);
  }

  // Method لنسخ الكائن مع تغيير بعض الخصائص
  NotificationModel copyWith({int? id, String? message, DateTime? readAt, DateTime? createdAt}) {
    return NotificationModel(
      id: id ?? this.id,
      message: message ?? this.message,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, message: $message, readAt: $readAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel &&
        other.id == id &&
        other.message == message &&
        other.readAt == readAt &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ message.hashCode ^ readAt.hashCode ^ createdAt.hashCode;
  }
}
