// =======================================================
// APP SKELETON
// -------------------------------------------------------
// Skeleton genérico reutilizável com animação pulse.
//
// Suporta:
// - largura customizada
// - altura customizada
// - borda arredondada
// - formato circular ou retangular
// - margem externa
//
// Ajustes:
// - usa AppColors para overlays
// - remove withOpacity deprecated
// - organiza lógica em helpers
// =======================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AppSkeleton extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final BoxShape shape;
  final EdgeInsetsGeometry? margin;

  const AppSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 12,
    this.shape = BoxShape.rectangle,
    this.margin,
  });

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _scaleAnimation;

  // ===================================================
  // INIT STATE
  // ---------------------------------------------------
  // Inicializa as animações de opacity e scale usadas
  // para criar o efeito de pulse.
  // ===================================================
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(
      begin: 0.35,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.985,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  // ===================================================
  // DISPOSE
  // ---------------------------------------------------
  // Libera o AnimationController para evitar vazamento
  // de recursos quando o widget sair da árvore.
  // ===================================================
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ===================================================
  // BUILD
  // ---------------------------------------------------
  // Renderiza o skeleton animado.
  // ===================================================
  @override
  Widget build(BuildContext context) {
    final skeletonChild = _buildSkeletonChild(context);

    return AnimatedBuilder(
      animation: _controller,
      child: skeletonChild,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
    );
  }

  // ===================================================
  // BUILD SKELETON CHILD
  // ---------------------------------------------------
  // Cria o container base do skeleton.
  // ===================================================
  Widget _buildSkeletonChild(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: _baseColor(context),
        shape: widget.shape,
        borderRadius: _borderRadius(),
      ),
    );
  }

  // ===================================================
  // BASE COLOR
  // ---------------------------------------------------
  // Define a cor base do skeleton conforme o tema atual.
  // ===================================================
  Color _baseColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return AppColors.whiteOverlay(0.12);
    }

    return AppColors.blackOverlay(0.08);
  }

  // ===================================================
  // BORDER RADIUS
  // ---------------------------------------------------
  // Retorna borda arredondada apenas quando o skeleton
  // não for circular.
  // ===================================================
  BorderRadius? _borderRadius() {
    if (widget.shape == BoxShape.circle) {
      return null;
    }

    return BorderRadius.circular(widget.borderRadius);
  }
}
