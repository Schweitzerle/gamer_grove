import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/data/models/user_model.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_event.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class EditProfilePage extends StatefulWidget {
  static const String routeName = 'edit_profile';
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _bioController;
  Country? _selectedCountry;
  String? _initialCountryName;
  File? _selectedImageFile;
  bool _isLoading = false;

  late bool _isProfilePublic;
  late bool _showWishlist;
  late bool _showRatedGames;
  late bool _showRecommendedGames;
  late bool _showTopThree;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.user.bio);
    _isProfilePublic = widget.user.isProfilePublic;
    _showWishlist = widget.user.showWishlist;
    _showRatedGames = widget.user.showRatedGames;
    _showRecommendedGames = widget.user.showRecommendedGames;
    _showTopThree = widget.user.showTopThree;
    _initialCountryName = widget.user.country;
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? avatarUrl;
      final supabaseClient = supabase.Supabase.instance.client;

      // 1. Upload image if selected
      if (_selectedImageFile != null) {
        final file = _selectedImageFile!;
        final extension = p.extension(file.path).substring(1);
        final filePath = '/${widget.user.id}/avatar.$extension';

        await supabaseClient.storage.from('avatars').upload(
              filePath,
              file,
              fileOptions: const supabase.FileOptions(
                  cacheControl: '3600', upsert: true),
            );

        avatarUrl =
            supabaseClient.storage.from('avatars').getPublicUrl(filePath);
      }

      // 2. Prepare data for update
      final updates = {
        'bio': _bioController.text,
        'country': _selectedCountry?.name ?? _initialCountryName,
        'is_profile_public': _isProfilePublic,
        'show_wishlist': _showWishlist,
        'show_rated_games': _showRatedGames,
        'show_recommended_games': _showRecommendedGames,
        'show_top_three': _showTopThree,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (avatarUrl != null) {
        updates['avatar_url'] = avatarUrl;
      }

      // 3. Update profile
      await supabaseClient
          .from('users')
          .update(updates)
          .eq('id', widget.user.id);

      // 4. Fetch updated user data
      final updatedData = await supabaseClient
          .from('users')
          .select()
          .eq('id', widget.user.id)
          .single();
      final updatedUser = UserModel.fromJson(updatedData).toEntity();

      if (mounted) {
        // 5. Update global auth state
        context.read<AuthBloc>().add(UserDataUpdated(updatedUser));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 24),
                  _buildBioField(),
                  const SizedBox(height: 24),
                  _buildCountryPicker(),
                  const SizedBox(height: 24),
                  _buildPrivacySwitches(),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final theme = Theme.of(context);
    ImageProvider? backgroundImage;

    if (_selectedImageFile != null) {
      backgroundImage = FileImage(_selectedImageFile!);
    } else if (widget.user.hasAvatar) {
      backgroundImage = CachedNetworkImageProvider(widget.user.avatarUrl!);
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: theme.colorScheme.primaryContainer,
            backgroundImage: backgroundImage,
            child: backgroundImage == null
                ? Text(
                    widget.user.username[0].toUpperCase(),
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: _pickImage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioField() {
    return TextFormField(
      controller: _bioController,
      decoration: const InputDecoration(
        labelText: 'Bio',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      maxLength: 150,
    );
  }

  Widget _buildCountryPicker() {
    return ListTile(
      title: Text(
          _selectedCountry?.name ?? _initialCountryName ?? 'Select Country'),
      trailing: const Icon(Icons.arrow_drop_down),
      onTap: () {
        showCountryPicker(
          context: context,
          onSelect: (Country country) {
            setState(() {
              _selectedCountry = country;
            });
          },
        );
      },
    );
  }

  Widget _buildPrivacySwitches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Privacy Settings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SwitchListTile(
          title: const Text('Public Profile'),
          value: _isProfilePublic,
          onChanged: (value) => setState(() => _isProfilePublic = value),
        ),
        SwitchListTile(
          title: const Text('Show Wishlist'),
          value: _showWishlist,
          onChanged: (value) => setState(() => _showWishlist = value),
        ),
        SwitchListTile(
          title: const Text('Show Rated Games'),
          value: _showRatedGames,
          onChanged: (value) => setState(() => _showRatedGames = value),
        ),
        SwitchListTile(
          title: const Text('Show Recommended Games'),
          value: _showRecommendedGames,
          onChanged: (value) => setState(() => _showRecommendedGames = value),
        ),
        SwitchListTile(
          title: const Text('Show Top Three Games'),
          value: _showTopThree,
          onChanged: (value) => setState(() => _showTopThree = value),
        ),
      ],
    );
  }
}
