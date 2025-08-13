import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'providers/language_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _user = FirebaseAuth.instance.currentUser;
  final _firestore = FirebaseFirestore.instance;

  String _selectedLanguage = "English";
  String _selectedLocation = "USA";
  String _displayName = "";
  String? _profileImageUrl;
  String? _selectedAvatar;

  final TextEditingController _nameController = TextEditingController();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // 미리 정의된 아바타 목록
  final List<String> _avatarOptions = [
    'assets/avatars/avatar1.png',
    'assets/avatars/avatar2.png',
    'assets/avatars/avatar3.png',
    'assets/avatars/avatar4.png',
    'assets/avatars/avatar5.png',
    'assets/avatars/avatar6.png',
    'assets/avatars/avatar7.png',
    'assets/avatars/avatar8.png',
    'assets/avatars/avatar9.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    if (_user == null) return;
    final doc = await _firestore.collection('users').doc(_user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _displayName = data['displayName'] ?? "User Name";
        _selectedLanguage = data['language'] ?? "English";
        _selectedLocation = data['location'] ?? "USA";
        _profileImageUrl = data['profileImageUrl'];
        _selectedAvatar = data['selectedAvatar'];
        _nameController.text = _displayName;
      });
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 스크롤 가능하게 설정
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.25, // 화면 높이의 25%
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 드래그 핸들
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                AppLocalizations.of(context)?.editProfile ??
                    'Choose Profile Picture',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImageFromGallery();
                    },
                    icon: const Icon(Icons.photo_library),
                    label: Text(
                        AppLocalizations.of(context)?.selectFromGallery ??
                            'Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFCBF02),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showAvatarSelection();
                    },
                    icon: const Icon(Icons.face),
                    label: const Text('Avatar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C2461),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        _selectedAvatar = null; // 갤러리 이미지 선택 시 아바타 선택 해제
      });
      await _uploadImageToFirebase();
    }
  }

  Future<void> _uploadImageToFirebase() async {
    if (_profileImage == null || _user == null) return;

    try {
      // 로딩 상태 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)?.loading ?? 'Uploading...'),
          duration: const Duration(seconds: 1),
        ),
      );

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${_user.uid}.jpg');

      await storageRef.putFile(_profileImage!);
      final downloadUrl = await storageRef.getDownloadURL();

      // Firestore에 이미지 URL 저장
      await _firestore.collection('users').doc(_user.uid).set({
        'profileImageUrl': downloadUrl,
        'selectedAvatar': null, // 갤러리 이미지 선택 시 아바타 선택 해제
      }, SetOptions(merge: true));

      setState(() {
        _profileImageUrl = downloadUrl;
        _selectedAvatar = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.save ??
              'Profile picture uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${AppLocalizations.of(context)?.error ?? 'Failed to upload image'}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAvatarSelection() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              AppLocalizations.of(context)?.selectLanguage ?? 'Choose Avatar'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300, // 고정 높이 설정
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _avatarOptions.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    if (_user == null) return;

                    // 선택된 아바타를 즉시 Firestore에 저장
                    try {
                      await _firestore.collection('users').doc(_user.uid).set({
                        'selectedAvatar': _avatarOptions[index],
                        'profileImageUrl': null, // 아바타 선택 시 갤러리 이미지 해제
                      }, SetOptions(merge: true));

                      setState(() {
                        _selectedAvatar = _avatarOptions[index];
                        _profileImage = null;
                        _profileImageUrl = null;
                      });

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)?.save ??
                              'Avatar updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${AppLocalizations.of(context)?.error ?? 'Failed to update avatar'}: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedAvatar == _avatarOptions[index]
                            ? const Color(0xFFFCBF02)
                            : Colors.grey,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: CircleAvatar(
                      backgroundImage: AssetImage(_avatarOptions[index]),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveUserSettings() async {
    if (_user == null) return;
    await _firestore.collection('users').doc(_user.uid).set({
      'displayName': _nameController.text.trim(),
      'language': _selectedLanguage,
      'location': _selectedLocation,
      'profileImageUrl': _profileImageUrl,
      'selectedAvatar': _selectedAvatar,
    }, SetOptions(merge: true));

    setState(() {
      _displayName = _nameController.text.trim();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)?.save ?? "Changes saved"),
        backgroundColor: Colors.green,
      ),
    );
  }

  ImageProvider _getProfileImage() {
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    } else if (_selectedAvatar != null) {
      return AssetImage(_selectedAvatar!);
    } else if (_profileImageUrl != null) {
      return NetworkImage(_profileImageUrl!);
    } else {
      return const AssetImage('assets/profile_pic.png');
    }
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0C2461), // darkBlue
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const themeYellow = Color(0xFFFCBF02);
    const darkBlue = Color(0xFF0C2461);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkBlue),
        title: Text(
          AppLocalizations.of(context)?.editProfile ?? "Edit Profile",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: darkBlue,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        children: [
          const SizedBox(height: 10),
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _getProfileImage(),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFCBF02),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          _buildInputLabel(AppLocalizations.of(context)?.profile ?? "Username"),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)?.editProfile ??
                  "Enter display name",
              border: const UnderlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
          const SizedBox(height: 20),
          _buildInputLabel(AppLocalizations.of(context)?.email ?? "Email"),
          const SizedBox(height: 6),
          Text(
            _user?.email ?? "",
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          _buildInputLabel(AppLocalizations.of(context)?.selectLanguage ??
              "Select Language"),
          const SizedBox(height: 6),
          Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
            return DropdownButtonFormField<String>(
              value: languageProvider.locale.languageCode == 'ko'
                  ? 'Korean'
                  : 'English',
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              items: [
                DropdownMenuItem(
                    value: "English",
                    child: Text(
                        AppLocalizations.of(context)?.english ?? "English")),
                DropdownMenuItem(
                    value: "Korean",
                    child: Text(AppLocalizations.of(context)?.korean ?? "한국어")),
              ],
              onChanged: (value) {
                if (value == 'Korean') {
                  languageProvider.changeLanguage(const Locale('ko'));
                } else {
                  languageProvider.changeLanguage(const Locale('en'));
                }
                setState(() {
                  _selectedLanguage = value!;
                });
              },
            );
          }),
          const SizedBox(height: 20),
          _buildInputLabel("Select Location"),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedLocation,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            items: const [
              DropdownMenuItem(value: "USA", child: Text("USA")),
              DropdownMenuItem(
                  value: "South Korea", child: Text("South Korea")),
              DropdownMenuItem(value: "Germany", child: Text("Germany")),
            ],
            onChanged: (value) {
              setState(() {
                _selectedLocation = value!;
              });
            },
          ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeYellow,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _saveUserSettings,
              child: Text(AppLocalizations.of(context)?.save ?? "Save Changes",
                  style: const TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
