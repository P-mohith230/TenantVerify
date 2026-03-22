import 'package:flutter/foundation.dart';
import 'package:project/models/tenant.dart';
import 'package:project/models/verification.dart';
import 'package:project/models/certificate.dart';
import 'package:project/services/verification_service.dart';

class VerificationProvider with ChangeNotifier {
  final VerificationService _service = VerificationService();

  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  
  // Current verification workflow state
  Tenant? _currentTenant;
  List<TenantDocument> _currentDocuments = [];
  Verification? _currentVerification;

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  Tenant? get currentTenant => _currentTenant;
  List<TenantDocument> get currentDocuments => _currentDocuments;
  Verification? get currentVerification => _currentVerification;

  List<Tenant> get tenants => _service.getTenants();
  List<Verification> get verifications => _service.getVerifications();
  List<Certificate> get certificates => _service.getCertificates();
  Map<String, int> get stats => _service.getStats();

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.initialize();
    } catch (e) {
      debugPrint('Failed to initialize verification service: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Tenant? getTenantById(String id) => _service.getTenantById(id);
  Verification? getVerificationById(String id) => _service.getVerificationById(id);
  Verification? getVerificationForTenant(String tenantId) => _service.getVerificationForTenant(tenantId);
  Certificate? getCertificateById(String id) => _service.getCertificateById(id);
  Certificate? getCertificateForTenant(String tenantId) => _service.getCertificateForTenant(tenantId);

  // Wizard Step 1: Create Tenant
  Future<bool> createTenant({
    required String name,
    required String email,
    required String phone,
    required DateTime dob,
    required String aadhaarLast4,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentTenant = await _service.createTenant(
        name: name,
        email: email,
        phone: phone,
        dob: dob,
        aadhaarLast4: aadhaarLast4,
      );
      _currentDocuments = [];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Wizard Step 2: Add Documents
  Future<bool> addDocument({
    required DocumentType type,
    required String fileName,
    required int fileSize,
    required Uint8List fileBytes,
  }) async {
    if (_currentTenant == null) {
      _error = 'No tenant selected';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final doc = await _service.addDocument(
        tenantId: _currentTenant!.id,
        type: type,
        fileName: fileName,
        fileSize: fileSize,
        fileBytes: fileBytes,
      );
      
      // Replace if same type exists
      _currentDocuments.removeWhere((d) => d.type == type);
      _currentDocuments.add(doc);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void removeDocument(DocumentType type) {
    _currentDocuments.removeWhere((d) => d.type == type);
    notifyListeners();
  }

  bool hasDocument(DocumentType type) =>
      _currentDocuments.any((d) => d.type == type);

  TenantDocument? getDocument(DocumentType type) {
    try {
      return _currentDocuments.firstWhere((d) => d.type == type);
    } catch (_) {
      return null;
    }
  }

  // Wizard Step 3: Start Verification
  Future<Verification?> startVerification(String landlordAddress) async {
    if (_currentTenant == null || _currentDocuments.isEmpty) {
      _error = 'Missing tenant or documents';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create verification record
      _currentVerification = await _service.createVerification(
        tenantId: _currentTenant!.id,
        documentIds: _currentDocuments.map((d) => d.id).toList(),
      );
      notifyListeners();

      // Run the workflow
      _currentVerification = await _service.runVerificationWorkflow(
        _currentVerification!,
        landlordAddress,
        (updated) {
          _currentVerification = updated;
          notifyListeners();
        },
      );

      _isLoading = false;
      notifyListeners();
      return _currentVerification;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> revokeCertificate(String certificateId, String landlordAddress) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.revokeCertificate(certificateId, landlordAddress);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void resetWizard() {
    _currentTenant = null;
    _currentDocuments = [];
    _currentVerification = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
