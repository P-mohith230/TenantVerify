import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:project/theme.dart';
import 'package:project/components/responsive_layout.dart';
import 'package:project/components/animations.dart';
import 'package:project/providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  bool _isLogin = true;
  bool _showConsentDialog = false;
  String? _pendingAuthMethod;
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _rotateController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated background
          _AnimatedBackground(controller: _rotateController),
          
          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ContentContainer(
                  maxWidth: 440,
                  padding: EdgeInsets.zero,
                  child: _showConsentDialog 
                      ? _ConsentDialog(
                          onAccept: _handleConsentAccepted,
                          onDecline: _handleConsentDeclined,
                        )
                      : _AuthForm(
                          isLogin: _isLogin,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          nameController: _nameController,
                          formKey: _formKey,
                          pulseController: _pulseController,
                          onToggleMode: () => setState(() => _isLogin = !_isLogin),
                          onWalletConnect: () => _initiateAuth('wallet'),
                          onEmailAuth: () => _initiateAuth('email'),
                        ),
                ),
              ),
            ),
          ),
          
          // Back button
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textSecondary),
                onPressed: () => context.go('/'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _initiateAuth(String method) {
    if (method == 'email' && !_formKey.currentState!.validate()) return;
    
    setState(() {
      _pendingAuthMethod = method;
      _showConsentDialog = true;
    });
  }

  Future<void> _handleConsentAccepted() async {
    final auth = context.read<AuthProvider>();
    bool success = false;

    if (_pendingAuthMethod == 'wallet') {
      success = await auth.connectWallet();
    } else if (_pendingAuthMethod == 'email') {
      if (_isLogin) {
        success = await auth.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        success = await auth.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );
      }
    }

    if (success && mounted) {
      context.go('/dashboard');
    } else if (mounted) {
      setState(() {
        _showConsentDialog = false;
        _pendingAuthMethod = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Authentication failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleConsentDeclined() {
    setState(() {
      _showConsentDialog = false;
      _pendingAuthMethod = null;
    });
  }
}

class _AnimatedBackground extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _BackgroundPainter(rotation: controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double rotation;

  _BackgroundPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    // Grid
    final gridPaint = Paint()
      ..color = AppColors.cardBorder.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    const spacing = 50.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Glowing orbs
    final orbPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.neonGreen.withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width * 0.2 + math.cos(rotation * math.pi * 2) * 30,
            size.height * 0.3 + math.sin(rotation * math.pi * 2) * 30,
          ),
          radius: 150,
        ),
      );

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      150,
      orbPaint,
    );

    final orbPaint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.electricBlue.withValues(alpha: 0.1),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.8, size.height * 0.7),
          radius: 200,
        ),
      );

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.7),
      200,
      orbPaint2,
    );
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) => oldDelegate.rotation != rotation;
}

class _AuthForm extends StatelessWidget {
  final bool isLogin;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final GlobalKey<FormState> formKey;
  final AnimationController pulseController;
  final VoidCallback onToggleMode;
  final VoidCallback onWalletConnect;
  final VoidCallback onEmailAuth;

  const _AuthForm({
    required this.isLogin,
    required this.emailController,
    required this.passwordController,
    required this.nameController,
    required this.formKey,
    required this.pulseController,
    required this.onToggleMode,
    required this.onWalletConnect,
    required this.onEmailAuth,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final auth = context.watch<AuthProvider>();

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonGreen.withValues(alpha: 0.1),
            blurRadius: 40,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          AnimatedBuilder(
            animation: pulseController,
            builder: (context, child) {
              return Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppColors.neonGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonGreen.withValues(alpha: 0.3 + 0.2 * pulseController.value),
                      blurRadius: 25,
                      spreadRadius: 3 * pulseController.value,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'TV',
                    style: TextStyle(
                      color: AppColors.background,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          
          Text(
            isLogin ? 'Welcome Back' : 'Create Account',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            isLogin 
                ? 'Sign in to access your verification dashboard'
                : 'Start verifying tenants with blockchain trust',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Wallet connect button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonGreen.withValues(alpha: 0.3),
                  blurRadius: 15,
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: auth.isLoading ? null : onWalletConnect,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonGreen,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: auth.isLoading && auth.error == null
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                    )
                  : const Icon(Icons.account_balance_wallet_rounded),
              label: const Text(
                'Connect Wallet',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Divider
          Row(
            children: [
              Expanded(child: Container(height: 1, color: AppColors.cardBorder)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'or continue with email',
                  style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
                ),
              ),
              Expanded(child: Container(height: 1, color: AppColors.cardBorder)),
            ],
          ),
          const SizedBox(height: 24),
          
          // Email form
          Form(
            key: formKey,
            child: Column(
              children: [
                if (!isLogin) ...[
                  TextFormField(
                    controller: nameController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.textMuted),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted),
                  ),
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Email is required';
                    if (!v!.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.textMuted),
                  ),
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Password is required';
                    if (v!.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Submit button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: auth.isLoading ? null : onEmailAuth,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.cardBorder),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                isLogin ? 'Sign In' : 'Create Account',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Toggle mode
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLogin ? "Don't have an account? " : 'Already have an account? ',
                style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
              TextButton(
                onPressed: onToggleMode,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  isLogin ? 'Sign Up' : 'Sign In',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.neonGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConsentDialog extends StatefulWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _ConsentDialog({
    required this.onAccept,
    required this.onDecline,
  });

  @override
  State<_ConsentDialog> createState() => _ConsentDialogState();
}

class _ConsentDialogState extends State<_ConsentDialog> {
  bool _dataProcessing = false;
  bool _blockchainStorage = false;
  bool _termsAccepted = false;

  bool get _canProceed => _dataProcessing && _blockchainStorage && _termsAccepted;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.cyberPurple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: AppColors.cyberPurple,
              size: 32,
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Consent Required',
            style: textTheme.titleLarge?.semiBold,
          ),
          const SizedBox(height: 8),
          Text(
            'Before proceeding, please review and accept the following:',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          _ConsentCheckbox(
            value: _dataProcessing,
            onChanged: (v) => setState(() => _dataProcessing = v ?? false),
            title: 'Data Processing',
            description: 'I consent to the processing of verification data using cryptographic methods.',
          ),
          const SizedBox(height: 12),
          _ConsentCheckbox(
            value: _blockchainStorage,
            onChanged: (v) => setState(() => _blockchainStorage = v ?? false),
            title: 'Blockchain Storage',
            description: 'I understand that verification proofs will be stored on a public blockchain.',
          ),
          const SizedBox(height: 12),
          _ConsentCheckbox(
            value: _termsAccepted,
            onChanged: (v) => setState(() => _termsAccepted = v ?? false),
            title: 'Terms & Privacy',
            description: 'I have read and accept the Terms of Service and Privacy Policy.',
          ),
          const SizedBox(height: 32),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.cardBorder),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: _canProceed ? BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonGreen.withValues(alpha: 0.3),
                        blurRadius: 15,
                      ),
                    ],
                  ) : null,
                  child: ElevatedButton(
                    onPressed: _canProceed ? widget.onAccept : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonGreen,
                      foregroundColor: AppColors.background,
                      disabledBackgroundColor: AppColors.surfaceLight,
                      disabledForegroundColor: AppColors.textMuted,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Accept & Continue'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
          color: value ? AppColors.neonGreen.withValues(alpha: 0.05) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: value ? AppColors.neonGreen.withValues(alpha: 0.3) : Colors.transparent,
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
                side: BorderSide(color: value ? AppColors.neonGreen : AppColors.textMuted),
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
