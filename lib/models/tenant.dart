import 'package:flutter/foundation.dart';

enum DocumentType { aadhaar, pan, employment }

class Tenant {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime dob;
  final String aadhaarLast4;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tenant({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.dob,
    required this.aadhaarLast4,
    required this.createdAt,
    required this.updatedAt,
  });

  Tenant copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    DateTime? dob,
    String? aadhaarLast4,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Tenant(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    dob: dob ?? this.dob,
    aadhaarLast4: aadhaarLast4 ?? this.aadhaarLast4,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'dob': dob.toIso8601String(),
    'aadhaarLast4': aadhaarLast4,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    dob: DateTime.parse(json['dob'] as String),
    aadhaarLast4: json['aadhaarLast4'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}

class TenantDocument {
  final String id;
  final String tenantId;
  final DocumentType type;
  final String fileName;
  final int fileSize;
  final String hash;
  final DateTime uploadedAt;
  final Uint8List? fileBytes;

  TenantDocument({
    required this.id,
    required this.tenantId,
    required this.type,
    required this.fileName,
    required this.fileSize,
    required this.hash,
    required this.uploadedAt,
    this.fileBytes,
  });

  String get typeLabel {
    switch (type) {
      case DocumentType.aadhaar:
        return 'Aadhaar Card';
      case DocumentType.pan:
        return 'PAN Card';
      case DocumentType.employment:
        return 'Employment Letter';
    }
  }

  TenantDocument copyWith({
    String? id,
    String? tenantId,
    DocumentType? type,
    String? fileName,
    int? fileSize,
    String? hash,
    DateTime? uploadedAt,
    Uint8List? fileBytes,
  }) => TenantDocument(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    type: type ?? this.type,
    fileName: fileName ?? this.fileName,
    fileSize: fileSize ?? this.fileSize,
    hash: hash ?? this.hash,
    uploadedAt: uploadedAt ?? this.uploadedAt,
    fileBytes: fileBytes ?? this.fileBytes,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'tenantId': tenantId,
    'type': type.name,
    'fileName': fileName,
    'fileSize': fileSize,
    'hash': hash,
    'uploadedAt': uploadedAt.toIso8601String(),
  };

  factory TenantDocument.fromJson(Map<String, dynamic> json) => TenantDocument(
    id: json['id'] as String,
    tenantId: json['tenantId'] as String,
    type: DocumentType.values.firstWhere((e) => e.name == json['type']),
    fileName: json['fileName'] as String,
    fileSize: json['fileSize'] as int,
    hash: json['hash'] as String,
    uploadedAt: DateTime.parse(json['uploadedAt'] as String),
  );
}
