enum VerificationStatus { pending, processing, verified, failed, revoked }

enum VerificationStepType {
  fileHashing,
  merkleRoot,
  governmentVerification,
  blockchainStorage,
}

class VerificationStep {
  final VerificationStepType type;
  final String title;
  final String description;
  final bool isCompleted;
  final bool isFailed;
  final DateTime? completedAt;
  final String? result;
  final String? error;

  VerificationStep({
    required this.type,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.isFailed = false,
    this.completedAt,
    this.result,
    this.error,
  });

  VerificationStep copyWith({
    VerificationStepType? type,
    String? title,
    String? description,
    bool? isCompleted,
    bool? isFailed,
    DateTime? completedAt,
    String? result,
    String? error,
  }) => VerificationStep(
    type: type ?? this.type,
    title: title ?? this.title,
    description: description ?? this.description,
    isCompleted: isCompleted ?? this.isCompleted,
    isFailed: isFailed ?? this.isFailed,
    completedAt: completedAt ?? this.completedAt,
    result: result ?? this.result,
    error: error ?? this.error,
  );

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'title': title,
    'description': description,
    'isCompleted': isCompleted,
    'isFailed': isFailed,
    'completedAt': completedAt?.toIso8601String(),
    'result': result,
    'error': error,
  };

  factory VerificationStep.fromJson(Map<String, dynamic> json) => VerificationStep(
    type: VerificationStepType.values.firstWhere((e) => e.name == json['type']),
    title: json['title'] as String,
    description: json['description'] as String,
    isCompleted: json['isCompleted'] as bool? ?? false,
    isFailed: json['isFailed'] as bool? ?? false,
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
    result: json['result'] as String?,
    error: json['error'] as String?,
  );
}

class Verification {
  final String id;
  final String tenantId;
  final VerificationStatus status;
  final List<String> documentIds;
  final List<VerificationStep> steps;
  final String? merkleRoot;
  final String? transactionHash;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Verification({
    required this.id,
    required this.tenantId,
    required this.status,
    required this.documentIds,
    required this.steps,
    this.merkleRoot,
    this.transactionHash,
    required this.startedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Verification copyWith({
    String? id,
    String? tenantId,
    VerificationStatus? status,
    List<String>? documentIds,
    List<VerificationStep>? steps,
    String? merkleRoot,
    String? transactionHash,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Verification(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    status: status ?? this.status,
    documentIds: documentIds ?? this.documentIds,
    steps: steps ?? this.steps,
    merkleRoot: merkleRoot ?? this.merkleRoot,
    transactionHash: transactionHash ?? this.transactionHash,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt ?? this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'tenantId': tenantId,
    'status': status.name,
    'documentIds': documentIds,
    'steps': steps.map((s) => s.toJson()).toList(),
    'merkleRoot': merkleRoot,
    'transactionHash': transactionHash,
    'startedAt': startedAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Verification.fromJson(Map<String, dynamic> json) => Verification(
    id: json['id'] as String,
    tenantId: json['tenantId'] as String,
    status: VerificationStatus.values.firstWhere((e) => e.name == json['status']),
    documentIds: List<String>.from(json['documentIds'] as List),
    steps: (json['steps'] as List).map((s) => VerificationStep.fromJson(s as Map<String, dynamic>)).toList(),
    merkleRoot: json['merkleRoot'] as String?,
    transactionHash: json['transactionHash'] as String?,
    startedAt: DateTime.parse(json['startedAt'] as String),
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  static List<VerificationStep> createInitialSteps() => [
    VerificationStep(
      type: VerificationStepType.fileHashing,
      title: 'File Hashing',
      description: 'Computing SHA-256 hash for each document',
    ),
    VerificationStep(
      type: VerificationStepType.merkleRoot,
      title: 'Merkle Root Creation',
      description: 'Combining document hashes into Merkle root',
    ),
    VerificationStep(
      type: VerificationStepType.governmentVerification,
      title: 'Government Verification',
      description: 'Verifying documents with government APIs',
    ),
    VerificationStep(
      type: VerificationStepType.blockchainStorage,
      title: 'Blockchain Storage',
      description: 'Recording proof on Polygon blockchain',
    ),
  ];
}
