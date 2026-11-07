import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth_kyc/providers/auth_kyc_provider.dart';
import '../../features/profile/providers/profile_provider.dart';
import '../../features/profile/services/profile_photo_service.dart';
import '../constants/api_constants.dart';
import '../services/cache_service.dart';

class FinmosUserAvatar extends ConsumerWidget {
  final double radius;
  final bool showCameraBadge;
  final bool isTappable;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;

  const FinmosUserAvatar({
    super.key,
    this.radius = 40,
    this.showCameraBadge = false,
    this.isTappable = false,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
  });

  ImageProvider? _resolveImageProvider(String path) {
    if (path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    // Check local device storage first (Android / iOS / Desktop cache & file paths)
    if (!kIsWeb) {
      try {
        final cleanPath = path.startsWith('file://') ? path.substring(7) : path;
        final file = File(cleanPath);
        if (file.existsSync() ||
            cleanPath.startsWith('/data/') ||
            cleanPath.startsWith('/storage/') ||
            cleanPath.startsWith('/var/') ||
            cleanPath.startsWith('C:\\') ||
            cleanPath.startsWith('D:\\')) {
          if (file.existsSync()) {
            return FileImage(file);
          }
        }

        // Check if there is an active local avatar path cached on device
        final cachedLocal = LocalCacheService().get('active_local_avatar') as String?;
        if (cachedLocal != null && cachedLocal.isNotEmpty) {
          final localFile = File(cachedLocal);
          if (localFile.existsSync()) {
            return FileImage(localFile);
          }
        }

        // Check if mapped specifically for this upload URL
        final cachedForUrl = LocalCacheService().get('avatar_local_$path') as String?;
        if (cachedForUrl != null && cachedForUrl.isNotEmpty) {
          final localFile = File(cachedForUrl);
          if (localFile.existsSync()) {
            return FileImage(localFile);
          }
        }

        // If path references a local device scaled photo (e.g. scaled_1000161603.jpg)
        final match = RegExp(r'(scaled_[0-9]+\.jpe?g)').firstMatch(path);
        if (match != null) {
          final localCandidate = File('/data/user/0/com.finomos/cache/${match.group(1)}');
          if (localCandidate.existsSync()) {
            return FileImage(localCandidate);
          }
          final legacyCandidate = File('/data/user/0/com.example.finomos/cache/${match.group(1)}');
          if (legacyCandidate.existsSync()) {
            return FileImage(legacyCandidate);
          }
        }
      } catch (_) {}
    }

    // Relative /uploads/ server paths:
    // Render does not mount a static file route for /uploads, which causes 404s.
    // If no local file copy was found on this device, cleanly return null to display
    // the user's initial monogram circle without making a failing HTTP GET request.
    if (path.startsWith('/uploads/')) {
      return null;
    }

    // Only prepend baseUrl for other relative server endpoints
    if (path.startsWith('/api/') || path.startsWith('/static/')) {
      return NetworkImage('${ApiConstants.baseUrl}$path');
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileUrl = ref.watch(profileProvider).personalInfo.profilePicUrl;
    final kycUser = ref.watch(authKycProvider).user;
    final activePhoto = profileUrl.isNotEmpty ? profileUrl : kycUser.profilePicUrl;
    final imageProvider = _resolveImageProvider(activePhoto);

    final userName = kycUser.fullName.isNotEmpty
        ? kycUser.fullName
        : ref.watch(profileProvider).personalInfo.fullName;
    final initial = userName.trim().isNotEmpty ? userName.trim()[0].toUpperCase() : 'S';

    final effectiveBgColor = backgroundColor ?? const Color(0xFF0066FF).withOpacity(0.12);
    final effectiveIconColor = iconColor ?? const Color(0xFF0066FF);

    Widget avatarWidget = CircleAvatar(
      radius: radius,
      backgroundColor: effectiveBgColor,
      backgroundImage: imageProvider,
      onBackgroundImageError: imageProvider != null ? (_, __) {} : null,
      child: imageProvider == null
          ? (radius >= 30
              ? Text(
                  initial,
                  style: TextStyle(
                    fontSize: radius * 0.75,
                    fontWeight: FontWeight.bold,
                    color: effectiveIconColor,
                  ),
                )
              : Icon(
                  Icons.person,
                  size: radius * 1.1,
                  color: effectiveIconColor,
                ))
          : null,
    );

    if (isTappable || showCameraBadge) {
      avatarWidget = InkWell(
        onTap: onTap ?? () => ProfilePhotoService.showPhotoOptionsSheet(context, ref),
        borderRadius: BorderRadius.circular(radius),
        child: avatarWidget,
      );
    }

    if (!showCameraBadge) {
      return avatarWidget;
    }

    final badgeRadius = radius >= 36 ? 14.0 : 10.0;
    final iconSize = radius >= 36 ? 13.0 : 9.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatarWidget,
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => ProfilePhotoService.showPhotoOptionsSheet(context, ref),
            child: Container(
              padding: EdgeInsets.all(badgeRadius * 0.28),
              decoration: BoxDecoration(
                color: const Color(0xFF0066FF),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt,
                size: iconSize,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
