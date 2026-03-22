import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:project/theme.dart';
import 'package:project/components/buttons.dart';
import 'package:project/components/app_card.dart';
import 'package:project/components/file_upload_card.dart';
import 'package:project/components/step_timeline.dart';
import 'package:project/components/responsive_layout.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:project/providers/verification_provider.dart';
import 'package:project/models/tenant.dart';

class VerificationWizardScreen extends StatefulWidget {
  const VerificationWizardScreen({super.key});

  @override
  State<VerificationWizardScreen> createState() => _VerificationWizardScreenState();
}

class _VerificationWizardScreenState extends State<VerificationWizardScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  // Step 1: Tenant details
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _aadhaarController = TextEditingController();
  DateTime? _selectedDob;
  
  // Step 3: Consent
  bool _tenantConsent = false;
  bool _landlordDeclaration = false;
  bool _privacyAccepted = false;
  
  // Loading states
  Map<DocumentType, bool> _uploadingDocs = {};

  @override
  void initState() {
    super.initState();
    // Add listeners to trigger rebuild when text changes
    _nameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _aadhaarController.addListener(_onFieldChanged);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VerificationProvider>().resetWizard();
    });
  }
  
  void _onFieldChanged() {
    setState(() {}); // Trigger rebuild to update button state
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _emailController.removeListener(_onFieldChanged);
    _phoneController.removeListener(_onFieldChanged);
    _aadhaarController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _aadhaarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            context.read<VerificationProvider>().resetWizard();
            context.pop();
          },
        ),
        title: const Text('New Verification'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step indicator
            Padding(
              padding: const EdgeInsets.all(24),
              child: WizardStepIndicator(
                steps: const ['Details', 'Documents', 'Consent'],
                currentStep: _currentStep,
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: ContentContainer(
                  maxWidth: 600,
                  padding: EdgeInsets.zero,
                  child: _buildCurrentStep(),
                ),
              ),
            ),
            // Navigation buttons
            _buildNavigationButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _TenantDetailsStep(
          formKey: _formKey,
          nameController: _nameController,
          emailController: _emailController,
          phoneController: _phoneController,
          aadhaarController: _aadhaarController,
          selectedDob: _selectedDob,
          onDobChanged: (date) => setState(() => _selectedDob = date),
        );
      case 1:
        return _DocumentUploadStep(
          uploadingDocs: _uploadingDocs,
          onUploadDocument: _uploadDocument,
          onRemoveDocument: _removeDocument,
        );
      case 2:
        return _ConsentStep(
          tenantConsent: _tenantConsent,
          landlordDeclaration: _landlordDeclaration,
          privacyAccepted: _privacyAccepted,
          onTenantConsentChanged: (v) => setState(() => _tenantConsent = v ?? false),
          onLandlordDeclarationChanged: (v) => setState(() => _landlordDeclaration = v ?? false),
          onPrivacyAcceptedChanged: (v) => setState(() => _privacyAccepted = v ?? false),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNavigationButtons(BuildContext context) {
    final provider = context.watch<VerificationProvider>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            SecondaryButton(
              label: 'Back',
              icon: Icons.arrow_back_rounded,
              onPressed: () => setState(() => _currentStep--),
            ),
          const Spacer(),
          _currentStep == 2
              ? Container(
                  decoration: _canProceed() ? BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonGreen.withValues(alpha: 0.4),
                        blurRadius: 20,
                      ),
                    ],
                  ) : null,
                  child: ElevatedButton.icon(
                    onPressed: _canProceed() && !provider.isLoading ? _handleNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonGreen,
                      foregroundColor: AppColors.background,
                      disabledBackgroundColor: AppColors.surfaceLight,
                      disabledForegroundColor: AppColors.textMuted,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    icon: provider.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.background,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Start Verification'),
                  ),
                )
              : PrimaryButton(
                  label: 'Continue',
                  icon: Icons.arrow_forward_rounded,
                  isLoading: provider.isLoading,
                  onPressed: _canProceed() ? _handleNext : null,
                ),
        ],
      ),
    );
  }

  bool _canProceed() {
    final provider = context.read<VerificationProvider>();
    
    switch (_currentStep) {
      case 0:
        return _nameController.text.isNotEmpty &&
               _emailController.text.isNotEmpty &&
               _phoneController.text.isNotEmpty &&
               _aadhaarController.text.length == 4 &&
               _selectedDob != null;
      case 1:
        return provider.hasDocument(DocumentType.aadhaar) &&
               provider.hasDocument(DocumentType.pan);
      case 2:
        return _tenantConsent && _landlordDeclaration && _privacyAccepted;
      default:
        return false;
    }
  }

  Future<void> _handleNext() async {
    final provider = context.read<VerificationProvider>();
    final auth = context.read<AuthProvider>();

    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) return;
      
      final success = await provider.createTenant(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        dob: _selectedDob!,
        aadhaarLast4: _aadhaarController.text.trim(),
      );
      
      if (success) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      setState(() => _currentStep++);
    } else if (_currentStep == 2) {
      final landlordAddress = auth.user?.walletAddress ?? '0x742d35Cc6634C0532925a3b844Bc9e7595f2bD9e';
      final verification = await provider.startVerification(landlordAddress);
      
      if (verification != null && mounted) {
        context.go('/progress/${verification.id}');
      }
    }
  }

  Future<void> _uploadDocument(DocumentType type) async {
    setState(() => _uploadingDocs[type] = true);
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          await context.read<VerificationProvider>().addDocument(
            type: type,
            fileName: file.name,
            fileSize: file.size,
            fileBytes: file.bytes!,
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _uploadingDocs[type] = false);
      }
    }
  }

  void _removeDocument(DocumentType type) {
    context.read<VerificationProvider>().removeDocument(type);
  }
}

class _TenantDetailsStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController aadhaarController;
  final DateTime? selectedDob;
  final Function(DateTime?) onDobChanged;

  const _TenantDetailsStep({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.aadhaarController,
    required this.selectedDob,
    required this.onDobChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dateFormat = DateFormat('dd MMM yyyy');

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tenant Details', style: textTheme.titleLarge?.semiBold),
          const SizedBox(height: 8),
          Text(
            'Enter the tenant\'s basic information for verification',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 32),
          
          TextFormField(
            controller: nameController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.textMuted),
            ),
            validator: (v) => v?.isEmpty ?? true ? 'Name is required' : null,
          ),
          const SizedBox(height: 20),
          
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Email Address *',
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted),
            ),
            validator: (v) {
              if (v?.isEmpty ?? true) return 'Email is required';
              if (!v!.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Phone Number *',
              prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textMuted),
              hintText: '+91 98765 43210',
            ),
            validator: (v) => v?.isEmpty ?? true ? 'Phone is required' : null,
          ),
          const SizedBox(height: 20),
          
          // Date of Birth
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDob ?? DateTime(1990),
                firstDate: DateTime(1940),
                lastDate: DateTime.now().subtract(const Duration(days: 6570)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: AppColors.neonGreen,
                        surface: AppColors.surface,
                        onSurface: AppColors.textPrimary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) onDobChanged(date);
            },
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Date of Birth *',
                prefixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.textMuted),
                suffixIcon: Icon(Icons.arrow_drop_down_rounded, color: AppColors.textMuted),
              ),
              child: Text(
                selectedDob != null ? dateFormat.format(selectedDob!) : 'Select date',
                style: TextStyle(
                  color: selectedDob != null ? AppColors.textPrimary : AppColors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          TextFormField(
            controller: aadhaarController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Aadhaar Last 4 Digits *',
              prefixIcon: Icon(Icons.badge_outlined, color: AppColors.textMuted),
              counterText: '',
              hintText: '1234',
            ),
            validator: (v) {
              if (v?.isEmpty ?? true) return 'Required';
              if (v!.length != 4) return 'Enter exactly 4 digits';
              return null;
            },
          ),
          
          const SizedBox(height: 24),
          
          // Privacy note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.electricBlue.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 20, color: AppColors.electricBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Only the last 4 digits of Aadhaar are stored. Full documents are hashed, not stored.',
                    style: textTheme.bodySmall?.copyWith(color: AppColors.electricBlue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentUploadStep extends StatelessWidget {
  final Map<DocumentType, bool> uploadingDocs;
  final Function(DocumentType) onUploadDocument;
  final Function(DocumentType) onRemoveDocument;

  const _DocumentUploadStep({
    required this.uploadingDocs,
    required this.onUploadDocument,
    required this.onRemoveDocument,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final provider = context.watch<VerificationProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Document Upload', style: textTheme.titleLarge?.semiBold),
        const SizedBox(height: 8),
        Text(
          'Upload identity documents for verification',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 32),
        
        ...DocumentType.values.map((type) {
          final doc = provider.getDocument(type);
          final isRequired = type != DocumentType.employment;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FileUploadCard(
                  documentType: type,
                  fileName: doc?.fileName,
                  fileSize: doc?.fileSize,
                  isUploaded: doc != null,
                  isLoading: uploadingDocs[type] ?? false,
                  onUpload: () => onUploadDocument(type),
                  onRemove: doc != null ? () => onRemoveDocument(type) : null,
                ),
                if (isRequired && doc == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 8),
                    child: Text(
                      'Required',
                      style: textTheme.labelSmall?.copyWith(color: AppColors.error),
                    ),
                  ),
              ],
            ),
          );
        }),
        
        const SizedBox(height: 16),
        
        // Upload info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Accepted formats', style: textTheme.labelMedium?.semiBold),
              const SizedBox(height: 8),
              Text(
                'PDF, JPG, PNG • Max 10MB per file',
                style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConsentStep extends StatelessWidget {
  final bool tenantConsent;
  final bool landlordDeclaration;
  final bool privacyAccepted;
  final Function(bool?) onTenantConsentChanged;
  final Function(bool?) onLandlordDeclarationChanged;
  final Function(bool?) onPrivacyAcceptedChanged;

  const _ConsentStep({
    required this.tenantConsent,
    required this.landlordDeclaration,
    required this.privacyAccepted,
    required this.onTenantConsentChanged,
    required this.onLandlordDeclarationChanged,
    required this.onPrivacyAcceptedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Consent & Submission', style: textTheme.titleLarge?.semiBold),
        const SizedBox(height: 8),
        Text(
          'Review and confirm before submission',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 32),
        
        _ConsentCheckbox(
          value: tenantConsent,
          onChanged: onTenantConsentChanged,
          title: 'Tenant Consent Obtained',
          description: 'I confirm that the tenant has provided explicit consent for document verification and blockchain proof storage.',
        ),
        const SizedBox(height: 16),
        
        _ConsentCheckbox(
          value: landlordDeclaration,
          onChanged: onLandlordDeclarationChanged,
          title: 'Landlord Declaration',
          description: 'I declare that the information provided is accurate and I am authorized to initiate this verification.',
        ),
        const SizedBox(height: 16),
        
        _ConsentCheckbox(
          value: privacyAccepted,
          onChanged: onPrivacyAcceptedChanged,
          title: 'Privacy Policy Acceptance',
          description: 'I have read and accept the privacy policy and terms of service.',
        ),
        
        const SizedBox(height: 32),
        
        // What happens next
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.cyberPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(
                      Icons.rocket_launch_rounded,
                      color: AppColors.cyberPurple,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('What happens next?', style: textTheme.titleSmall?.semiBold),
                ],
              ),
              const SizedBox(height: 16),
              _NextStepItem(
                icon: Icons.fingerprint_rounded,
                text: 'Documents are hashed using SHA-256',
                color: AppColors.electricBlue,
              ),
              _NextStepItem(
                icon: Icons.account_tree_rounded,
                text: 'Merkle root is computed from hashes',
                color: AppColors.warning,
              ),
              _NextStepItem(
                icon: Icons.verified_user_rounded,
                text: 'Government APIs verify documents',
                color: AppColors.cyberPurple,
              ),
              _NextStepItem(
                icon: Icons.link_rounded,
                text: 'Proof is recorded on Polygon blockchain',
                color: AppColors.neonGreen,
              ),
              _NextStepItem(
                icon: Icons.workspace_premium_rounded,
                text: 'Trust certificate is generated',
                color: AppColors.neonGreen,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConsentCheckbox extends StatelessWidget {
  final bool value;
  final Function(bool?) onChanged;
  final String title;
  final String description;

  const _ConsentCheckbox({
    required this.value,
    required this.onChanged,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: value 
              ? AppColors.neonGreen.withValues(alpha: 0.05)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: value 
                ? AppColors.neonGreen.withValues(alpha: 0.3)
                : AppColors.cardBorder,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.neonGreen,
                checkColor: AppColors.background,
                side: BorderSide(
                  color: value ? AppColors.neonGreen : AppColors.textMuted,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.titleSmall?.semiBold),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextStepItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool isLast;

  const _NextStepItem({
    required this.icon,
    required this.text,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
