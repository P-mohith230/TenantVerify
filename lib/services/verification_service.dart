import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:project/models/tenant.dart';
import 'package:project/models/verification.dart';
import 'package:project/models/certificate.dart';
import 'package:project/services/blockchain_service.dart';

class VerificationService {
  static const _tenantsKey = 'tenants';
  static const _verificationsKey = 'verifications';
  static const _certificatesKey = 'certificates';
  static const _documentsKey = 'documents';

  static final _uuid = Uuid();
  final BlockchainService _blockchainService = BlockchainService();

  // In-memory cache
  List<Tenant> _tenants = [];
  List<Verification> _verifications = [];
  List<Certificate> _certificates = [];
  List<TenantDocument> _documents = [];
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadData();
    _isInitialized = true;
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final tenantsJson = prefs.getString(_tenantsKey);
      if (tenantsJson != null) {
        final list = jsonDecode(tenantsJson) as List;
        _tenants = list.map((e) => Tenant.fromJson(e as Map<String, dynamic>)).toList();
      }

      final verificationsJson = prefs.getString(_verificationsKey);
      if (verificationsJson != null) {
        final list = jsonDecode(verificationsJson) as List;
        _verifications = list.map((e) => Verification.fromJson(e as Map<String, dynamic>)).toList();
      }

      final certificatesJson = prefs.getString(_certificatesKey);
      if (certificatesJson != null) {
        final list = jsonDecode(certificatesJson) as List;
        _certificates = list.map((e) => Certificate.fromJson(e as Map<String, dynamic>)).toList();
      }

      final documentsJson = prefs.getString(_documentsKey);
      if (documentsJson != null) {
        final list = jsonDecode(documentsJson) as List;
        _documents = list.map((e) => TenantDocument.fromJson(e as Map<String, dynamic>)).toList();
      }

      // Add sample data if empty
      if (_tenants.isEmpty) {
        await _addSampleData();
      }
    } catch (e) {
      debugPrint('Failed to load verification data: $e');
      await _addSampleData();
    }
  }

  Future<void> _addSampleData() async {
    final now = DateTime.now();
    
    // Sample tenants
    final tenant1 = Tenant(
      id: _uuid.v4(),
      name: 'Rahul Sharma',
      email: 'rahul.sharma@email.com',
      phone: '+91 98765 43210',
      dob: DateTime(1992, 5, 15),
      aadhaarLast4: '4521',
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(days: 30)),
    );

    final tenant2 = Tenant(
      id: _uuid.v4(),
      name: 'Priya Patel',
      email: 'priya.patel@email.com',
      phone: '+91 87654 32109',
      dob: DateTime(1995, 8, 22),
      aadhaarLast4: '7832',
      createdAt: now.subtract(const Duration(days: 15)),
      updatedAt: now.subtract(const Duration(days: 15)),
    );

    final tenant3 = Tenant(
      id: _uuid.v4(),
      name: 'Amit Kumar',
      email: 'amit.kumar@email.com',
      phone: '+91 76543 21098',
      dob: DateTime(1988, 12, 3),
      aadhaarLast4: '9156',
      createdAt: now.subtract(const Duration(days: 7)),
      updatedAt: now.subtract(const Duration(days: 7)),
    );

    _tenants = [tenant1, tenant2, tenant3];

    // Sample verifications
    final verification1 = Verification(
      id: _uuid.v4(),
      tenantId: tenant1.id,
      status: VerificationStatus.verified,
      documentIds: [],
      steps: Verification.createInitialSteps().map((s) => s.copyWith(
        isCompleted: true,
        completedAt: now.subtract(const Duration(days: 28)),
        result: 'Success',
      )).toList(),
      merkleRoot: '0x${_blockchainService.computeStringHash('sample1')}',
      transactionHash: '0x${_blockchainService.computeStringHash('tx1')}',
      startedAt: now.subtract(const Duration(days: 30)),
      completedAt: now.subtract(const Duration(days: 28)),
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(days: 28)),
    );

    final verification2 = Verification(
      id: _uuid.v4(),
      tenantId: tenant2.id,
      status: VerificationStatus.verified,
      documentIds: [],
      steps: Verification.createInitialSteps().map((s) => s.copyWith(
        isCompleted: true,
        completedAt: now.subtract(const Duration(days: 13)),
        result: 'Success',
      )).toList(),
      merkleRoot: '0x${_blockchainService.computeStringHash('sample2')}',
      transactionHash: '0x${_blockchainService.computeStringHash('tx2')}',
      startedAt: now.subtract(const Duration(days: 15)),
      completedAt: now.subtract(const Duration(days: 13)),
      createdAt: now.subtract(const Duration(days: 15)),
      updatedAt: now.subtract(const Duration(days: 13)),
    );

    final verification3 = Verification(
      id: _uuid.v4(),
      tenantId: tenant3.id,
      status: VerificationStatus.pending,
      documentIds: [],
      steps: Verification.createInitialSteps(),
      startedAt: now.subtract(const Duration(days: 5)),
      createdAt: now.subtract(const Duration(days: 7)),
      updatedAt: now.subtract(const Duration(days: 5)),
    );

    _verifications = [verification1, verification2, verification3];

    // Sample certificates for verified tenants
    final cert1 = Certificate(
      id: _uuid.v4(),
      verificationId: verification1.id,
      tenantId: tenant1.id,
      tenantName: tenant1.name,
      certificateNumber: 'TV-2025-${tenant1.id.substring(0, 8).toUpperCase()}',
      issueDate: now.subtract(const Duration(days: 28)),
      expiryDate: now.add(const Duration(days: 337)),
      landlordAddress: '0x742d35Cc6634C0532925a3b844Bc9e7595f2bD9e',
      transactionHash: verification1.transactionHash!,
      merkleRoot: verification1.merkleRoot!,
      qrCodeData: 'https://tenantverify.app/certificate/${verification1.id}',
      createdAt: now.subtract(const Duration(days: 28)),
      updatedAt: now.subtract(const Duration(days: 28)),
    );

    final cert2 = Certificate(
      id: _uuid.v4(),
      verificationId: verification2.id,
      tenantId: tenant2.id,
      tenantName: tenant2.name,
      certificateNumber: 'TV-2025-${tenant2.id.substring(0, 8).toUpperCase()}',
      issueDate: now.subtract(const Duration(days: 13)),
      expiryDate: now.add(const Duration(days: 352)),
      landlordAddress: '0x742d35Cc6634C0532925a3b844Bc9e7595f2bD9e',
      transactionHash: verification2.transactionHash!,
      merkleRoot: verification2.merkleRoot!,
      qrCodeData: 'https://tenantverify.app/certificate/${verification2.id}',
      createdAt: now.subtract(const Duration(days: 13)),
      updatedAt: now.subtract(const Duration(days: 13)),
    );

    _certificates = [cert1, cert2];

    await _saveData();
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tenantsKey, jsonEncode(_tenants.map((e) => e.toJson()).toList()));
      await prefs.setString(_verificationsKey, jsonEncode(_verifications.map((e) => e.toJson()).toList()));
      await prefs.setString(_certificatesKey, jsonEncode(_certificates.map((e) => e.toJson()).toList()));
      await prefs.setString(_documentsKey, jsonEncode(_documents.map((e) => e.toJson()).toList()));
    } catch (e) {
      debugPrint('Failed to save verification data: $e');
    }
  }

  // Tenant operations
  List<Tenant> getTenants() => List.from(_tenants);

  Tenant? getTenantById(String id) {
    try {
      return _tenants.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Tenant> createTenant({
    required String name,
    required String email,
    required String phone,
    required DateTime dob,
    required String aadhaarLast4,
  }) async {
    final now = DateTime.now();
    final tenant = Tenant(
      id: _uuid.v4(),
      name: name,
      email: email,
      phone: phone,
      dob: dob,
      aadhaarLast4: aadhaarLast4,
      createdAt: now,
      updatedAt: now,
    );

    _tenants.add(tenant);
    await _saveData();
    return tenant;
  }

  // Document operations
  List<TenantDocument> getDocumentsForTenant(String tenantId) =>
      _documents.where((d) => d.tenantId == tenantId).toList();

  Future<TenantDocument> addDocument({
    required String tenantId,
    required DocumentType type,
    required String fileName,
    required int fileSize,
    required Uint8List fileBytes,
  }) async {
    final hash = _blockchainService.computeFileHash(fileBytes);
    
    final document = TenantDocument(
      id: _uuid.v4(),
      tenantId: tenantId,
      type: type,
      fileName: fileName,
      fileSize: fileSize,
      hash: hash,
      uploadedAt: DateTime.now(),
      fileBytes: fileBytes,
    );

    _documents.add(document);
    await _saveData();
    return document;
  }

  // Verification operations
  List<Verification> getVerifications() => List.from(_verifications);

  Verification? getVerificationById(String id) {
    try {
      return _verifications.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  Verification? getVerificationForTenant(String tenantId) {
    try {
      return _verifications.firstWhere((v) => v.tenantId == tenantId);
    } catch (_) {
      return null;
    }
  }

  Future<Verification> createVerification({
    required String tenantId,
    required List<String> documentIds,
  }) async {
    final now = DateTime.now();
    final verification = Verification(
      id: _uuid.v4(),
      tenantId: tenantId,
      status: VerificationStatus.pending,
      documentIds: documentIds,
      steps: Verification.createInitialSteps(),
      startedAt: now,
      createdAt: now,
      updatedAt: now,
    );

    _verifications.add(verification);
    await _saveData();
    return verification;
  }

  Future<Verification> runVerificationWorkflow(
    Verification verification,
    String landlordAddress,
    Function(Verification) onStepComplete,
  ) async {
    var current = verification.copyWith(status: VerificationStatus.processing);
    _updateVerification(current);
    onStepComplete(current);

    final documents = _documents.where((d) => current.documentIds.contains(d.id)).toList();
    final hashes = documents.map((d) => d.hash).toList();

    // Step 1: File Hashing (already done during upload)
    await Future.delayed(const Duration(seconds: 1));
    current = _updateStep(current, 0, true, 'Hashes computed for ${documents.length} documents');
    onStepComplete(current);

    // Step 2: Merkle Root Creation
    await Future.delayed(const Duration(seconds: 1));
    final merkleRoot = _blockchainService.computeMerkleRoot(hashes);
    current = _updateStep(current, 1, true, '0x$merkleRoot');
    current = current.copyWith(merkleRoot: '0x$merkleRoot');
    _updateVerification(current);
    onStepComplete(current);

    // Step 3: Government Verification (Mock)
    await Future.delayed(const Duration(seconds: 2));
    current = _updateStep(current, 2, true, 'All documents verified successfully');
    _updateVerification(current);
    onStepComplete(current);

    // Step 4: Blockchain Storage
    await Future.delayed(const Duration(seconds: 1));
    final transaction = await _blockchainService.createTransaction(
      merkleRoot: '0x$merkleRoot',
      issuerAddress: landlordAddress,
      issueDate: DateTime.now(),
      expiryDate: DateTime.now().add(const Duration(days: 365)),
    );

    current = _updateStep(current, 3, true, transaction.transactionHash);
    current = current.copyWith(
      status: VerificationStatus.verified,
      transactionHash: transaction.transactionHash,
      completedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _updateVerification(current);
    onStepComplete(current);

    // Create certificate
    await _createCertificateForVerification(current, landlordAddress);

    return current;
  }

  Verification _updateStep(Verification verification, int index, bool completed, String result) {
    final steps = List<VerificationStep>.from(verification.steps);
    steps[index] = steps[index].copyWith(
      isCompleted: completed,
      completedAt: DateTime.now(),
      result: result,
    );
    return verification.copyWith(steps: steps, updatedAt: DateTime.now());
  }

  void _updateVerification(Verification verification) {
    final index = _verifications.indexWhere((v) => v.id == verification.id);
    if (index != -1) {
      _verifications[index] = verification;
      _saveData();
    }
  }

  // Certificate operations
  List<Certificate> getCertificates() => List.from(_certificates);

  Certificate? getCertificateById(String id) {
    try {
      return _certificates.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Certificate? getCertificateForTenant(String tenantId) {
    try {
      return _certificates.firstWhere((c) => c.tenantId == tenantId && !c.isRevoked);
    } catch (_) {
      return null;
    }
  }

  Future<Certificate> _createCertificateForVerification(
    Verification verification,
    String landlordAddress,
  ) async {
    final tenant = getTenantById(verification.tenantId);
    final now = DateTime.now();

    final certificate = Certificate(
      id: _uuid.v4(),
      verificationId: verification.id,
      tenantId: verification.tenantId,
      tenantName: tenant?.name ?? 'Unknown',
      certificateNumber: 'TV-2025-${verification.id.substring(0, 8).toUpperCase()}',
      issueDate: now,
      expiryDate: now.add(const Duration(days: 365)),
      landlordAddress: landlordAddress,
      transactionHash: verification.transactionHash!,
      merkleRoot: verification.merkleRoot!,
      qrCodeData: 'https://tenantverify.app/certificate/${verification.id}',
      createdAt: now,
      updatedAt: now,
    );

    _certificates.add(certificate);
    await _saveData();
    return certificate;
  }

  Future<Certificate> revokeCertificate(String certificateId, String landlordAddress) async {
    final index = _certificates.indexWhere((c) => c.id == certificateId);
    if (index == -1) throw Exception('Certificate not found');

    await _blockchainService.revokeCertificate(
      originalTransactionHash: _certificates[index].transactionHash,
      issuerAddress: landlordAddress,
    );

    final revoked = _certificates[index].copyWith(
      isRevoked: true,
      revokedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _certificates[index] = revoked;

    // Update verification status
    final vIndex = _verifications.indexWhere((v) => v.id == revoked.verificationId);
    if (vIndex != -1) {
      _verifications[vIndex] = _verifications[vIndex].copyWith(
        status: VerificationStatus.revoked,
        updatedAt: DateTime.now(),
      );
    }

    await _saveData();
    return revoked;
  }

  // Stats
  Map<String, int> getStats() {
    return {
      'totalTenants': _tenants.length,
      'verified': _verifications.where((v) => v.status == VerificationStatus.verified).length,
      'pending': _verifications.where((v) => v.status == VerificationStatus.pending).length,
      'certificates': _certificates.where((c) => !c.isRevoked).length,
    };
  }
}
