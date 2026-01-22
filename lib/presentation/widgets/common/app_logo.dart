import 'package:flutter/material.dart';

/// Reusable app logo widget
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final String? text;

  const AppLogo({
    super.key,
    this.size = 80,
    this.showText = true,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo image with fallback to icon
        SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            'assets/images/app_logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to icon with gradient background if image not found
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.local_taxi,
                  size: size * 0.6,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.2),
          Text(
            text ?? 'Vezunchik',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Small logo for app bars
class AppLogoSmall extends StatelessWidget {
  final double size;

  const AppLogoSmall({
    super.key,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/app_logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to icon with gradient background if image not found
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Icon(
              Icons.local_taxi,
              size: size * 0.6,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
