class Certificate {
  final String id;
  final String verificationId;
  final String tenantId;
  final String tenantName;
  final String certificateNumber;
  final DateTime issueDate;
  final DateTime expiryDate;
  final String landlordAddress;
  final String transactionHash;
  final String merkleRoot;
  final String qrCodeData;
  final bool isRevoked;
  final DateTime? revokedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Certificate({
    required this.id,
    required this.verificationId,
    required this.tenantId,
    required this.tenantName,
    required this.certificateNumber,
    required this.issueDate,
    required this.expiryDate,
    required this.landlordAddress,
    required this.transactionHash,
    required this.merkleRoot,
    required this.qrCodeData,
    this.isRevoked = false,
    this.revokedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isValid => !isRevoked && DateTime.now().isBefore(expiryDate);

  String get statusLabel {
    if (isRevoked) return 'Revoked';
    if (DateTime.now().isAfter(expiryDate)) return 'Expired';
    return 'Valid';
  }

  Certificate copyWith({
    String? id,
    String? verificationId,
    String? tenantId,
    String? tenantName,
    String? certificateNumber,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? landlordAddress,
    String? transactionHash,
    String? merkleRoot,
    String? qrCodeData,
    bool? isRevoked,
    DateTime? revokedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Certificate(
    id: id ?? this.id,
    verificationId: verificationId ?? this.verificationId,
    tenantId: tenantId ?? this.tenantId,
    tenantName: tenantName ?? this.tenantName,
    certificateNumber: certificateNumber ?? this.certificateNumber,
    issueDate: issueDate ?? this.issueDate,
    expiryDate: expiryDate ?? this.expiryDate,
    landlordAddress: landlordAddress ?? this.landlordAddress,
    transactionHash: transactionHash ?? this.transactionHash,
    merkleRoot: merkleRoot ?? this.merkleRoot,
    qrCodeData: qrCodeData ?? this.qrCodeData,
    isRevoked: isRevoked ?? this.isRevoked,
    revokedAt: revokedAt ?? this.revokedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'verificationId': verificationId,
    'tenantId': tenantId,
    'tenantName': tenantName,
    'certificateNumber': certificateNumber,
    'issueDate': issueDate.toIso8601String(),
    'expiryDate': expiryDate.toIso8601String(),
    'landlordAddress': landlordAddress,
    'transactionHash': transactionHash,
    'merkleRoot': merkleRoot,
    'qrCodeData': qrCodeData,
    'isRevoked': isRevoked,
    'revokedAt': revokedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Certificate.fromJson(Map<String, dynamic> json) => Certificate(
    id: json['id'] as String,
    verificationId: json['verificationId'] as String,
    tenantId: json['tenantId'] as String,
    tenantName: json['tenantName'] as String,
    certificateNumber: json['certificateNumber'] as String,
    issueDate: DateTime.parse(json['issueDate'] as String),
    expiryDate: DateTime.parse(json['expiryDate'] as String),
    landlordAddress: json['landlordAddress'] as String,
    transactionHash: json['transactionHash'] as String,
    merkleRoot: json['merkleRoot'] as String,
    qrCodeData: json['qrCodeData'] as String,
    isRevoked: json['isRevoked'] as bool? ?? false,
    revokedAt: json['revokedAt'] != null ? DateTime.parse(json['revokedAt'] as String) : null,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}
