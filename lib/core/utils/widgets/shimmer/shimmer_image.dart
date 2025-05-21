import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final BoxFit? fit;
  final double radius;

  const ShimmerImage({
    Key? key,
    required this.imageUrl,
    this.height = 100,
    this.width = 100,
    this.fit,
    this.radius = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: width,
        fit: fit,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
        fadeInDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
