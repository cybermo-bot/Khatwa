import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/auth_store.dart';
import '../features/common.dart';
import 'app_theme.dart';

/// The patient's own profile photo. It stays on this device (small, about
/// 30 kB) and is never sent to the doctor or the server.
class ProfilePhoto {
  static final ValueNotifier<Uint8List?> current = ValueNotifier(null);
  static String? _loadedFor;

  static String _key(String accountId) => 'khatwa_avatar_$accountId';

  /// Loads the photo of the signed-in account, once per account.
  static Future<void> ensure() async {
    final id = AuthStore.instance.current?.id;
    if (id == _loadedFor) return;
    _loadedFor = id;
    if (id == null) {
      current.value = null;
      return;
    }
    try {
      final saved = (await SharedPreferences.getInstance()).getString(_key(id));
      if (_loadedFor == id) current.value = saved == null ? null : base64Decode(saved);
    } catch (_) {
      current.value = null;
    }
  }

  /// Picks a photo from the gallery or the camera. Returns false when the
  /// patient cancelled or the picture could not be read.
  static Future<bool> pick(ImageSource source) async {
    final id = AuthStore.instance.current?.id;
    if (id == null) return false;
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 360,
        maxHeight: 360,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.front,
      );
      if (file == null) return false;
      final bytes = await file.readAsBytes();
      await (await SharedPreferences.getInstance()).setString(_key(id), base64Encode(bytes));
      _loadedFor = id;
      current.value = bytes;
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> remove() async {
    final id = AuthStore.instance.current?.id;
    if (id == null) return;
    await (await SharedPreferences.getInstance()).remove(_key(id));
    current.value = null;
  }
}

/// A round avatar: the profile photo, or the initials, or a person icon.
class ProfileAvatar extends StatefulWidget {
  final double size;
  final String name;

  /// Shows a small camera badge (the Me page, where tapping changes it).
  final bool editable;
  final VoidCallback? onTap;

  const ProfileAvatar({super.key, required this.size, required this.name, this.editable = false, this.onTap});

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  @override
  void initState() {
    super.initState();
    ProfilePhoto.ensure();
  }

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    final first = parts.first.characters.first;
    final second = parts.length > 1 ? parts.last.characters.first : '';
    return (first + second).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return Semantics(
      button: widget.onTap != null,
      label: widget.editable
          ? tr('Photo de profil, la changer',
              aeb: 'تصويرة البروفيل، بدّلها', ar: 'صورة الملف الشخصي، تغييرها', en: 'Profile photo, change it')
          : tr('Mon profil', aeb: 'البروفيل متاعي', ar: 'ملفي الشخصي', en: 'My profile'),
      child: InkResponse(
        onTap: widget.onTap,
        radius: s / 2 + 6,
        // At least 48 x 48 to tap, even when the picture is smaller.
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: ValueListenableBuilder<Uint8List?>(
              valueListenable: ProfilePhoto.current,
              builder: (context, photo, _) {
                final letters = initials(widget.name);
                return Stack(clipBehavior: Clip.none, children: [
                  Container(
                    width: s,
                    height: s,
                    alignment: Alignment.center,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: K.primarySoft,
                      shape: BoxShape.circle,
                      border: Border.all(color: K.glow.withAlpha(140), width: 1.5),
                      boxShadow: [
                        BoxShadow(color: K.glow.withAlpha(K.isDark ? 70 : 30), blurRadius: s * 0.35, spreadRadius: -4)
                      ],
                    ),
                    child: photo != null
                        ? Image.memory(photo, width: s, height: s, fit: BoxFit.cover, gaplessPlayback: true)
                        : letters.isNotEmpty
                            ? Text(letters, style: (s >= 56 ? K.h1 : K.bodyStrong).copyWith(color: K.primaryStrong))
                            : Icon(Icons.person_rounded, color: K.primaryStrong, size: s * 0.55),
                  ),
                  if (widget.editable)
                    PositionedDirectional(
                      end: -2,
                      bottom: -2,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                            color: K.primary, shape: BoxShape.circle, border: Border.all(color: K.surface, width: 2)),
                        child: Icon(Icons.photo_camera_rounded, size: 14, color: K.onPrimary),
                      ),
                    ),
                ]);
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Choose, take or remove the profile photo.
Future<void> showProfilePhotoSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: K.surface,
      builder: (sheet) {
        Future<void> run(Future<void> Function() action) async {
          Navigator.of(sheet).pop();
          await action();
        }

        return SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(
              minTileHeight: 56,
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(tr('Choisir une photo', aeb: 'اختار تصويرة', ar: 'اختيار صورة', en: 'Choose a photo')),
              onTap: () => run(() => ProfilePhoto.pick(ImageSource.gallery)),
            ),
            if (!kIsWeb)
              ListTile(
                minTileHeight: 56,
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(tr('Prendre une photo', aeb: 'صوّر توّا', ar: 'التقاط صورة', en: 'Take a photo')),
                onTap: () => run(() => ProfilePhoto.pick(ImageSource.camera)),
              ),
            if (ProfilePhoto.current.value != null)
              ListTile(
                minTileHeight: 56,
                leading: Icon(Icons.delete_outline_rounded, color: K.danger),
                title: Text(tr('Retirer la photo', aeb: 'نحّي التصويرة', ar: 'إزالة الصورة', en: 'Remove the photo'),
                    style: TextStyle(color: K.danger)),
                onTap: () => run(ProfilePhoto.remove),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Text(
                tr('La photo reste sur cet appareil.',
                    aeb: 'التصويرة تقعد في الجهاز هذا.',
                    ar: 'تبقى الصورة على هذا الجهاز.',
                    en: 'The photo stays on this device.'),
                style: K.small.copyWith(color: K.inkSoft),
              ),
            ),
          ]),
        );
      },
    );
