import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/app_logo.dart';
import 'dart:async';
import '../../main.dart';
import '../login_page.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  final bool showHeader;
  const ProfileScreen({super.key, required this.user, this.showHeader = true});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String name;
  late String email;
  late String phone;
  late String? profileImageUrl;
  bool editingName = false;
  bool editingPhone = false;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;
  bool _isUploadingImage = false;
  bool notificationsEnabled = true;
  bool darkMode = false;

  // Add this flag
  bool _isLoggingOut = false;

  final List<String> _emergencyMessages = [
    "In case of fire, call 911 immediately.",
    "Keep your emergency contacts up to date.",
    "Know your nearest exit routes.",
    "Stay calm and follow safety protocols.",
    "Report suspicious activity to authorities.",
    "Have a first aid kit accessible.",
    "Practice emergency drills regularly.",
  ];
  int _currentMessageIndex = 0;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    name = widget.user.fullName;
    email = widget.user.email;
    phone = widget.user.phoneNumber ?? '';
    profileImageUrl = widget.user.profileImageUrl;
    _nameController.text = name;
    _phoneController.text = phone;
    _startMessageRotation();
  }

  void _startMessageRotation() {
    _messageTimer?.cancel();
    _messageTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      setState(() {
        _currentMessageIndex =
            (_currentMessageIndex + 1) % _emergencyMessages.length;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image != null) {
      await _uploadImage(File(image.path));
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image != null) {
      await _uploadImage(File(image.path));
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() {
      _isUploadingImage = true;
    });

    try {
      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(
        'profile_images/${widget.user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Update user profile with new image URL
      final updatedUser = UserModel(
        uid: widget.user.uid,
        email: widget.user.email,
        fullName: name,
        role: widget.user.role,
        departmentId: widget.user.departmentId,
        departmentName: widget.user.departmentName,
        employeeId: widget.user.employeeId,
        phoneNumber: phone,
        profileImageUrl: downloadUrl,
        createdAt: widget.user.createdAt,
        isActive: widget.user.isActive,
      );

      await _authService.updateUserData(updatedUser);

      setState(() {
        profileImageUrl = downloadUrl;
        _isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Profile Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> saveName() async {
    setState(() {
      _isSaving = true;
    });
    final updatedUser = UserModel(
      uid: widget.user.uid,
      email: widget.user.email,
      fullName: _nameController.text.trim(),
      role: widget.user.role,
      departmentId: widget.user.departmentId,
      departmentName: widget.user.departmentName,
      employeeId: widget.user.employeeId,
      phoneNumber: phone,
      profileImageUrl: profileImageUrl,
      createdAt: widget.user.createdAt,
      isActive: widget.user.isActive,
    );
    await _authService.updateUserData(updatedUser);
    setState(() {
      name = _nameController.text.trim();
      editingName = false;
      _isSaving = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Name updated successfully!')));
    Navigator.of(context).pop(updatedUser);
  }

  Future<void> savePhone() async {
    setState(() {
      _isSaving = true;
    });
    final updatedUser = UserModel(
      uid: widget.user.uid,
      email: widget.user.email,
      fullName: name,
      role: widget.user.role,
      departmentId: widget.user.departmentId,
      departmentName: widget.user.departmentName,
      employeeId: widget.user.employeeId,
      phoneNumber: _phoneController.text.trim(),
      profileImageUrl: profileImageUrl,
      createdAt: widget.user.createdAt,
      isActive: widget.user.isActive,
    );
    await _authService.updateUserData(updatedUser);
    setState(() {
      phone = _phoneController.text.trim();
      editingPhone = false;
      _isSaving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Phone number updated successfully!')),
    );
    Navigator.of(context).pop(updatedUser);
  }

  void _launchPhone(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange.shade400, Colors.deepOrange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            'GUARDIAN SAVE',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          AppLogo.build(size: 28, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildProfileIconWithAnimatedBackground() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Animated background (e.g., animated gradient or shimmer)
        AnimatedContainer(
          duration: const Duration(seconds: 2),
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.deepOrange.withOpacity(0.18),
                Colors.deepOrange.withOpacity(0.08),
                Colors.white.withOpacity(0.0),
              ],
              stops: [0.5, 0.8, 1.0],
            ),
          ),
        ),
        // Profile Icon
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.deepOrange,
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl!)
                    : null,
                child: profileImageUrl == null
                    ? const Icon(Icons.person, size: 70, color: Colors.white)
                    : null,
              ),
              if (_isUploadingImage)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _isUploadingImage
                        ? null
                        : _showImagePickerDialog,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggingOut) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE0B2), Color(0xFFE0E0E0), Color(0xFFFFCC80)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            if (widget.showHeader) _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    // Profile Image Section
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      ),
                      child: Center(
                        child: _buildProfileIconWithAnimatedBackground(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Profile Info Cards
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 700),
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      ),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Name Section
                              Row(
                                children: [
                                  const Icon(
                                    Icons.badge,
                                    color: Colors.deepOrange,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: editingName
                                        ? TextField(
                                            controller: _nameController,
                                            autofocus: true,
                                            decoration: InputDecoration(
                                              labelText: 'Full Name',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              fillColor: Colors.white,
                                              filled: true,
                                            ),
                                          )
                                        : Text(
                                            name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      editingName ? Icons.check : Icons.edit,
                                      color: Colors.deepOrange,
                                    ),
                                    onPressed: _isSaving
                                        ? null
                                        : () {
                                            if (editingName) {
                                              saveName();
                                            } else {
                                              setState(
                                                () => editingName = true,
                                              );
                                            }
                                          },
                                  ),
                                ],
                              ),
                              const Divider(height: 32),

                              // Email Section
                              InkWell(
                                onTap: () => _launchEmail(email),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.email,
                                        color: Colors.deepOrange,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          email,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 18,
                                        color: Colors.deepOrange,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(height: 32),

                              // Phone Section
                              InkWell(
                                onTap: () => _launchPhone(phone),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.phone,
                                        color: Colors.deepOrange,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: editingPhone
                                            ? TextField(
                                                controller: _phoneController,
                                                autofocus: true,
                                                keyboardType:
                                                    TextInputType.phone,
                                                decoration: InputDecoration(
                                                  labelText: 'Phone Number',
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                ),
                                              )
                                            : Text(
                                                phone.isNotEmpty
                                                    ? phone
                                                    : 'No phone number',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          editingPhone
                                              ? Icons.check
                                              : Icons.edit,
                                          color: Colors.deepOrange,
                                        ),
                                        onPressed: _isSaving
                                            ? null
                                            : () {
                                                if (editingPhone) {
                                                  savePhone();
                                                } else {
                                                  setState(
                                                    () => editingPhone = true,
                                                  );
                                                }
                                              },
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 18,
                                        color: Colors.deepOrange,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Emergency Contacts Card
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      ),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Emergency Contacts',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildContactTile(
                                'Emergency',
                                '911',
                                Icons.local_hospital,
                                _launchPhone,
                              ),
                              _buildContactTile(
                                'Police',
                                '911',
                                Icons.local_police,
                                _launchPhone,
                              ),
                              _buildContactTile(
                                'Department',
                                '911',
                                Icons.apartment,
                                _launchPhone,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Settings Card
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 900),
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      ),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Settings',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SwitchListTile(
                                value: notificationsEnabled,
                                onChanged: (val) {
                                  setState(() => notificationsEnabled = val);
                                },
                                title: const Text('Enable Notifications'),
                                activeColor: Colors.deepOrange,
                                contentPadding: EdgeInsets.zero,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.brightness_6,
                                    color: Colors.deepOrange,
                                  ),
                                  const SizedBox(width: 16),
                                  const Text(
                                    'Theme',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  DropdownButton<ThemeMode>(
                                    value: themeNotifier.value,
                                    onChanged: (mode) {
                                      if (mode != null) {
                                        themeNotifier.setTheme(mode);
                                      }
                                    },
                                    items: const [
                                      DropdownMenuItem(
                                        value: ThemeMode.system,
                                        child: Text('System'),
                                      ),
                                      DropdownMenuItem(
                                        value: ThemeMode.light,
                                        child: Text('Light'),
                                      ),
                                      DropdownMenuItem(
                                        value: ThemeMode.dark,
                                        child: Text('Dark'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    // Log Out Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          'Log Out',
                          style: TextStyle(fontSize: 18),
                        ),
                        onPressed: () async {
                          setState(() => _isLoggingOut = true);
                          await AuthService().signOut();
                          if (mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                              (route) => false,
                            );
                          }
                          return; // Prevent further code execution
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(
    String label,
    String value,
    IconData icon,
    Function(String) onTap,
  ) {
    return InkWell(
      onTap: () => onTap(value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.deepOrange),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '$label: $value',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.blue),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.deepOrange,
            ),
          ],
        ),
      ),
    );
  }
}
