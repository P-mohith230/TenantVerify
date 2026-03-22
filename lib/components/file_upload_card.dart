import 'package:flutter/material.dart';
import 'package:project/theme.dart';
import 'package:project/models/tenant.dart';

class FileUploadCard extends StatelessWidget {
  final DocumentType documentType;
  final String? fileName;
  final int? fileSize;
  final bool isUploaded;
  final bool isLoading;
  final VoidCallback onUpload;
  final VoidCallback? onRemove;

  const FileUploadCard({
    super.key,
    required this.documentType,
    this.fileName,
    this.fileSize,
    required this.isUploaded,
    required this.isLoading,
    required this.onUpload,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isUploaded || isLoading ? null : onUpload,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isUploaded
                ? AppColors.neonGreen.withValues(alpha: 0.05)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isUploaded
                  ? AppColors.neonGreen.withValues(alpha: 0.3)
                  : AppColors.cardBorder,
              width: isUploaded ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isUploaded
                      ? AppColors.neonGreen.withValues(alpha: 0.15)
                      : _getTypeColor().withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  isUploaded ? Icons.check_circle_rounded : _getTypeIcon(),
                  color: isUploaded ? AppColors.neonGreen : _getTypeColor(),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTypeName(),
                      style: textTheme.titleSmall?.semiBold,
                    ),
                    const SizedBox(height: 4),
                    if (isUploaded && fileName != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.attach_file_rounded,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              fileName!,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (fileSize != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              _formatFileSize(fileSize!),
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ] else ...[
                      Text(
                        isLoading ? 'Uploading...' : 'Tap to upload',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Actions
              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.electricBlue),
                  ),
                )
              else if (isUploaded && onRemove != null)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: AppColors.error,
                  onPressed: onRemove,
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    Icons.cloud_upload_outlined,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeName() {
    switch (documentType) {
      case DocumentType.aadhaar:
        return 'Aadhaar Card';
      case DocumentType.pan:
        return 'PAN Card';
      case DocumentType.employment:
        return 'Employment Proof';
    }
  }

  IconData _getTypeIcon() {
    switch (documentType) {
      case DocumentType.aadhaar:
        return Icons.credit_card_rounded;
      case DocumentType.pan:
        return Icons.badge_rounded;
      case DocumentType.employment:
        return Icons.work_outline_rounded;
    }
  }

  Color _getTypeColor() {
    switch (documentType) {
      case DocumentType.aadhaar:
        return AppColors.electricBlue;
      case DocumentType.pan:
        return AppColors.cyberPurple;
      case DocumentType.employment:
        return AppColors.warning;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class DropzoneUpload extends StatefulWidget {
  final DocumentType documentType;
  final bool isUploaded;
  final bool isLoading;
  final VoidCallback onUpload;

  const DropzoneUpload({
    super.key,
    required this.documentType,
    required this.isUploaded,
    required this.isLoading,
    required this.onUpload,
  });

  @override
  State<DropzoneUpload> createState() => _DropzoneUploadState();
}

class _DropzoneUploadState extends State<DropzoneUpload> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.isUploaded || widget.isLoading ? null : widget.onUpload,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: _isHovering
                ? AppColors.neonGreen.withValues(alpha: 0.05)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: _isHovering
                  ? AppColors.neonGreen
                  : AppColors.cardBorder,
              width: _isHovering ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(
                  widget.isLoading
                      ? Icons.sync_rounded
                      : Icons.cloud_upload_outlined,
                  size: 32,
                  color: _isHovering ? AppColors.neonGreen : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.isLoading
                    ? 'Uploading...'
                    : 'Drop file here or click to upload',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'PDF, JPG, PNG • Max 10MB',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
