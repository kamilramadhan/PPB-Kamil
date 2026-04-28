import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Hasil dari bottom sheet: bisa ImageSource atau 'delete'
class ImagePickResult {
  final ImageSource? source;
  final bool isDelete;
  ImagePickResult({this.source, this.isDelete = false});
}

Future<ImagePickResult?> showImageSourceSheet(
  BuildContext context, {
  bool showDelete = false,
}) {
  return showModalBottomSheet<ImagePickResult>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pilih Sumber Foto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ambil foto baru atau pilih dari perangkat',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
                const SizedBox(height: 20),
                // Camera option
                _SourceTile(
                  icon: Icons.camera_alt_rounded,
                  iconColor: Colors.white,
                  iconBg: const Color(0xFF1565C0),
                  title: 'Ambil dari Kamera',
                  subtitle: 'Buka kamera untuk foto baru',
                  onTap: () => Navigator.pop(
                    context,
                    ImagePickResult(source: ImageSource.camera),
                  ),
                ),
                const SizedBox(height: 10),
                // Gallery option
                _SourceTile(
                  icon: Icons.photo_library_rounded,
                  iconColor: Colors.white,
                  iconBg: const Color(0xFF43A047),
                  title: 'Pilih dari Galeri / File',
                  subtitle: 'Pilih gambar yang sudah ada',
                  onTap: () => Navigator.pop(
                    context,
                    ImagePickResult(source: ImageSource.gallery),
                  ),
                ),
                if (showDelete) ...[
                  const SizedBox(height: 10),
                  _SourceTile(
                    icon: Icons.delete_outline_rounded,
                    iconColor: Colors.white,
                    iconBg: Colors.red[400]!,
                    title: 'Hapus Foto',
                    subtitle: 'Hapus foto saat ini',
                    onTap: () => Navigator.pop(
                      context,
                      ImagePickResult(isDelete: true),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SourceTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F7FA),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
