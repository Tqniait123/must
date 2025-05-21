// convert String to NetworkAsset
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

extension ToNetworkAsset on String {
  Widget toNetworkAsset({double height = 24, double width = 24}) {
    if (endsWith('.jpg') || endsWith('.jpeg') || endsWith('.png')) {
      return Image.network(
        this,
        height: height,
        width: width,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error); // Display a fallback icon
        },
      );
    } else if (endsWith('.svg')) {
      return SvgPicture.network(this, height: height, width: width);
    } else {
      return const Icon(Icons.broken_image, size: 12);
    }
  }

  Widget toImage({double height = 24, double width = 24}) {
    return Image.network(
      this,
      height: height,
      width: width,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.error); // Display a fallback icon
      },
    );
  }
}
