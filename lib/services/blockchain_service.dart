import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class BlockchainService {
  static final _uuid = Uuid();

  /// Compute SHA-256 hash of file bytes
  String computeFileHash(Uint8List fileBytes) {
    final digest = sha256.convert(fileBytes);
    return digest.toString();
  }

  /// Compute SHA-256 hash of string
  String computeStringHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Compute Merkle root from list of hashes
  String computeMerkleRoot(List<String> hashes) {
    if (hashes.isEmpty) return '';
    if (hashes.length == 1) return hashes.first;

    List<String> currentLevel = List.from(hashes);

    while (currentLevel.length > 1) {
      List<String> nextLevel = [];
      
      for (int i = 0; i < currentLevel.length; i += 2) {
        if (i + 1 < currentLevel.length) {
          final combined = currentLevel[i] + currentLevel[i + 1];
          nextLevel.add(computeStringHash(combined));
        } else {
          // Odd number of elements, promote the last one
          nextLevel.add(currentLevel[i]);
        }
      }
      
      currentLevel = nextLevel;
    }

    return currentLevel.first;
  }

  /// Mock blockchain transaction
  Future<BlockchainTransaction> createTransaction({
    required String merkleRoot,
    required String issuerAddress,
    required DateTime issueDate,
    required DateTime expiryDate,
  }) async {
    // Simulate blockchain transaction delay
    await Future.delayed(const Duration(seconds: 2));

    final transactionHash = '0x${_generateMockHash()}';
    final blockNumber = 45000000 + DateTime.now().millisecondsSinceEpoch % 1000000;

    debugPrint('Blockchain transaction created:');
    debugPrint('  Transaction Hash: $transactionHash');
    debugPrint('  Block Number: $blockNumber');
    debugPrint('  Merkle Root: $merkleRoot');

    return BlockchainTransaction(
      transactionHash: transactionHash,
      blockNumber: blockNumber,
      merkleRoot: merkleRoot,
      issuerAddress: issuerAddress,
      issueDate: issueDate,
      expiryDate: expiryDate,
      timestamp: DateTime.now(),
      network: 'Polygon Mumbai (Testnet)',
      status: TransactionStatus.confirmed,
    );
  }

  /// Mock certificate revocation
  Future<BlockchainTransaction> revokeCertificate({
    required String originalTransactionHash,
    required String issuerAddress,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return BlockchainTransaction(
      transactionHash: '0x${_generateMockHash()}',
      blockNumber: 45000000 + DateTime.now().millisecondsSinceEpoch % 1000000,
      merkleRoot: '',
      issuerAddress: issuerAddress,
      issueDate: DateTime.now(),
      expiryDate: DateTime.now(),
      timestamp: DateTime.now(),
      network: 'Polygon Mumbai (Testnet)',
      status: TransactionStatus.confirmed,
      isRevocation: true,
      originalTransactionHash: originalTransactionHash,
    );
  }

  /// Verify a certificate on blockchain (mock)
  Future<VerificationResult> verifyCertificate(String transactionHash) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return VerificationResult(
      isValid: true,
      transactionHash: transactionHash,
      blockNumber: 45000000 + DateTime.now().millisecondsSinceEpoch % 1000000,
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      network: 'Polygon Mumbai (Testnet)',
    );
  }

  String _generateMockHash() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = _uuid.v4().replaceAll('-', '');
    return computeStringHash(timestamp + random).substring(0, 64);
  }
}

enum TransactionStatus { pending, confirmed, failed }

class BlockchainTransaction {
  final String transactionHash;
  final int blockNumber;
  final String merkleRoot;
  final String issuerAddress;
  final DateTime issueDate;
  final DateTime expiryDate;
  final DateTime timestamp;
  final String network;
  final TransactionStatus status;
  final bool isRevocation;
  final String? originalTransactionHash;

  BlockchainTransaction({
    required this.transactionHash,
    required this.blockNumber,
    required this.merkleRoot,
    required this.issuerAddress,
    required this.issueDate,
    required this.expiryDate,
    required this.timestamp,
    required this.network,
    required this.status,
    this.isRevocation = false,
    this.originalTransactionHash,
  });
}

class VerificationResult {
  final bool isValid;
  final String transactionHash;
  final int blockNumber;
  final DateTime timestamp;
  final String network;
  final String? error;

  VerificationResult({
    required this.isValid,
    required this.transactionHash,
    required this.blockNumber,
    required this.timestamp,
    required this.network,
    this.error,
  });
}
