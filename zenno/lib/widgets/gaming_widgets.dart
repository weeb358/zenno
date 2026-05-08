import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Steam dark palette
const kSteamBg = Color(0xFF171a21);
const kSteamDark = Color(0xFF1b2838);
const kSteamMed = Color(0xFF2a475e);
const kSteamAccent = Color(0xFF66c0f4);
const kSteamText = Color(0xFFc7d5e0);
const kSteamSubtext = Color(0xFF8f98a0);
const kSteamGreen = Color(0xFFa3cf6f);
const kSteamRed = Color(0xFFff6b6b);

class GamingButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final Color? color;

  const GamingButton({
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final btnColor = color ?? (isPrimary ? kSteamAccent : kSteamGreen);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          colors: [kSteamDark, kSteamMed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: btnColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: btnColor.withValues(alpha: 0.35),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Center(
              child: Text(
                label.toUpperCase(),
                style: GoogleFonts.rajdhani(
                  color: btnColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GamingTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final IconData? prefixIcon;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const GamingTextField({
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.prefixIcon,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
    super.key,
  });

  @override
  State<GamingTextField> createState() => _GamingTextFieldState();
}

class _GamingTextFieldState extends State<GamingTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 14),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: kSteamAccent, size: 20)
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: kSteamSubtext,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
        filled: true,
        fillColor: kSteamDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: kSteamMed, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: kSteamAccent, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: kSteamMed, width: 1.5),
        ),
      ),
    );
  }
}

class GamingGradientBackground extends StatelessWidget {
  final Widget child;

  const GamingGradientBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kSteamBg, kSteamDark, kSteamBg],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}

class ParticleWidget extends StatefulWidget {
  final int particleCount;
  final Widget child;

  const ParticleWidget({
    required this.child,
    this.particleCount = 5,
    super.key,
  });

  @override
  State<ParticleWidget> createState() => _ParticleWidgetState();
}

class _ParticleWidgetState extends State<ParticleWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.particleCount,
      (index) => AnimationController(
        duration: Duration(seconds: 4 + index),
        vsync: this,
      )..repeat(),
    );
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ...List.generate(
          widget.particleCount,
          (index) => Positioned(
            left: (index * 73.0 + 40) % MediaQuery.of(context).size.width,
            top: (index * 120.0 + 60) % MediaQuery.of(context).size.height,
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 0.4).animate(
                CurvedAnimation(parent: _controllers[index], curve: Curves.easeInOut),
              ),
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index % 3 == 0 ? kSteamAccent : kSteamMed,
                  boxShadow: [
                    BoxShadow(
                      color: kSteamAccent.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class GamingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onThemeToggle;
  final bool showThemeButton;
  final List<Widget>? actions;
  final Widget? leading;

  const GamingAppBar({
    required this.title,
    this.onThemeToggle,
    this.showThemeButton = false,
    this.actions,
    this.leading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: kSteamDark,
      elevation: 0,
      leading: leading,
      automaticallyImplyLeading: leading != null,
      title: Text(
        title.toUpperCase(),
        style: GoogleFonts.rajdhani(
          fontWeight: FontWeight.w700,
          letterSpacing: 3,
          color: kSteamAccent,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, kSteamAccent, Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(57);
}

// Reusable Steam-style card container
class SteamCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final VoidCallback? onTap;

  const SteamCard({
    required this.child,
    this.padding,
    this.borderColor,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kSteamDark,
          border: Border.all(color: borderColor ?? kSteamMed, width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: child,
      ),
    );
  }
}

// Steam-style section header
class SteamSectionHeader extends StatelessWidget {
  final String title;

  const SteamSectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: kSteamAccent,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [BoxShadow(color: kSteamAccent.withValues(alpha: 0.5), blurRadius: 6)],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.rajdhani(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: kSteamText,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
