import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../Utils/Constant/enum.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? signatureUrl;
  final String? initialsUrl;
  final UserRole role;
  final double usedStorageMB;
  final DateTime createdAt;
  final DateTime updatedAt;

  static const double maxStorageMB = 2048; // 2 GB

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.signatureUrl,
    this.initialsUrl,
    this.role = UserRole.owner,
    this.usedStorageMB = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  double get freeStorageMB => maxStorageMB - usedStorageMB;
  double get usedStorageGB => usedStorageMB / 1024;
  double get freeStorageGB => freeStorageMB / 1024;
  double get storageUsagePercent => usedStorageMB / maxStorageMB;
  bool get isStorageFull => usedStorageMB >= maxStorageMB;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      signatureUrl: data['signatureUrl'],
      initialsUrl: data['initialsUrl'],
      role: UserRole.values.firstWhere(
        (r) => r.name == (data['role'] ?? 'owner'),
        orElse: () => UserRole.owner,
      ),
      usedStorageMB: (data['usedStorageMB'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'signatureUrl': signatureUrl,
      'initialsUrl': initialsUrl,
      'role': role.name,
      'usedStorageMB': usedStorageMB,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? photoUrl,
    String? signatureUrl,
    String? initialsUrl,
    UserRole? role,
    double? usedStorageMB,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      initialsUrl: initialsUrl ?? this.initialsUrl,
      role: role ?? this.role,
      usedStorageMB: usedStorageMB ?? this.usedStorageMB,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
