import 'package:flutter/material.dart';

class AdaptiveLogoWidget extends StatelessWidget {
  final double height;
  final bool forceWhiteBackground;

  const AdaptiveLogoWidget({
    Key? key,
    this.height = 60,
    this.forceWhiteBackground = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Ak chceš vynútiť biele pozadie (napr. v SlovenskoSk banner)
    if (forceWhiteBackground) {
      return _buildLogoWithWhiteBackground();
    }

    // Adaptívne logo podľa témy
    return _buildAdaptiveLogo(isDark);
  }

  // ✅ Varianta 1: Logo s bielym pozadím (pre tmavý režim)
  Widget _buildLogoWithWhiteBackground() {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.asset(
        'assets/images/logo.png', // Originálne logo (čierny text)
        height: height - 16,
        fit: BoxFit.contain,
      ),
    );
  }

  // ✅ Varianta 2: Adaptívne logo (mení farbu textu)
  Widget _buildAdaptiveLogo(bool isDark) {
    return ColorFiltered(
      colorFilter: isDark
          ? const ColorFilter.mode(
        Colors.white,
        BlendMode.srcIn, // Zmení čierny text na biely
      )
          : const ColorFilter.mode(
        Colors.transparent,
        BlendMode.dst, // Nechá originálne farby
      ),
      child: Image.asset(
        'assets/images/logo.png',
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}

