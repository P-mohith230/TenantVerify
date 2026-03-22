import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:project/models/certificate.dart';

class CertificatePdfService {
  static Future<Uint8List> generateCertificatePdf(Certificate certificate) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy');
    final isValid = certificate.isValid && !certificate.isRevoked;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(30),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: isValid ? PdfColors.green : PdfColors.grey,
                width: 3,
              ),
              borderRadius: pw.BorderRadius.circular(16),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: pw.BoxDecoration(
                    color: isValid ? PdfColors.green50 : PdfColors.grey300,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Container(
                        width: 40,
                        height: 40,
                        decoration: pw.BoxDecoration(
                          color: isValid ? PdfColors.green : PdfColors.grey,
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          'TV',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'TenantVerify',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'Blockchain Trust Certificate',
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 40),

                // Status badge
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: pw.BoxDecoration(
                    color: certificate.isRevoked
                        ? PdfColors.red50
                        : isValid
                            ? PdfColors.green50
                            : PdfColors.orange50,
                    borderRadius: pw.BorderRadius.circular(20),
                    border: pw.Border.all(
                      color: certificate.isRevoked
                          ? PdfColors.red
                          : isValid
                              ? PdfColors.green
                              : PdfColors.orange,
                    ),
                  ),
                  child: pw.Text(
                    certificate.isRevoked
                        ? 'REVOKED'
                        : isValid
                            ? 'VERIFIED'
                            : 'EXPIRED',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                      color: certificate.isRevoked
                          ? PdfColors.red
                          : isValid
                              ? PdfColors.green
                              : PdfColors.orange,
                    ),
                  ),
                ),
                pw.SizedBox(height: 30),

                // Certificate title
                pw.Text(
                  'CERTIFICATE OF VERIFICATION',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'This is to certify that',
                  style: const pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 20),

                // Tenant name
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(
                        color: isValid ? PdfColors.green : PdfColors.grey,
                        width: 2,
                      ),
                    ),
                  ),
                  child: pw.Text(
                    certificate.tenantName,
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                // Verification statement
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'has been verified through TenantVerify\'s blockchain-powered identity verification system. '
                    'The verification proof has been immutably recorded on the Polygon blockchain.',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey800,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 30),

                // Certificate details
                pw.Container(
                  width: double.infinity,
                  child: pw.Column(
                    children: [
                      _buildDetailRow('Certificate Number', certificate.certificateNumber),
                      _buildDetailRow('Issue Date', dateFormat.format(certificate.issueDate)),
                      _buildDetailRow('Expiry Date', dateFormat.format(certificate.expiryDate)),
                      _buildDetailRow('Issuer', _shortenAddress(certificate.landlordAddress)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // Blockchain proof section
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green50,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.green200),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 24,
                            height: 24,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.green,
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                            alignment: pw.Alignment.center,
                            child: pw.Text(
                              '⛓',
                              style: const pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Text(
                            'BLOCKCHAIN PROOF',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                              color: PdfColors.green800,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 12),
                      _buildProofRow('Merkle Root', certificate.merkleRoot),
                      pw.SizedBox(height: 6),
                      _buildProofRow('Transaction Hash', certificate.transactionHash),
                      pw.SizedBox(height: 6),
                      _buildProofRow('Network', 'Polygon Mumbai (Testnet)'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // QR verification note
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Icon(
                        const pw.IconData(0xe8f4),
                        size: 20,
                        color: PdfColors.grey600,
                      ),
                      pw.SizedBox(width: 8),
                      pw.Text(
                        'Verify this certificate at: ${certificate.qrCodeData}',
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Spacer(),

                // Footer
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Generated by TenantVerify',
                      style: const pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey500,
                      ),
                    ),
                    pw.Text(
                      'Dreamflow Buildathon 2025',
                      style: const pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildProofRow(String label, String value) {
    final displayValue =
        value.length > 40 ? '${value.substring(0, 20)}...${value.substring(value.length - 16)}' : value;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey600,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            displayValue,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  static String _shortenAddress(String address) {
    if (address.length < 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  static Future<void> printCertificate(Certificate certificate) async {
    final pdfBytes = await generateCertificatePdf(certificate);
    await Printing.layoutPdf(
      onLayout: (_) => pdfBytes,
      name: 'TenantVerify_Certificate_${certificate.certificateNumber}',
    );
  }

  static Future<void> shareCertificate(Certificate certificate) async {
    final pdfBytes = await generateCertificatePdf(certificate);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'TenantVerify_Certificate_${certificate.certificateNumber}.pdf',
    );
  }
}
