import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/theme.dart';
import 'package:project/components/buttons.dart';
import 'package:project/components/responsive_layout.dart';
import 'package:project/components/animations.dart';

class HowItWorksScreen extends StatefulWidget {
  const HowItWorksScreen({super.key});

  @override
  State<HowItWorksScreen> createState() => _HowItWorksScreenState();
}

class _HowItWorksScreenState extends State<HowItWorksScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.of(context).size.width >= Breakpoints.tablet;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/'),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.neonGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('TV', style: TextStyle(color: AppColors.background, fontWeight: FontWeight.w900, fontSize: 10)),
              ),
            ),
            const SizedBox(width: 10),
            const Text('TenantVerify'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PrimaryButton(label: 'Get Started', onPressed: () => context.go('/auth')),
          ),
        ],
      ),
      body: Stack(
        children: [
          const ParticleBackground(particleCount: 20, particleColor: AppColors.electricBlue),
          FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ContentContainer(
                maxWidth: 1100,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildHero(textTheme),
                    const SizedBox(height: 80),
                    _buildWorkflowSteps(textTheme, isWide),
                    const SizedBox(height: 80),
                    _buildTechnicalDeepDive(textTheme, isWide),
                    const SizedBox(height: 80),
                    _buildUseCases(textTheme, isWide),
                    const SizedBox(height: 80),
                    _buildFaq(textTheme),
                    const SizedBox(height: 80),
                    _buildCta(textTheme),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(TextTheme textTheme) {
    return Column(
      children: [
        const BlockchainNodes(size: 150, nodeCount: 5, duration: Duration(seconds: 15)),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.electricBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.electricBlue.withValues(alpha: 0.3)),
          ),
          child: Text(
            'VERIFICATION WORKFLOW',
            style: textTheme.labelSmall?.copyWith(color: AppColors.electricBlue, fontWeight: FontWeight.w600, letterSpacing: 2),
          ),
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => AppColors.neonGradient.createShader(bounds),
          child: Text(
            'How TenantVerify Works',
            style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'A step-by-step journey from document upload to\nimmutable blockchain certification.',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.6),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWorkflowSteps(TextTheme textTheme, bool isWide) {
    final steps = [
      _StepData(
        number: '01',
        title: 'Tenant Onboarding',
        description: 'Landlord enters tenant details including name, email, phone, and date of birth. The tenant receives a notification about the verification process.',
        icon: Icons.person_add_rounded,
        color: AppColors.textSecondary,
        details: ['Basic KYC information collected', 'Tenant consent obtained', 'Secure data encryption'],
      ),
      _StepData(
        number: '02',
        title: 'Document Upload',
        description: 'Tenant uploads identity documents (Aadhaar, PAN) through a secure encrypted channel. Documents are processed locally - never stored on our servers.',
        icon: Icons.upload_file_rounded,
        color: AppColors.cyberPurple,
        details: ['Aadhaar Card (mandatory)', 'PAN Card (mandatory)', 'Employment proof (optional)'],
      ),
      _StepData(
        number: '03',
        title: 'Cryptographic Hashing',
        description: 'Each document is processed through SHA-256 algorithm to generate a unique 64-character hash. This hash acts as a digital fingerprint.',
        icon: Icons.fingerprint_rounded,
        color: AppColors.warning,
        details: ['SHA-256 algorithm', 'Unique document fingerprint', 'Collision-resistant'],
      ),
      _StepData(
        number: '04',
        title: 'Merkle Tree Generation',
        description: 'Individual document hashes are combined into a Merkle tree structure, producing a single root hash that represents all documents.',
        icon: Icons.account_tree_rounded,
        color: AppColors.electricBlue,
        details: ['Efficient batch verification', 'Single proof for multiple docs', 'Mathematical certainty'],
      ),
      _StepData(
        number: '05',
        title: 'Government API Verification',
        description: 'Documents are validated against official government databases (UIDAI for Aadhaar, Income Tax for PAN) in real-time.',
        icon: Icons.verified_user_rounded,
        color: AppColors.error,
        details: ['Real-time API validation', 'Official database check', 'Fraud detection'],
      ),
      _StepData(
        number: '06',
        title: 'Blockchain Anchoring',
        description: 'The Merkle root is permanently recorded on the Polygon blockchain, creating an immutable timestamp that cannot be altered or deleted.',
        icon: Icons.link_rounded,
        color: AppColors.neonGreen,
        details: ['Polygon network', 'Gas-efficient storage', 'Permanent record'],
      ),
      _StepData(
        number: '07',
        title: 'Certificate Generation',
        description: 'A professional PDF certificate is generated with embedded QR code linking to the blockchain proof. This certificate is the tenant\'s portable trust credential.',
        icon: Icons.workspace_premium_rounded,
        color: AppColors.neonGreen,
        details: ['PDF with QR code', 'Instant verification', 'Reusable across landlords'],
      ),
    ];

    return Column(
      children: [
        Text('THE PROCESS', style: textTheme.labelSmall?.copyWith(color: AppColors.neonGreen, letterSpacing: 2)),
        const SizedBox(height: 16),
        Text('7 Steps to Trust', style: textTheme.headlineMedium?.semiBold, textAlign: TextAlign.center),
        const SizedBox(height: 48),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: steps.length,
          itemBuilder: (context, index) {
            final step = steps[index];
            final isLast = index == steps.length - 1;
            return _WorkflowStep(step: step, isLast: isLast, isWide: isWide);
          },
        ),
      ],
    );
  }

  Widget _buildTechnicalDeepDive(TextTheme textTheme, bool isWide) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Text('TECHNICAL DEEP DIVE', style: textTheme.labelSmall?.copyWith(color: AppColors.cyberPurple, letterSpacing: 2)),
          const SizedBox(height: 16),
          Text('Under the Hood', style: textTheme.headlineSmall?.semiBold),
          const SizedBox(height: 32),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              _TechCard(
                icon: Icons.code_rounded,
                title: 'SHA-256 Algorithm',
                code: 'hash = SHA256(document)\n// Output: 64-char hex string\n// e7d3...9a2f',
              ),
              _TechCard(
                icon: Icons.account_tree_rounded,
                title: 'Merkle Root',
                code: 'root = hash(hash(A+B), hash(C+D))\n// Single proof for N docs\n// O(log N) verification',
              ),
              _TechCard(
                icon: Icons.hexagon_rounded,
                title: 'Smart Contract',
                code: 'function anchor(bytes32 root)\n  emit ProofAnchored(\n    root, block.timestamp\n  )',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUseCases(TextTheme textTheme, bool isWide) {
    return Column(
      children: [
        Text('USE CASES', style: textTheme.labelSmall?.copyWith(color: AppColors.warning, letterSpacing: 2)),
        const SizedBox(height: 16),
        Text('Who Benefits?', style: textTheme.headlineMedium?.semiBold, textAlign: TextAlign.center),
        const SizedBox(height: 40),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isWide ? 3 : 1,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: isWide ? 1.2 : 2.5,
          children: const [
            _UseCaseCard(
              icon: Icons.apartment_rounded,
              title: 'Landlords',
              benefits: ['Verify tenants in 90 seconds', 'Eliminate fraud risk', 'Reduce legal disputes'],
            ),
            _UseCaseCard(
              icon: Icons.people_rounded,
              title: 'Tenants',
              benefits: ['Verify once, use everywhere', 'Portable trust credential', 'Faster rental approvals'],
            ),
            _UseCaseCard(
              icon: Icons.business_rounded,
              title: 'Property Managers',
              benefits: ['Bulk verification support', 'Analytics dashboard', 'API integration'],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFaq(TextTheme textTheme) {
    final faqs = [
      ('How long does verification take?', 'The entire process typically completes in under 90 seconds. Document hashing is instant, and blockchain anchoring takes about 15-30 seconds.'),
      ('What if a document is modified after verification?', 'Any modification will change the document\'s hash. When the modified document is checked against the blockchain proof, verification will fail immediately.'),
      ('Is my data stored on the blockchain?', 'No. Only the cryptographic hash (a mathematical fingerprint) is stored on blockchain. Your actual documents and personal data never leave your device.'),
      ('Can I verify the same tenant again?', 'Tenants can reuse their verification certificate with multiple landlords. This eliminates redundant verifications and speeds up the rental process.'),
    ];

    return Column(
      children: [
        Text('FAQ', style: textTheme.labelSmall?.copyWith(color: AppColors.electricBlue, letterSpacing: 2)),
        const SizedBox(height: 16),
        Text('Common Questions', style: textTheme.headlineMedium?.semiBold, textAlign: TextAlign.center),
        const SizedBox(height: 32),
        ...faqs.map((faq) => _FaqItem(question: faq.$1, answer: faq.$2)),
      ],
    );
  }

  Widget _buildCta(TextTheme textTheme) {
    return AnimatedGradientBorder(
      borderRadius: AppRadius.xl,
      borderWidth: 2,
      child: Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          children: [
            Text('Start Verifying Today', style: textTheme.headlineMedium?.semiBold, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              'Experience the future of trust verification with blockchain-backed security.',
              style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                GlowingButton(label: 'Start Verification', icon: Icons.verified_rounded, onPressed: () => context.go('/auth')),
                SecondaryButton(label: 'Read Documentation', icon: Icons.menu_book_rounded, onPressed: () => context.go('/docs')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepData {
  final String number;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> details;
  const _StepData({required this.number, required this.title, required this.description, required this.icon, required this.color, required this.details});
}

class _WorkflowStep extends StatelessWidget {
  final _StepData step;
  final bool isLast;
  final bool isWide;
  const _WorkflowStep({required this.step, required this.isLast, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline
        SizedBox(
          width: 60,
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: step.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: step.color.withValues(alpha: 0.5)),
                ),
                child: Icon(step.icon, color: step.color, size: 24),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 80,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [step.color.withValues(alpha: 0.5), step.color.withValues(alpha: 0.1)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : 32),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(step.number, style: textTheme.labelMedium?.copyWith(color: step.color, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(step.title, style: textTheme.titleMedium?.semiBold)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(step.description, style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted, height: 1.5)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: step.details.map((d) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: step.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(d, style: textTheme.labelSmall?.copyWith(color: step.color)),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TechCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String code;
  const _TechCard({required this.icon, required this.title, required this.code});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: 280,
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
              Icon(icon, color: AppColors.cyberPurple, size: 20),
              const SizedBox(width: 8),
              Text(title, style: textTheme.labelMedium?.semiBold),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              code,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.neonGreen, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _UseCaseCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> benefits;
  const _UseCaseCard({required this.icon, required this.title, required this.benefits});

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
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: AppColors.warning, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: textTheme.titleMedium?.semiBold),
          const SizedBox(height: 12),
          ...benefits.map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.neonGreen, size: 14),
                const SizedBox(width: 8),
                Expanded(child: Text(b, style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted))),
              ],
            ),
          )),
        ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: _isExpanded ? AppColors.neonGreen.withValues(alpha: 0.3) : AppColors.cardBorder),
      ),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(widget.question, style: textTheme.titleSmall?.semiBold)),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(widget.answer, style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted, height: 1.5)),
                ),
                crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
