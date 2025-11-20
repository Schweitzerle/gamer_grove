// core/widgets/cached_image_widget.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../presentation/widgets/custom_shimmer.dart';

class CachedImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Validate and clean image URL
    final cleanUrl = _cleanImageUrl(imageUrl);

    if (cleanUrl.isEmpty) {
      return _buildErrorWidget(context);
    }

    final image = CachedNetworkImage(
      imageUrl: cleanUrl,
      width: width,
      height: height,
      fit: fit,
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
  }

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