import 'package:flutter/material.dart';

class GamingButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const GamingButton({
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2563EB);
    const secondaryColor = Color(0xFF06B6D4);
    final isPrimaryColor = isPrimary ? primaryColor : secondaryColor;
    final int r = (isPrimaryColor.r * 255.0).round().clamp(0, 255).toInt();
    final int g = (isPrimaryColor.g * 255.0).round().clamp(0, 255).toInt();
    final int b = (isPrimaryColor.b * 255.0).round().clamp(0, 255).toInt();
    final shadowColor = Color.fromARGB(128, r, g, b);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: isPrimaryColor, width: 2),
          foregroundColor: isPrimaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
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

  const GamingTextField({
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.prefixIcon,
    this.maxLines = 1,
    super.key,
  });

  @override
  State<GamingTextField> createState() => _GamingTextFieldState();
}

class _GamingTextFieldState extends State<GamingTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      focusNode: _focusNode,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: Color(0xFF2563EB),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: Color(0xFF2563EB),
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: Color(0xFFBFDBFE),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class GamingGradientBackground extends StatelessWidget {
  final Widget child;

  const GamingGradientBackground({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF5F5F7),
            Color(0xFFE8E3FF),
            Color(0xFFF5F5F7),
          ],
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
        duration: Duration(seconds: 3 + index),
        vsync: this,
      )..repeat(),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
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
            left: (index * 100.0) % MediaQuery.of(context).size.width,
            top: (index * 50.0) % MediaQuery.of(context).size.height,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(parent: _controllers[index], curve: Curves.easeInOut),
              ),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.3, end: 0).animate(
                  CurvedAnimation(parent: _controllers[index], curve: Curves.easeOut),
                ),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2563EB),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xCC2563EB),
                        blurRadius: 8,
                      ),
                    ],
                  ),
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

  const GamingAppBar({
    required this.title,
    this.onThemeToggle,
    this.showThemeButton = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFFFFFF),
      elevation: 8,
      shadowColor: const Color(0x4D2563EB),
      title: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          color: Color(0xFF2563EB),
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
