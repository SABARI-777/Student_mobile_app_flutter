
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import '../services/image_picker_service.dart';

class ProfileImagePicker extends StatelessWidget {
  final Function(File) onImageSelected;
  final File? selectedImage;

  const ProfileImagePicker({
    super.key,
    required this.onImageSelected,
    this.selectedImage,
  });

  Future<void> _showImageOptions(BuildContext context) async {
    final imageService = ImagePickerService();

    final source = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, 'gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.pop(context, 'camera'),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    File? image;

    if (source == 'gallery') {
      image = await imageService.pickFromGallery();
    } else {
      image = await imageService.pickFromCamera();
    }

    if (image != null) {
      onImageSelected(image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageOptions(context),
      child: CircleAvatar(
        radius: 45,
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            : null,
        child: selectedImage == null
            ? const Icon(Icons.camera_alt, size: 30)
            : null,
      ),
    );
  }
}
