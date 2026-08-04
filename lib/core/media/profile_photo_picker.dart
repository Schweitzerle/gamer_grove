import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

/// Picks the one image this app ever asks for: a profile picture.
///
/// Wrapped rather than called directly because of a default that costs an app
/// its release. `image_picker_android` ships the Android photo picker but has
/// **`useAndroidPhotoPicker = false`**, so out of the box it still fires the
/// legacy gallery intent — which needs `READ_MEDIA_IMAGES`, the broad
/// permission to read every photo on the device.
///
/// Play refuses that permission when a system picker would do, and here it
/// plainly would: the app wants one picture the user chose, not a library. The
/// picker hands back exactly that, with no permission at all.
///
/// The plugin's own comment says the default "is subject to change", which is
/// the other reason this is set in one place instead of at each call site.
abstract final class ProfilePhotoPicker {
  static bool _configured = false;

  static void _useSystemPicker() {
    if (_configured) return;
    _configured = true;
    final platform = ImagePickerPlatform.instance;
    if (platform is ImagePickerAndroid) {
      platform.useAndroidPhotoPicker = true;
    }
  }

  /// Returns the chosen image, or null when the picker was dismissed.
  static Future<XFile?> pick() async {
    _useSystemPicker();
    return ImagePicker().pickImage(source: ImageSource.gallery);
  }
}
