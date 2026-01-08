import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_luxe/services/user_profile_service.dart';
import 'package:urban_luxe/state/main_tab_notifier.dart';
import 'package:urban_luxe/services/hotel_cart_service.dart';
import 'package:urban_luxe/state/cart_notifier.dart';
import 'package:urban_luxe/utils/app_snackbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _username;
  String _fullname = "";
  String _email = "";
  String _avatarB64 = "";

  int _favoriteCount = 0;
  int _cartCount = 0;

  bool _loading = true;
  late final VoidCallback _tabListener;
  late final VoidCallback _cartListener;

  @override
  void initState() {
    super.initState();
    _loadProfile();

    _tabListener = () {
      if (!mounted) return;
      if (mainTabIndex.value == 3) _loadProfile();
    };
    mainTabIndex.addListener(_tabListener);

    _cartListener = () {
      if (!mounted) return;
      _loadProfile();
    };
    cartChanged.addListener(_cartListener);
  }

  @override
  void dispose() {
    mainTabIndex.removeListener(_tabListener);
    cartChanged.removeListener(_cartListener);
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final u = await UserProfileService.getCurrentUser();

    final favIds = prefs.getStringList('favorite_hotel_ids') ?? [];
    final cartCount = await HotelCartService.loadCount();
    // final cartCount = (await HotelCartService.loadItems()).length;

    if (!mounted) return;

    if (u == null || u.isEmpty) {
      setState(() {
        _username = null;
        _fullname = "";
        _email = "";
        _avatarB64 = "";
        _favoriteCount = 0;
        _cartCount = 0;
        _loading = false;
      });
      return;
    }

    final fn = await UserProfileService.getFullname(u);
    final em = await UserProfileService.getEmail(u);
    final av = await UserProfileService.getAvatarBase64(u);

    if (!mounted) return;
    setState(() {
      _username = u;
      _fullname = fn.isEmpty ? "-" : fn;
      _email = em.isEmpty ? "-" : em;
      _avatarB64 = av;
      _favoriteCount = favIds.length;
      _cartCount = cartCount;
      _loading = false;
    });
  }

  int _readCartCount(SharedPreferences prefs) {
    final list1 = prefs.getStringList('cart_items');
    if (list1 != null) return list1.length;

    final list2 = prefs.getStringList('cart_item_ids');
    if (list2 != null) return list2.length;

    final jsonStr =
        prefs.getString('cart_items_json') ?? prefs.getString('cart_items_data');
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(jsonStr);
        if (decoded is List) return decoded.length;
      } catch (_) {}
    }

    return 0;
  }

  Future<void> _changePhoto() async {
    if (_username == null) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const Text(
                "Pilih Foto",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Ambil dari Kamera"),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Pilih dari Galeri"),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: source,
      imageQuality: 75,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    final b64 = base64Encode(bytes);

    await UserProfileService.saveAvatarBase64(_username!, b64);

    if (!mounted) return;
    setState(() => _avatarB64 = b64);

    AppSnackBar.success(context, "Foto profile berhasil diubah");
  }

  Future<void> _editFullname() async {
    if (_username == null) return;

    final controller = TextEditingController(
      text: _fullname == "-" ? "" : _fullname,
    );

    final newName = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 14,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Edit Name",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Fullname",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7CF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (newName == null) return;
    if (newName.isEmpty) {
      AppSnackBar.error(context, "Fullname tidak boleh kosong");
      return;
    }

    await UserProfileService.updateFullname(_username!, newName);
    await _loadProfile();

    if (!mounted) return;
    AppSnackBar.success(context, "Fullname berhasil diupdate");
  }

  Future<void> _editEmail() async {
    if (_username == null) return;

    final controller = TextEditingController(
      text: _email == "-" ? "" : _email,
    );

    final newEmail = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 14,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Edit Email",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7CF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (newEmail == null) return;
    if (newEmail.isEmpty) {
      AppSnackBar.error(context, "Email tidak boleh kosong");
      return;
    }

    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(newEmail);
    if (!ok) {
      AppSnackBar.error(context, "Format email tidak valid");
      return;
    }

    await UserProfileService.updateEmail(_username!, newEmail);
    await _loadProfile();

    if (!mounted) return;
    AppSnackBar.success(context, "Email berhasil diupdate");
  }

  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    final u = _username;

    await prefs.setBool('is_logged_in', false);
    await prefs.remove('full_name');
    await HotelCartService.clear();
    await prefs.remove('hotel_cart_items_v1');
    await prefs.remove('cart_items');
    await prefs.remove('cart_item_ids');
    await prefs.remove('cart_items_json');
    await prefs.remove('cart_items_data');

    if (u != null && u.isNotEmpty) {
      await UserProfileService.clearProfile(u);
    }

    await UserProfileService.clearCurrentUser();

    if (!mounted) return;
    setState(() {
      _username = null;
      _fullname = "";
      _email = "";
      _avatarB64 = "";
      _favoriteCount = 0;
      _cartCount = 0;
    });

    AppSnackBar.info(context, "Sign out berhasil");
  }

  void _goToSignIn() {
    Navigator.pushReplacementNamed(context, '/signin');
  }

  Uint8List? _avatarBytes() {
    if (_avatarB64.isEmpty) return null;
    try {
      return base64Decode(_avatarB64);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isLoggedIn = _username != null && _username!.isNotEmpty;

    final usernameText = !isLoggedIn ? "-" : "@${_username!}";
    final fullNameText =_fullname.isEmpty ? "-" : _fullname;
    final emailText = _email.isEmpty ? "-" : _email;

    final String topLetter = isLoggedIn ? _username! : "";
    final avatarBytes = _avatarBytes();

    return Scaffold(
      body: Stack(
        children: [
          const _GreenBackground(),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      SizedBox(height: isLoggedIn ? 14 : 0),

                      if (isLoggedIn)
                        Center(
                          child: Text(
                            topLetter, 
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                      SizedBox(height: isLoggedIn ? 14 : 0),

                      Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 108,
                              height: 108,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.95),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 16,
                                    offset: const Offset(0, 10),
                                    color: Colors.black.withOpacity(0.18),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: avatarBytes == null
                                    ? const Icon(Icons.person,
                                        size: 56, color: Color(0xFF2A7E62))
                                    : ClipOval(
                                        child: Image.memory(
                                          avatarBytes,
                                          width: 108,
                                          height: 108,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                            ),

                            if (isLoggedIn)
                              Positioned(
                                right: -2,
                                bottom: 6,
                                child: _CircleIconButton(
                                  size: 34,
                                  iconSize: 18,
                                  icon: Icons.edit,
                                  bg: Colors.white,
                                  fg: const Color(0xFF2A7E62),
                                  onTap: _changePhoto,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoBlock(label: "USERNAME", value: usernameText),
                        
                        const SizedBox(height: 14),

                        InkWell(
                          onTap: isLoggedIn ? _editFullname : null,
                          child: _InfoBlock(label: "FULLNAME", value: fullNameText),
                        ),

                        const SizedBox(height: 14),

                        InkWell(
                          onTap: isLoggedIn ? _editEmail : null,
                          child: _InfoBlock(label: "EMAIL ADDRESS", value: emailText),
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: "Favorite",
                                count: _favoriteCount,
                                icon: Icons.favorite,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: "Keranjang",
                                count: _cartCount,
                                icon: Icons.shopping_bag,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 26),
                      ],
                    ),
                  ),
                ),

                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (isLoggedIn) {
                            await _signOut();
                          } else {
                            _goToSignIn();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isLoggedIn ? const Color(0xFFE53935) : const Color(0xFF2E7CF6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isLoggedIn ? "Sign Out" : "Sign In",
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GreenBackground extends StatelessWidget {
  const _GreenBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2FAE88), Color(0xFF2A7E62)],
        ),
      ),
      child: Stack(
        children: const [
          _Bubble(x: 0.16, y: 0.17, size: 18, filled: false),
          _Bubble(x: 0.10, y: 0.28, size: 10, filled: true),
          _Bubble(x: 0.26, y: 0.36, size: 26, filled: false),
          _Bubble(x: 0.42, y: 0.30, size: 14, filled: true),
          _Bubble(x: 0.66, y: 0.23, size: 22, filled: false),
          _Bubble(x: 0.78, y: 0.36, size: 12, filled: true),
          _Bubble(x: 0.58, y: 0.44, size: 28, filled: false),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final double x;
  final double y;
  final double size;
  final bool filled;

  const _Bubble({
    required this.x,
    required this.y,
    required this.size,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: MediaQuery.of(context).size.width * x,
      top: MediaQuery.of(context).size.height * y,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? Colors.white.withOpacity(0.15) : Colors.transparent,
          border: filled
              ? null
              : Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 2,
                ),
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.70),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withOpacity(0.96),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withOpacity(0.18), height: 1),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "$count",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.98),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color bg;
  final Color fg;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.size = 40,
    this.iconSize = 20,
    this.bg = const Color(0x22FFFFFF),
    this.fg = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: fg, size: iconSize),
        ),
      ),
    );
  }
}