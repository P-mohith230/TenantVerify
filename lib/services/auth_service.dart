import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:project/models/user.dart';

class AuthService {
  static const _userKey = 'current_user';
  static final _uuid = Uuid();
  
  // Cache to avoid repeated SharedPreferences issues on web
  User? _cachedUser;
  bool _cacheLoaded = false;

  /// Mock wallet addresses for demo
  static const _mockWallets = [
    '0x742d35Cc6634C0532925a3b844Bc9e7595f2bD9e',
    '0x8ba1f109551bD432803012645Ac136ddd64DBA72',
    '0x2546BcD3c84621e976D8185a91A922aE77ECEc30',
  ];

  Future<User?> getCurrentUser() async {
    // Return cached user if available
    if (_cacheLoaded && _cachedUser != null) {
      return _cachedUser;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        _cachedUser = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
        _cacheLoaded = true;
        return _cachedUser;
      }
    } catch (e) {
      debugPrint('Failed to get current user: $e');
      // On web, SharedPreferences might fail initially - return cached user if available
      if (_cachedUser != null) {
        return _cachedUser;
      }
    }
    _cacheLoaded = true;
    return null;
  }

  Future<User> connectWallet() async {
    // Simulate wallet connection delay
    await Future.delayed(const Duration(seconds: 1));
    
    final walletAddress = _mockWallets[DateTime.now().millisecond % _mockWallets.length];
    final now = DateTime.now();
    
    final user = User(
      id: _uuid.v4(),
      walletAddress: walletAddress,
      displayName: 'Landlord',
      role: UserRole.landlord,
      isWalletConnected: true,
      createdAt: now,
      updatedAt: now,
    );
    
    await _saveUser(user);
    return user;
  }

  Future<User> signInWithEmail(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));
    
    final now = DateTime.now();
    final user = User(
      id: _uuid.v4(),
      email: email,
      displayName: email.split('@').first,
      role: UserRole.landlord,
      isWalletConnected: false,
      createdAt: now,
      updatedAt: now,
    );
    
    await _saveUser(user);
    return user;
  }

  Future<User> signUpWithEmail(String email, String password, String name) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));
    
    final now = DateTime.now();
    final user = User(
      id: _uuid.v4(),
      email: email,
      displayName: name,
      role: UserRole.landlord,
      isWalletConnected: false,
      createdAt: now,
      updatedAt: now,
    );
    
    await _saveUser(user);
    return user;
  }

  Future<User> signConsent(User user) async {
    // Simulate consent signing
    await Future.delayed(const Duration(milliseconds: 500));
    
    final updatedUser = user.copyWith(
      consentSignedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await _saveUser(updatedUser);
    return updatedUser;
  }

  Future<void> signOut() async {
    // Clear cache first
    _cachedUser = null;
    _cacheLoaded = false;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (e) {
      debugPrint('Failed to clear storage on sign out: $e');
      // User is already cleared from cache
    }
  }

  Future<void> _saveUser(User user) async {
    // Always update cache first
    _cachedUser = user;
    _cacheLoaded = true;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('Failed to save user to storage: $e');
      // User is still cached in memory, so the app will work
    }
  }

  String generateConsentMessage() {
    final timestamp = DateTime.now().toIso8601String();
    return '''TenantVerify Consent

I authorize verification of my documents and storage of cryptographic proof on the Polygon blockchain.

Timestamp: $timestamp
Purpose: Tenant Verification

This consent allows TenantVerify to:
• Verify identity documents with government APIs
• Generate cryptographic proofs of verification
• Store verification proofs on the Polygon blockchain
• Issue tamper-proof certificates

No raw personal data will be stored on the blockchain.
Only cryptographic hashes and Merkle roots are recorded.''';
  }
}
