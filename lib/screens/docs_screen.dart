import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/theme.dart';
import 'package:project/components/buttons.dart';
import 'package:project/components/responsive_layout.dart';
import 'package:project/components/animations.dart';

class DocsScreen extends StatefulWidget {
  const DocsScreen({super.key});

  @override
  State<DocsScreen> createState() => _DocsScreenState();
}

class _DocsScreenState extends State<DocsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String _selectedSection = 'getting-started';

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
            const Text('Documentation'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PrimaryButton(label: 'Start Building', onPressed: () => context.go('/auth')),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: isWide ? _buildDesktopLayout(textTheme) : _buildMobileLayout(textTheme),
      ),
    );
  }

  Widget _buildDesktopLayout(TextTheme textTheme) {
    return Row(
      children: [
        // Sidebar
        Container(
          width: 280,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(right: BorderSide(color: AppColors.cardBorder)),
          ),
          child: _buildSidebar(textTheme),
        ),
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: ContentContainer(
              maxWidth: 800,
              padding: EdgeInsets.zero,
              child: _buildContent(textTheme),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(TextTheme textTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMobileNav(textTheme),
          const SizedBox(height: 24),
          _buildContent(textTheme),
        ],
      ),
    );
  }

  Widget _buildSidebar(TextTheme textTheme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SidebarSection(
          title: 'GETTING STARTED',
          items: [
            _SidebarItem(id: 'getting-started', label: 'Introduction', icon: Icons.home_rounded),
            _SidebarItem(id: 'quick-start', label: 'Quick Start', icon: Icons.rocket_launch_rounded),
            _SidebarItem(id: 'installation', label: 'Installation', icon: Icons.download_rounded),
          ],
          selectedId: _selectedSection,
          onSelect: (id) => setState(() => _selectedSection = id),
        ),
        const SizedBox(height: 24),
        _SidebarSection(
          title: 'CORE CONCEPTS',
          items: [
            _SidebarItem(id: 'verification-flow', label: 'Verification Flow', icon: Icons.verified_rounded),
            _SidebarItem(id: 'blockchain-anchoring', label: 'Blockchain Anchoring', icon: Icons.link_rounded),
            _SidebarItem(id: 'certificates', label: 'Certificates', icon: Icons.workspace_premium_rounded),
          ],
          selectedId: _selectedSection,
          onSelect: (id) => setState(() => _selectedSection = id),
        ),
        const SizedBox(height: 24),
        _SidebarSection(
          title: 'API REFERENCE',
          items: [
            _SidebarItem(id: 'api-overview', label: 'API Overview', icon: Icons.api_rounded),
            _SidebarItem(id: 'authentication', label: 'Authentication', icon: Icons.vpn_key_rounded),
            _SidebarItem(id: 'endpoints', label: 'Endpoints', icon: Icons.webhook_rounded),
          ],
          selectedId: _selectedSection,
          onSelect: (id) => setState(() => _selectedSection = id),
        ),
        const SizedBox(height: 24),
        _SidebarSection(
          title: 'RESOURCES',
          items: [
            _SidebarItem(id: 'faq', label: 'FAQ', icon: Icons.help_outline_rounded),
            _SidebarItem(id: 'troubleshooting', label: 'Troubleshooting', icon: Icons.build_rounded),
            _SidebarItem(id: 'changelog', label: 'Changelog', icon: Icons.history_rounded),
          ],
          selectedId: _selectedSection,
          onSelect: (id) => setState(() => _selectedSection = id),
        ),
      ],
    );
  }

  Widget _buildMobileNav(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: DropdownButton<String>(
        value: _selectedSection,
        isExpanded: true,
        dropdownColor: AppColors.surface,
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
        items: [
          DropdownMenuItem(value: 'getting-started', child: Text('Introduction', style: textTheme.bodyMedium)),
          DropdownMenuItem(value: 'quick-start', child: Text('Quick Start', style: textTheme.bodyMedium)),
          DropdownMenuItem(value: 'verification-flow', child: Text('Verification Flow', style: textTheme.bodyMedium)),
          DropdownMenuItem(value: 'blockchain-anchoring', child: Text('Blockchain Anchoring', style: textTheme.bodyMedium)),
          DropdownMenuItem(value: 'api-overview', child: Text('API Overview', style: textTheme.bodyMedium)),
        ],
        onChanged: (v) => setState(() => _selectedSection = v ?? 'getting-started'),
      ),
    );
  }

  Widget _buildContent(TextTheme textTheme) {
    switch (_selectedSection) {
      case 'getting-started':
        return _IntroductionContent();
      case 'quick-start':
        return _QuickStartContent();
      case 'installation':
        return _InstallationContent();
      case 'verification-flow':
        return _VerificationFlowContent();
      case 'blockchain-anchoring':
        return _BlockchainAnchoringContent();
      case 'certificates':
        return _CertificatesContent();
      case 'api-overview':
        return _ApiOverviewContent();
      case 'authentication':
        return _AuthenticationContent();
      case 'endpoints':
        return _EndpointsContent();
      case 'faq':
        return _FaqContent();
      case 'troubleshooting':
        return _TroubleshootingContent();
      case 'changelog':
        return _ChangelogContent();
      default:
        return _IntroductionContent();
    }
  }
}

class _SidebarSection extends StatelessWidget {
  final String title;
  final List<_SidebarItem> items;
  final String selectedId;
  final Function(String) onSelect;

  const _SidebarSection({
    required this.title,
    required this.items,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(title, style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted, letterSpacing: 1)),
        ),
        ...items.map((item) => _buildItem(context, item)),
      ],
    );
  }

  Widget _buildItem(BuildContext context, _SidebarItem item) {
    final isSelected = item.id == selectedId;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => onSelect(item.id),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonGreen.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: isSelected ? Border.all(color: AppColors.neonGreen.withValues(alpha: 0.3)) : null,
        ),
        child: Row(
          children: [
            Icon(item.icon, size: 18, color: isSelected ? AppColors.neonGreen : AppColors.textMuted),
            const SizedBox(width: 10),
            Text(item.label, style: textTheme.bodySmall?.copyWith(color: isSelected ? AppColors.neonGreen : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem {
  final String id;
  final String label;
  final IconData icon;
  const _SidebarItem({required this.id, required this.label, required this.icon});
}

// Content sections
class _IntroductionContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Introduction to TenantVerify', style: textTheme.headlineMedium?.semiBold),
        const SizedBox(height: 16),
        Text(
          'TenantVerify is a blockchain-powered tenant verification platform that transforms document verification into immutable, cryptographic proofs.',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.6),
        ),
        const SizedBox(height: 32),
        _DocSection(
          title: 'What is TenantVerify?',
          content: 'TenantVerify solves the trust problem in rental markets by providing:\n\n• Cryptographic document verification using SHA-256 hashing\n• Merkle tree proofs for efficient batch verification\n• Permanent blockchain anchoring on Polygon network\n• Portable trust certificates with QR verification',
        ),
        const SizedBox(height: 24),
        _DocSection(
          title: 'Key Benefits',
          content: '1. **For Landlords**: Verify tenant identity in under 90 seconds with cryptographic certainty\n\n2. **For Tenants**: Get verified once, use the certificate with any landlord\n\n3. **For the Ecosystem**: Build a trust layer that eliminates rental fraud',
        ),
        const SizedBox(height: 24),
        _CodeBlock(
          title: 'How Verification Works',
          code: '''// 1. Document is hashed
hash = SHA256(document_bytes)

// 2. Hashes combined into Merkle tree
merkle_root = buildMerkleTree([hash1, hash2, hash3])

// 3. Root anchored on blockchain
tx = TenantVerify.anchor(merkle_root)

// 4. Certificate generated with QR code
certificate = generateCertificate(merkle_root, tx.hash)''',
        ),
      ],
    );
  }
}

class _QuickStartContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Start Guide', style: textTheme.headlineMedium?.semiBold),
        const SizedBox(height: 16),
        Text(
          'Get started with TenantVerify in 5 minutes. Follow these steps to perform your first verification.',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.6),
        ),
        const SizedBox(height: 32),
        _StepCard(number: 1, title: 'Create Account', description: 'Connect your wallet or sign up with email to create a landlord account.'),
        _StepCard(number: 2, title: 'Add Tenant', description: 'Enter tenant details: name, email, phone, and date of birth.'),
        _StepCard(number: 3, title: 'Upload Documents', description: 'Upload Aadhaar and PAN cards. Documents are processed locally.'),
        _StepCard(number: 4, title: 'Review & Submit', description: 'Confirm consent checkboxes and submit for verification.'),
        _StepCard(number: 5, title: 'Get Certificate', description: 'Download the PDF certificate with embedded QR code.'),
      ],
    );
  }
}

class _InstallationContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Installation', style: textTheme.headlineMedium?.semiBold),
        const SizedBox(height: 16),
        Text(
          'TenantVerify is a web-based platform. No installation required for basic usage.',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.6),
        ),
        const SizedBox(height: 32),
        _DocSection(
          title: 'Browser Requirements',
          content: '• Chrome 90+ (recommended)\n• Firefox 88+\n• Safari 14+\n• Edge 90+\n\nEnsure JavaScript is enabled and you have a stable internet connection.',
        ),
        const SizedBox(height: 24),
        _DocSection(
          title: 'Wallet Setup (Optional)',
          content: 'For blockchain interactions, you\'ll need a Web3 wallet:\n\n1. Install MetaMask browser extension\n2. Create or import a wallet\n3. Connect to Polygon network\n4. Keep some MATIC for gas fees (optional)',
        ),
      ],
    );
  }
}

class _VerificationFlowContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verification Flow', style: textTheme.headlineMedium?.semiBold),
        const SizedBox(height: 16),
        Text(
          'Understanding the complete verification pipeline from document input to blockchain proof.',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.6),
        ),
        const SizedBox(height: 32),
        _CodeBlock(
          title: 'Verification Pipeline',
          code: '''Input: [Aadhaar PDF, PAN PDF, Employment PDF]
           ↓
Step 1: Read file bytes
           ↓
Step 2: SHA256 hash each document
  aadhaar_hash = "e7d3a9..."
  pan_hash = "4b2c1f..."
  emp_hash = "8f9d2e..."
           ↓
Step 3: Build Merkle tree
  merkle_root = hash(hash(aadhaar + pan) + emp)
           ↓
Step 4: Call smart contract
  TenantVerify.anchor(merkle_root)
           ↓
Step 5: Generate certificate
  PDF with QR → verification URL''',
        ),
      ],
    );
  }
}

class _BlockchainAnchoringContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Blockchain Anchoring', style: textTheme.headlineMedium?.semiBold),
        const SizedBox(height: 16),
        Text(
          'How proofs are permanently recorded on the Polygon blockchain.',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.6),
        ),
        const SizedBox(height: 32),
        _DocSection(
          title: 'Why Polygon?',
          content: '• Low transaction costs (~\$0.01 per verification)\n• Fast block times (2 seconds)\n• Ethereum-compatible security\n• Environmentally friendly (PoS)',
        ),
        const SizedBox(height: 24),
        _CodeBlock(
          title: 'Smart Contract (Simplified)',
          code: '''// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TenantVerify {
  event ProofAnchored(
    bytes32 indexed merkleRoot,
    address indexed landlord,
    uint256 timestamp
  );
  
  function anchor(bytes32 merkleRoot) external {
    emit ProofAnchored(
      merkleRoot,
      msg.sender,
      block.timestamp
    );
  }
}''',
        ),
      ],
    );
  }
}

class _CertificatesContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Trust Certificates', style: textTheme.headlineMedium?.semiBold),
        const SizedBox(height: 16),
        Text(
          'Portable proof of verification that tenants can share with any landlord.',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.6),
        ),
        const SizedBox(height: 32),
        _DocSection(
          title: 'Certificate Contents',
          content: '• Tenant name and verification date\n• Trust score (0-100)\n• QR code linking to blockchain proof\n• Blockchain transaction hash\n• Document verification status\n• Validity period (1 year)',
        ),
        const SizedBox(height: 24),
        _DocSection(
          title: 'QR Verification',
          content: 'Any landlord can verify a tenant\'s certificate by:\n\n1. Scanning the QR code on the certificate\n2. Being redirected to the verification page\n3. Seeing real-time blockchain verification\n4. Confirming the proof is valid and unrevoked',
        ),
      ],
    );
  }
}

class _ApiOverviewContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('API Overview', style: textTheme.headlineMedium?.semiBold),
        const SizedBox(height: 16),
        Text(
          'Integrate TenantVerify into your property management system with our REST API.',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.6),
        ),
        const SizedBox(height: 32),
        _DocSection(
          title: 'Base URL',
          content: 'All API requests should be made to:\n\nhttps://api.tenantverify.io/v1',
        ),
        const SizedBox(height: 24),
        _DocSection(
          title: 'Available Endpoints',
          content: '• POST /tenants - Create new tenant\n• POST /documents - Upload documents\n• POST /verify - Start verification\n• GET /certificates/:id - Get certificate\n• GET /verify/:id - Check verification status',
        ),
      ],
    );
  }
}

class _AuthenticationContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Authentication', style: textTheme.headlineMedium?.semiBold),
        const SizedBox(height: 16),
        Text(
          'All API requests require authentication via API key or JWT token.',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.6),
        ),
        const SizedBox(height: 32),
        _CodeBlock(
          title: 'API Key Authentication',
          code: '''curl -X GET https://api.tenantverify.io/v1/tenants \\
  -H "Authorization: Bearer YOUR_API_KEY" \\
  -H "Content-Type: application/json"''',
        ),
      ],
    );
  }
}

class _EndpointsContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('API Endpoints', style: textTheme.headlineMedium?.semiBold),
        const SizedBox(height: 16),
        Text(
          'Complete reference for all available API endpoints.',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.6),
        ),
        const SizedBox(height: 32),
        _EndpointCard(method: 'POST', path: '/tenants', description: 'Create a new tenant record'),
        _EndpointCard(method: 'POST', path: '/verify', description: 'Start verification workflow'),
        _EndpointCard(method: 'GET', path: '/certificates/:id', description: 'Retrieve certificate details'),
        _EndpointCard(method: 'POST', path: '/certificates/:id/revoke', description: 'Revoke a certificate'),
      ],
    );
  }
}

class _FaqContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Frequently Asked Questions', style: textTheme.headlineMedium?.semiBold),
        const SizedBox(height: 32),
        _DocSection(
          title: 'Is my data stored on the blockchain?',
          content: 'No. Only cryptographic hashes are stored on the blockchain. Your documents and personal data never leave your device.',
        ),
        const SizedBox(height: 16),
        _DocSection(
          title: 'How long is a certificate valid?',
          content: 'Certificates are valid for 1 year from the verification date. Tenants can renew by re-verifying their documents.',
        ),
        const SizedBox(height: 16),
        _DocSection(
          title: 'What if a document is modified?',
          content: 'Any modification changes the hash. Verification will fail because the new hash won\'t match the blockchain record.',
        ),
      ],
    );
  }
}

class _TroubleshootingContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Troubleshooting', style: textTheme.headlineMedium?.semiBold),
        const SizedBox(height: 32),
        _DocSection(
          title: 'Verification Failed',
          content: '• Ensure documents are clear and readable\n• Check file format (PDF, JPG, PNG only)\n• File size must be under 10MB\n• Try uploading again',
        ),
        const SizedBox(height: 16),
        _DocSection(
          title: 'Wallet Connection Issues',
          content: '• Ensure MetaMask is installed\n• Check you\'re on Polygon network\n• Clear browser cache\n• Try refreshing the page',
        ),
      ],
    );
  }
}

class _ChangelogContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Changelog', style: textTheme.headlineMedium?.semiBold),
        const SizedBox(height: 32),
        _ChangelogEntry(version: 'v1.0.0', date: 'January 2025', changes: ['Initial release', 'Aadhaar & PAN verification', 'Polygon blockchain anchoring', 'PDF certificate generation']),
        _ChangelogEntry(version: 'v0.9.0', date: 'December 2024', changes: ['Beta release', 'Core verification pipeline', 'QR code verification']),
      ],
    );
  }
}

// Reusable components
class _DocSection extends StatelessWidget {
  final String title;
  final String content;
  const _DocSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.titleMedium?.semiBold),
        const SizedBox(height: 8),
        Text(content, style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.6)),
      ],
    );
  }
}

class _CodeBlock extends StatelessWidget {
  final String title;
  final String code;
  const _CodeBlock({required this.title, required this.code});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.titleSmall?.semiBold),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: SelectableText(
            code,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppColors.neonGreen, height: 1.5),
          ),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final int number;
  final String title;
  final String description;
  const _StepCard({required this.number, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.neonGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Center(child: Text('$number', style: textTheme.titleMedium?.copyWith(color: AppColors.neonGreen, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleSmall?.semiBold),
                const SizedBox(height: 4),
                Text(description, style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EndpointCard extends StatelessWidget {
  final String method;
  final String path;
  final String description;
  const _EndpointCard({required this.method, required this.path, required this.description});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final methodColor = method == 'POST' ? AppColors.neonGreen : method == 'GET' ? AppColors.electricBlue : AppColors.warning;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: methodColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(method, style: textTheme.labelSmall?.copyWith(color: methodColor, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Text(path, style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: AppColors.textPrimary)),
          const Spacer(),
          Flexible(child: Text(description, style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted), textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _ChangelogEntry extends StatelessWidget {
  final String version;
  final String date;
  final List<String> changes;
  const _ChangelogEntry({required this.version, required this.date, required this.changes});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(version, style: textTheme.labelMedium?.copyWith(color: AppColors.neonGreen, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Text(date, style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 16),
          ...changes.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.add_circle_outline_rounded, size: 16, color: AppColors.neonGreen),
                const SizedBox(width: 8),
                Text(c, style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
