import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/data/models/user_model.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_event.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class EditProfilePage extends StatefulWidget {

  const EditProfilePage({required this.user, super.key});
  static const String routeName = 'edit_profile';
  final User user;

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
                  upsert: true,),
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
          .from('profiles')
          .update(updates)
          .eq('id', widget.user.id);

      // 4. Fetch updated user data
      final updatedData = await supabaseClient
          .from('profiles')
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        actions: [
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.icon(
                icon: const Icon(Icons.check, size: 20),
                label: const Text('Save'),
                onPressed: _saveProfile,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 32),
                  _buildInfoSection(colorScheme),
                  const SizedBox(height: 16),
                  _buildPrivacySection(colorScheme),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (_isLoading)
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Saving profile...',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    ImageProvider? backgroundImage;

    if (_selectedImageFile != null) {
      backgroundImage = FileImage(_selectedImageFile!);
    } else if (widget.user.hasAvatar) {
      backgroundImage = CachedNetworkImageProvider(widget.user.avatarUrl!);
    }

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: colorScheme.primaryContainer,
                  backgroundImage: backgroundImage,
                  child: backgroundImage == null
                      ? Text(
                          widget.user.username[0].toUpperCase(),
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Material(
                  elevation: 4,
                  shape: const CircleBorder(),
                  color: colorScheme.primaryContainer,
                  child: InkWell(
                    onTap: _pickImage,
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: colorScheme.onPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.user.username,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the camera icon to change your avatar',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Profile Information',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell others about yourself...',
                prefixIcon: const Icon(Icons.edit_note),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              maxLines: 4,
              maxLength: 150,
            ),
            const SizedBox(height: 16),
            InkWell(
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
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.public,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Country',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedCountry?.name ??
                                _initialCountryName ??
                                'Select Country',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
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

  Widget _buildPrivacySection(ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.privacy_tip_outlined,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Privacy Settings',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Control what others can see on your profile',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            _buildPrivacySwitch(
              icon: Icons.public,
              title: 'Public Profile',
              subtitle: 'Allow others to view your profile',
              value: _isProfilePublic,
              onChanged: (value) => setState(() => _isProfilePublic = value),
              colorScheme: colorScheme,
            ),
            const Divider(height: 24),
            _buildPrivacySwitch(
              icon: Icons.favorite_border,
              title: 'Show Wishlist',
              subtitle: 'Display games you want to play',
              value: _showWishlist,
              onChanged: (value) => setState(() => _showWishlist = value),
              colorScheme: colorScheme,
            ),
            const Divider(height: 24),
            _buildPrivacySwitch(
              icon: Icons.star_border,
              title: 'Show Rated Games',
              subtitle: 'Display games you have rated',
              value: _showRatedGames,
              onChanged: (value) => setState(() => _showRatedGames = value),
              colorScheme: colorScheme,
            ),
            const Divider(height: 24),
            _buildPrivacySwitch(
              icon: Icons.recommend_outlined,
              title: 'Show Recommended Games',
              subtitle: 'Display your game recommendations',
              value: _showRecommendedGames,
              onChanged: (value) =>
                  setState(() => _showRecommendedGames = value),
              colorScheme: colorScheme,
            ),
            const Divider(height: 24),
            _buildPrivacySwitch(
              icon: Icons.emoji_events_outlined,
              title: 'Show Top Three Games',
              subtitle: 'Display your favorite games',
              value: _showTopThree,
              onChanged: (value) => setState(() => _showTopThree = value),
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ColorScheme colorScheme,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
