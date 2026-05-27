import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/imgbb_service.dart';
import '../utils/app_theme.dart';

class PhotoPicker extends StatefulWidget {
  final String? initialImageUrl;
  final Function(String?) onImageUploaded;
  final double size;
  final String placeholderText;

  const PhotoPicker({
    super.key,
    this.initialImageUrl,
    required this.onImageUploaded,
    this.size = 120,
    this.placeholderText = 'Add Photo',
  });

  @override
  State<PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  final _imgbbService = ImgBBService();
  final _picker = ImagePicker();
  String? _imageUrl;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialImageUrl;
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _uploading = true);

      String? uploadedUrl;

      if (kIsWeb) {
        // Web: Use bytes
        final bytes = await pickedFile.readAsBytes();
        uploadedUrl = await _imgbbService.uploadImageFromBytes(
          bytes,
          pickedFile.name,
        );
      } else {
        // Mobile: Use file
        final file = File(pickedFile.path);
        uploadedUrl = await _imgbbService.uploadImage(file);
      }

      if (!mounted) return;

      setState(() {
        _uploading = false;
        if (uploadedUrl != null) {
          _imageUrl = uploadedUrl;
          widget.onImageUploaded(uploadedUrl);
        }
      });

      if (uploadedUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload image. Please try again.'),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.accentColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    // On web, camera might not be available, so just use gallery
    if (kIsWeb) {
      _pickAndUploadImage(ImageSource.gallery);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choose Photo Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt,
                      color: AppTheme.primaryColor),
                ),
                title: const Text('Camera',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark)),
                subtitle: const Text('Take a new photo',
                    style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library,
                      color: AppTheme.accentColor),
                ),
                title: const Text('Gallery',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark)),
                subtitle: const Text('Choose from gallery',
                    style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
              if (_imageUrl != null)
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline,
                        color: AppTheme.accentColor),
                  ),
                  title: const Text('Remove Photo',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accentColor)),
                  subtitle: const Text('Delete current photo',
                      style:
                          TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _imageUrl = null);
                    widget.onImageUploaded(null);
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _uploading ? null : _showImageSourceDialog,
      child: Stack(
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(26, 31, 60, 0.08),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
              image: _imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(_imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _uploading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                      strokeWidth: 3,
                    ),
                  )
                : _imageUrl == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            color: AppTheme.textGrey,
                            size: widget.size * 0.3,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.placeholderText,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : null,
          ),
          if (!_uploading && _imageUrl == null)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: widget.size * 0.28,
                height: widget.size * 0.28,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: widget.size * 0.15,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
