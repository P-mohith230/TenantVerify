enum UserRole { landlord, tenant, admin }

class User {
  final String id;
  final String? email;
  final String? walletAddress;
  final String displayName;
  final UserRole role;
  final bool isWalletConnected;
  final DateTime? consentSignedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    this.email,
    this.walletAddress,
    required this.displayName,
    required this.role,
    this.isWalletConnected = false,
    this.consentSignedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  String get shortWalletAddress {
    if (walletAddress == null || walletAddress!.length < 10) return walletAddress ?? '';
    return '${walletAddress!.substring(0, 6)}...${walletAddress!.substring(walletAddress!.length - 4)}';
  }

  User copyWith({
    String? id,
    String? email,
    String? walletAddress,
    String? displayName,
    UserRole? role,
    bool? isWalletConnected,
    DateTime? consentSignedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    walletAddress: walletAddress ?? this.walletAddress,
    displayName: displayName ?? this.displayName,
    role: role ?? this.role,
    isWalletConnected: isWalletConnected ?? this.isWalletConnected,
    consentSignedAt: consentSignedAt ?? this.consentSignedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'walletAddress': walletAddress,
    'displayName': displayName,
    'role': role.name,
    'isWalletConnected': isWalletConnected,
    'consentSignedAt': consentSignedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    email: json['email'] as String?,
    walletAddress: json['walletAddress'] as String?,
    displayName: json['displayName'] as String,
    role: UserRole.values.firstWhere((e) => e.name == json['role']),
    isWalletConnected: json['isWalletConnected'] as bool? ?? false,
    consentSignedAt: json['consentSignedAt'] != null ? DateTime.parse(json['consentSignedAt'] as String) : null,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}
