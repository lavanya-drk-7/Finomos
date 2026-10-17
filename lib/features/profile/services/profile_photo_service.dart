import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth_kyc/providers/auth_kyc_provider.dart';
import '../providers/profile_provider.dart';

class ProfilePhotoService {
  ProfilePhotoService._();

  static const List<Map<String, String>> sampleAvatars = [
    {
      'name': 'Sireesha (Default Professional)',
      'url': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200',
    },
    {
      'name': 'Executive Portrait',
      'url': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
    },
    {
      'name': 'Corporate Casual',
      'url': 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=200',
    },
    {
      'name': 'Tech Leader',
      'url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
    },
  ];

  /// Updates profile photo synchronously across all providers in the app.
  static void updatePhoto(dynamic ref, String photoPath) {
    ref.read(profileProvider.notifier).updateProfilePhoto(photoPath);
    ref.read(authKycProvider.notifier).updateProfilePhoto(photoPath);
  }

  /// Removes current profile photo across all providers in the app.
  static void removePhoto(dynamic ref) {
    ref.read(profileProvider.notifier).updateProfilePhoto('');
    ref.read(authKycProvider.notifier).updateProfilePhoto('');
  }

  /// Gets current active profile photo path/url from either provider.
  static String getCurrentPhoto(dynamic ref) {
    final profileUrl = ref.read(profileProvider).personalInfo.profilePicUrl;
    if (profileUrl.isNotEmpty) return profileUrl;
    return ref.read(authKycProvider).user.profilePicUrl;
  }

  /// Displays the interactive profile photo selection sheet.
  static void showPhotoOptionsSheet(BuildContext context, WidgetRef ref) {
    final currentPhoto = getCurrentPhoto(ref);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0066FF).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF0066FF), size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Update Profile Photo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A2540),
                            ),
                          ),
                          Text(
                            'Choose a photo to update your profile',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 10),

                // Option 1: Take Photo with Camera
                _buildActionTile(
                  icon: Icons.camera_enhance_outlined,
                  color: const Color(0xFF0066FF),
                  title: 'Take Photo',
                  subtitle: 'Use device camera to capture new photo',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _pickFromSource(context, ref, ImageSource.camera);
                  },
                ),

                // Option 2: Choose from Gallery
                _buildActionTile(
                  icon: Icons.photo_library_outlined,
                  color: const Color(0xFF10B981),
                  title: 'Choose from Gallery',
                  subtitle: 'Select an existing image from your gallery',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _pickFromSource(context, ref, ImageSource.gallery);
                  },
                ),

                // Option 3: Choose from Sample Avatars
                _buildActionTile(
                  icon: Icons.face_retouching_natural_outlined,
                  color: const Color(0xFF8B5CF6),
                  title: 'Choose Sample Preset Avatar',
                  subtitle: 'Select from high-quality professional presets',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showSampleAvatarsDialog(context, ref);
                  },
                ),

                // Option 4: Remove Photo (if active)
                if (currentPhoto.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _buildActionTile(
                    icon: Icons.delete_outline_rounded,
                    color: const Color(0xFFEF4444),
                    title: 'Remove Current Photo',
                    subtitle: 'Reset to default initials & monogram avatar',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      removePhoto(ref);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile Photo Removed!'),
                          backgroundColor: Color(0xFFEF4444),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildActionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _pickFromSource(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (file != null) {
        updatePhoto(ref, file.path);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Profile Photo Updated!'),
                ],
              ),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access image: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  static void _showSampleAvatarsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Select Sample Preset Avatar',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: sampleAvatars.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (ctx, index) {
              final avatar = sampleAvatars[index];
              return InkWell(
                onTap: () {
                  Navigator.pop(dialogCtx);
                  updatePhoto(ref, avatar['url']!);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Profile Photo Updated!'),
                          ],
                        ),
                        backgroundColor: Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: const Color(0xFF0066FF).withOpacity(0.12),
                        backgroundImage: NetworkImage(avatar['url']!),
                        onBackgroundImageError: (_, __) {},
                      ),
                      const SizedBox(height: 8),
                      Text(
                        avatar['name']!,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
