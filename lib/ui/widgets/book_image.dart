import 'dart:io';
import 'package:flutter/material.dart';

Widget buildBookImage(String? imageUrl, String? imagePath, {double width = 120, double height = 180}) {
  Widget imageWidget;

  if (imageUrl != null && imageUrl.isNotEmpty) {
    imageWidget = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => emptyImagePlaceholder(width: width, height: height),
    );
  } else if (imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync()) {
    imageWidget = Image.file(
      File(imagePath),
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  } else {
    imageWidget = emptyImagePlaceholder(width: width, height: height);
  }

  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(12),
    ),
    child: imageWidget,
  );
}

Widget emptyImagePlaceholder({double width = 120, double height = 180}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade400),
      borderRadius: BorderRadius.circular(8),
      color: Colors.grey.shade100,
    ),
    child: Center(
      child: Icon(Icons.add_photo_alternate, size: width * 0.4, color: Colors.grey),
    ),
  );
}
