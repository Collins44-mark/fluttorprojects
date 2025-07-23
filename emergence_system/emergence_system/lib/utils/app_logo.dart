import 'package:flutter/material.dart';

class AppLogo {
  static const String logoPath = 'assets/images/logo.png';

  static Widget build({
    double size = 32,
    Color? color,
    bool useIconFallback = true,
  }) {
    return Image.asset(
      logoPath,
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) {
        if (useIconFallback) {
          return Icon(Icons.shield, size: size, color: color ?? Colors.white);
        }
        return SizedBox(width: size, height: size);
      },
    );
  }

  static Widget buildWithBackground({
    double size = 80,
    Color backgroundColor = Colors.deepOrange,
    Color? iconColor,
    bool useIconFallback = true,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Center(
        child: Image.asset(
          logoPath,
          width: size * 0.6,
          height: size * 0.6,
          errorBuilder: (context, error, stackTrace) {
            if (useIconFallback) {
              return Icon(
                Icons.shield,
                color: iconColor ?? Colors.white,
                size: size * 0.6,
              );
            }
            return SizedBox(width: size * 0.6, height: size * 0.6);
          },
        ),
      ),
    );
  }
}
