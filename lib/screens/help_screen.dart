import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/theme.dart';
import 'package:project/components/app_card.dart';
import 'package:project/components/responsive_layout.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Help & Privacy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ContentContainer(
          maxWidth: 700,
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.electricBlue.withValues(alpha: 0.1),
                      AppColors.cyberPurple.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.electricBlue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.electricBlue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: const Icon(
                        Icons.help_outline_rounded,
                        color: AppColors.electricBlue,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How can we help?',
                            style: textTheme.titleLarge?.semiBold,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Find answers and learn about TenantVerify',
                            style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // FAQ Section
              Text(
                'FREQUENTLY ASKED QUESTIONS',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              _FaqItem(
                question: 'What is TenantVerify?',
                answer: 'TenantVerify is a blockchain-powered platform that enables landlords to verify tenant identities and generate tamper-proof verification certificates.',
              ),
              _FaqItem(
                question: 'How does the verification work?',
                answer: 'Documents are converted into cryptographic hashes using SHA-256. These hashes are combined into a Merkle tree, and the root hash is recorded on the Polygon blockchain, creating an immutable proof.',
              ),
              _FaqItem(
                question: 'Is my data secure?',
                answer: 'Yes! We never store your actual documents on the blockchain. Only cryptographic fingerprints (hashes) are stored. Your documents are processed locally and only the proof is recorded.',
              ),
              _FaqItem(
                question: 'What blockchain network is used?',
                answer: 'TenantVerify uses the Polygon network for recording verification proofs. Currently running on Mumbai testnet for the prototype.',
              ),
              _FaqItem(
                question: 'Can certificates be revoked?',
                answer: 'Yes, landlords can revoke certificates at any time. The revocation is also recorded on the blockchain, and the certificate QR code will show the revoked status.',
              ),
              
              const SizedBox(height: 32),
              
              // Privacy Section
              Text(
                'PRIVACY POLICY',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PrivacySection(
                      title: 'Data Collection',
                      content: 'We collect only the minimum data required for verification: tenant name, email, phone, and document hashes. Full documents are processed locally and never stored on our servers.',
                    ),
                    _PrivacySection(
                      title: 'Data Storage',
                      content: 'Document hashes are stored on the Polygon blockchain. Personal information is stored securely with encryption. You can request deletion at any time.',
                    ),
                    _PrivacySection(
                      title: 'Data Sharing',
                      content: 'We do not sell or share your personal data with third parties. Verification proofs on the blockchain are public but contain no personally identifiable information.',
                    ),
                    _PrivacySection(
                      title: 'Your Rights',
                      content: 'You have the right to access, correct, or delete your data. Contact us at privacy@tenantverify.app for any data-related requests.',
                      isLast: true,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Contact Section
              Text(
                'CONTACT US',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ContactCard(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: 'support@tenantverify.app',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ContactCard(
                      icon: Icons.chat_outlined,
                      label: 'Discord',
                      value: 'Join our community',
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Footer
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: AppColors.neonGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'TV',
                              style: TextStyle(
                                color: AppColors.background,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('TenantVerify', style: textTheme.titleSmall?.semiBold),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Version 1.0.0 • Built for Dreamflow Buildathon 2025',
                      style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _isExpanded 
                  ? AppColors.neonGreen.withValues(alpha: 0.05)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: _isExpanded 
                    ? AppColors.neonGreen.withValues(alpha: 0.3)
                    : AppColors.cardBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.question,
                        style: textTheme.titleSmall?.copyWith(
                          color: _isExpanded ? AppColors.neonGreen : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.remove_rounded : Icons.add_rounded,
                      color: _isExpanded ? AppColors.neonGreen : AppColors.textMuted,
                    ),
                  ],
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.answer,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  final String title;
  final String content;
  final bool isLast;

  const _PrivacySection({
    required this.title,
    required this.content,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleSmall?.semiBold),
          const SizedBox(height: 8),
          Text(
            content,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.electricBlue, size: 20),
          ),
          const SizedBox(height: 12),
          Text(label, style: textTheme.labelMedium?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.bodySmall?.copyWith(color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
