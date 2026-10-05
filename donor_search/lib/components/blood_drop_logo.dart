import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class BloodDropLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool lightTheme;

  const BloodDropLogo({
    super.key,
    this.size = 80,
    this.showText = false,
    this.lightTheme = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            'assets/images/app_logo_transparent.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => _buildVectorFallback(),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 14),
          RichText(
            text: TextSpan(
              text: 'Blood',
              style: TextStyle(
                fontSize: size * 0.32,
                fontWeight: FontWeight.w800,
                color: lightTheme ? Colors.white : AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
              children: [
                TextSpan(
                  text: 'Connect',
                  style: TextStyle(
                    fontSize: size * 0.32,
                    fontWeight: FontWeight.w800,
                    color: lightTheme ? AppColors.primaryLight : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Save Lives • Connect Donors',
            style: TextStyle(
              fontSize: size * 0.15,
              fontWeight: FontWeight.w500,
              color: lightTheme ? Colors.white70 : AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVectorFallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFFF5252), AppColors.primaryDark],
          center: Alignment(-0.2, -0.2),
          radius: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.water_drop,
              size: size * 0.58,
              color: Colors.white,
            ),
            Positioned(
              bottom: size * 0.22,
              child: Icon(
                Icons.favorite,
                size: size * 0.22,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

