// core/widgets/cached_image_widget.dart
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/presentation/widgets/custom_shimmer.dart';

/// A network image that decodes at the size it is drawn at.
///
/// `width` and `height` are *layout* constraints — they say how large the
/// picture appears, not how large the bitmap in memory is. Without a decode
/// size, a cover fetched at `t_1080p` (811×1080) is decoded in full: 3.5 MB of
/// RAM for a card drawn at 160×240. Flutter's `ImageCache` holds 100 MB, so a
/// grid of covers evicts and re-decodes on every change of scroll direction.
///
/// The decode size is derived from the box the image actually occupies, times
/// the device pixel ratio, so the bitmap is exactly as detailed as the screen
/// can show and no more.
class CachedImageWidget extends StatelessWidget {
  const CachedImageWidget({
    required this.imageUrl,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  /// Decoding beyond this wastes memory on any phone screen: it is above the
  /// largest source IGDB serves, so a larger target would only upscale.
  static const int _maxDecodeExtent = 1920;

  @override
  Widget build(BuildContext context) {
    // Validate and clean image URL
    final cleanUrl = _cleanImageUrl(imageUrl);

    if (cleanUrl.isEmpty) {
      return _buildErrorWidget(context);
    }

    // LayoutBuilder rather than the width/height fields alone: the widest call
    // site in the app (the cover in every game card) passes neither and fills
    // its parent instead, so the size is only knowable at layout time.
    return LayoutBuilder(
      builder: (context, constraints) {
        final ratio = MediaQuery.devicePixelRatioOf(context);
        final (decodeWidth, decodeHeight) = _decodeTarget(constraints, ratio);

        final image = CachedNetworkImage(
          imageUrl: cleanUrl,
          width: width,
          height: height,
          fit: fit,
          memCacheWidth: decodeWidth,
          memCacheHeight: decodeHeight,
          placeholder: (context, url) =>
              placeholder ??
              CustomShimmer(
                child: Container(
                  width: width,
                  height: height,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
          errorWidget: (context, url, error) {
            return errorWidget ?? _buildErrorWidget(context);
          },
        );

        if (borderRadius != null) {
          return ClipRRect(
            borderRadius: borderRadius!,
            child: image,
          );
        }

        return image;
      },
    );
  }

  /// The decode target in physical pixels, as (width, height).
  ///
  /// Exactly one of the two is ever non-null. Setting both makes `ResizeImage`
  /// scale to that exact box, which distorts any image whose aspect ratio
  /// differs — and `BoxFit` cannot undo a bitmap that is already wrong. With
  /// one axis, the other follows the source.
  ///
  /// Which axis: the one the caller named, if they named exactly one. That is
  /// the case that carries intent — a logo given `height: 120` with
  /// `BoxFit.contain` is 120 tall whatever the row around it is wide, and
  /// taking the row's width would decode several times too much.
  ///
  /// Otherwise the **longer** side of the box. Under `BoxFit.cover` the image
  /// is scaled until it fills, so constraining the short side can still leave
  /// the long one short and the picture is then upscaled — a card box of
  /// 160×240 given a 3:4 cover decoded to 480 wide comes out 640 tall against
  /// 720 needed, and the difference is visible as softness. The long side is
  /// sufficient for every aspect ratio the app actually shows.
  (int?, int?) _decodeTarget(BoxConstraints constraints, double ratio) {
    final explicitWidth = _usable(width);
    final explicitHeight = _usable(height);

    if (explicitWidth != null && explicitHeight == null) {
      return (_physical(explicitWidth, ratio), null);
    }
    if (explicitHeight != null && explicitWidth == null) {
      return (null, _physical(explicitHeight, ratio));
    }

    final w = explicitWidth ?? _usable(constraints.maxWidth);
    final h = explicitHeight ?? _usable(constraints.maxHeight);

    if (w != null && h != null) {
      return w >= h ? (_physical(w, ratio), null) : (null, _physical(h, ratio));
    }
    if (w != null) return (_physical(w, ratio), null);
    if (h != null) return (null, _physical(h, ratio));

    // Neither axis is knowable — an unbounded box that has not been laid out.
    // Decoding at the source size is the old behaviour and the only safe one.
    return (null, null);
  }

  /// Unbounded and zero-sized extents both occur in practice: a sliver before
  /// layout, an image in a shrink-wrapping row, `width: double.infinity`. A
  /// decode target of 0 or infinity throws in the codec.
  static double? _usable(double? logical) =>
      (logical == null || !logical.isFinite || logical <= 0) ? null : logical;

  static int _physical(double logical, double ratio) =>
      math.min((logical * ratio).ceil(), _maxDecodeExtent);

  String _cleanImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    // Ensure URL starts with https://
    if (url.startsWith('//')) {
      return 'https:$url';
    } else if (!url.startsWith('http')) {
      return 'https://$url';
    }

    return url;
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: 40,
      ),
    );
  }
}
