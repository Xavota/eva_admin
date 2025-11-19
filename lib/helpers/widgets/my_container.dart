import 'package:blix_essentials/blix_essentials.dart';
import 'package:flutter/material.dart';
import 'package:medicare/helpers/theme/app_themes.dart';
import 'package:medicare/helpers/widgets/my_constant.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';

enum TooltipAnchor { center, mouse }

class MyContainer extends StatefulWidget {
  final Widget? child;
  final BorderRadius? borderRadius;
  final double? borderRadiusAll, paddingAll, marginAll;
  final EdgeInsetsGeometry? padding, margin;
  final Color? color;
  final Color? borderColor;
  final bool bordered;
  final Border? border;
  final Clip? clipBehavior;
  final BoxShape shape;
  final double? width, height;
  final AlignmentGeometry? alignment;
  final GestureTapCallback? onTap;
  final Color? splashColor;
  final bool enableBorderRadius;

  final bool enableShadow;
  final Color? shadowColor;
  final Offset? shadowOffset;
  final double? shadowBlurRadius;
  final double? shadowSpreadRadius;
  final BlurStyle? shadowBlurStyle;

  final Widget? tooltip;
  final TooltipAnchor tooltipAnchor;
  final Alignment tooltipAlignment;
  final Offset tooltipOffset;

  const MyContainer(
      {super.key,
        this.child,
        this.borderRadius,
        this.padding,
        this.borderRadiusAll,
        this.paddingAll,
        this.border,
        this.bordered = false,
        this.clipBehavior,
        this.color,
        this.shape = BoxShape.rectangle,
        this.width,
        this.height,
        this.alignment,
        this.enableBorderRadius = true,
        this.onTap,
        this.marginAll,
        this.margin,
        this.splashColor,
        this.borderColor,

        this.enableShadow = false,
        this.shadowColor,
        this.shadowOffset,
        this.shadowBlurRadius,
        this.shadowSpreadRadius,
        this.shadowBlurStyle,

        this.tooltip,
        this.tooltipAnchor = TooltipAnchor.center,
        this.tooltipAlignment = Alignment.bottomRight,
        this.tooltipOffset = const Offset(0, 0),
      });

  const MyContainer.shadow(
      {super.key,
        this.child,
        this.borderRadius,
        this.padding,
        this.borderRadiusAll,
        this.paddingAll,
        this.border,
        this.bordered = false,
        this.clipBehavior,
        this.color,
        this.shape = BoxShape.rectangle,
        this.width,
        this.height,
        this.alignment,
        this.enableBorderRadius = true,
        this.onTap,
        this.marginAll,
        this.margin,
        this.splashColor,
        this.borderColor,

        this.shadowColor = Colors.black45,
        this.shadowOffset = const Offset(2.0, 2.0),
        this.shadowBlurRadius = 5.0,
        this.shadowSpreadRadius,
        this.shadowBlurStyle,

        this.tooltip,
        this.tooltipAnchor = TooltipAnchor.center,
        this.tooltipAlignment = Alignment.bottomRight,
        this.tooltipOffset = const Offset(0, 0),
      })
      : enableShadow = true;

  const MyContainer.transparent(
      {super.key,
        this.child,
        this.borderRadius,
        this.padding,
        this.borderRadiusAll,
        this.paddingAll,
        this.border,
        this.bordered = false,
        this.clipBehavior,
        this.color = Colors.transparent,
        this.shape = BoxShape.rectangle,
        this.width,
        this.height,
        this.alignment,
        this.enableBorderRadius = true,
        this.onTap,
        this.marginAll,
        this.margin,
        this.splashColor,
        this.borderColor,

        this.enableShadow = false,
        this.shadowColor,
        this.shadowOffset,
        this.shadowBlurRadius,
        this.shadowSpreadRadius,
        this.shadowBlurStyle,

        this.tooltip,
        this.tooltipAnchor = TooltipAnchor.center,
        this.tooltipAlignment = Alignment.bottomRight,
        this.tooltipOffset = const Offset(0, 0),
      });

  const MyContainer.none(
      {super.key,
        this.child,
        this.borderRadius,
        this.padding,
        this.borderRadiusAll = 0,
        this.paddingAll = 0,
        this.border,
        this.bordered = false,
        this.clipBehavior,
        this.enableBorderRadius = true,
        this.color,
        this.shape = BoxShape.rectangle,
        this.width,
        this.height,
        this.alignment,
        this.onTap,
        this.marginAll,
        this.margin,
        this.splashColor,
        this.borderColor,

        this.enableShadow = false,
        this.shadowColor,
        this.shadowOffset,
        this.shadowBlurRadius,
        this.shadowSpreadRadius,
        this.shadowBlurStyle,

        this.tooltip,
        this.tooltipAnchor = TooltipAnchor.center,
        this.tooltipAlignment = Alignment.bottomRight,
        this.tooltipOffset = const Offset(0, 0),
      });

  const MyContainer.bordered(
      {super.key,
        this.child,
        this.borderRadius,
        this.padding,
        this.borderRadiusAll,
        this.paddingAll,
        this.border,
        this.bordered = true,
        this.enableBorderRadius = true,
        this.clipBehavior,
        this.color,
        this.shape = BoxShape.rectangle,
        this.width,
        this.height,
        this.alignment,
        this.onTap,
        this.marginAll,
        this.margin,
        this.splashColor,
        this.borderColor,

        this.enableShadow = false,
        this.shadowColor,
        this.shadowOffset,
        this.shadowBlurRadius,
        this.shadowSpreadRadius,
        this.shadowBlurStyle,

        this.tooltip,
        this.tooltipAnchor = TooltipAnchor.center,
        this.tooltipAlignment = Alignment.bottomRight,
        this.tooltipOffset = const Offset(0, 0),
      });

  const MyContainer.roundBordered(
      {super.key,
        this.child,
        this.borderRadius,
        this.padding,
        this.borderRadiusAll,
        this.enableBorderRadius = true,
        this.paddingAll,
        this.border,
        this.bordered = true,
        this.clipBehavior,
        this.color,
        this.shape = BoxShape.circle,
        this.width,
        this.height,
        this.alignment,
        this.onTap,
        this.marginAll,
        this.margin,
        this.splashColor,
        this.borderColor,

        this.enableShadow = false,
        this.shadowColor,
        this.shadowOffset,
        this.shadowBlurRadius,
        this.shadowSpreadRadius,
        this.shadowBlurStyle,

        this.tooltip,
        this.tooltipAnchor = TooltipAnchor.center,
        this.tooltipAlignment = Alignment.bottomRight,
        this.tooltipOffset = const Offset(0, 0),
      });

  const MyContainer.rounded(
      {super.key,
        this.child,
        this.borderRadius,
        this.padding,
        this.borderRadiusAll,
        this.enableBorderRadius = true,
        this.paddingAll,
        this.border,
        this.bordered = false,
        this.clipBehavior = Clip.antiAliasWithSaveLayer,
        this.color,
        this.shape = BoxShape.circle,
        this.width,
        this.height,
        this.alignment,
        this.onTap,
        this.marginAll,
        this.margin,
        this.splashColor,
        this.borderColor,

        this.enableShadow = false,
        this.shadowColor,
        this.shadowOffset,
        this.shadowBlurRadius,
        this.shadowSpreadRadius,
        this.shadowBlurStyle,

        this.tooltip,
        this.tooltipAnchor = TooltipAnchor.center,
        this.tooltipAlignment = Alignment.bottomRight,
        this.tooltipOffset = const Offset(0, 0),
      });

  @override
  State<MyContainer> createState() => _MyContainerState();
}

class _MyContainerState extends State<MyContainer> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Offset _lastMouseGlobal = Offset.zero;

  @override
  void dispose() {
    _removeTooltip();
    super.dispose();
  }

  void _showTooltip() {
    if (widget.tooltip == null || _overlayEntry != null) return;

    if (widget.tooltipAnchor == TooltipAnchor.center) {
      // Follows the container and stays centered.
      _overlayEntry = OverlayEntry(
        builder: (context) {
          return CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.topLeft,
            followerAnchor: widget.tooltipAlignment,
            offset: widget.tooltipOffset,
            child: IgnorePointer(
              ignoring: true,
              child: _TooltipSurface(alignment: widget.tooltipAlignment, child: widget.tooltip!,),
            ),
          );
        },
      );
    } else {
      // Positions at the mouse; we’ll rebuild on hover to move it.
      _overlayEntry = OverlayEntry(
        builder: (context) {
          final overlayBox =
          Overlay.of(context).context.findRenderObject() as RenderBox;
          final pos = overlayBox.globalToLocal(_lastMouseGlobal) + widget.tooltipOffset;
          return Stack(children: [
            Positioned(
              left: pos.dx,
              top: pos.dy,
              child: _TooltipSurface(alignment: widget.tooltipAlignment, child: widget.tooltip!),
            ),
          ]);
        },
      );
    }

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _updateTooltipPosition(Offset globalPos) {
    _lastMouseGlobal = globalPos;
    _overlayEntry?.markNeedsBuild();
  }

  void _removeTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    Widget base = Container(
      width: widget.width,
      height: widget.height,
      alignment: widget.alignment,
      margin: widget.margin ?? MySpacing.all(widget.marginAll ?? 0),
      decoration: BoxDecoration(
        color: widget.color ?? theme.cardTheme.color,
        shape: widget.shape,
        borderRadius: widget.enableBorderRadius
            ? (widget.shape == BoxShape.rectangle
            ? widget.borderRadius ??
            BorderRadius.all(Radius.circular(widget.borderRadiusAll ??
                MyConstant.constant.containerRadius))
            : null)
            : null,
        border: widget.bordered
            ? widget.border ??
            Border.all(color: widget.borderColor ?? theme.dividerColor, width: 1)
            : null,
        boxShadow: widget.enableShadow && widget.shadowColor != null ? [
          BoxShadow(
            color: widget.shadowColor!, offset: widget.shadowOffset?? Offset.zero,
            blurRadius: widget.shadowBlurRadius?? 0.0,
            spreadRadius: widget.shadowSpreadRadius?? 0.0,
            blurStyle: widget.shadowBlurStyle?? BlurStyle.normal,
          )
        ] : null,
      ),
      padding: widget.padding ?? MySpacing.all(widget.paddingAll ?? 16),
      clipBehavior: widget.clipBehavior ?? Clip.none,
      child: widget.child,
    );

    if (widget.onTap != null) {
      base = InkWell(
        borderRadius: widget.shape != BoxShape.circle
            ? widget.borderRadius ??
                BorderRadius.all(Radius.circular(
                    widget.borderRadiusAll ?? MyConstant.constant.containerRadius))
            : null,
        onTap: widget.onTap,
        splashColor: widget.splashColor ?? Colors.transparent,
        highlightColor: widget.splashColor ?? Colors.transparent,
        child: base,
      );
    }

    if (widget.tooltip != null) {
      base = MouseRegion(
        onEnter: (_) => _showTooltip(),
        onHover: (e) {
          if (widget.tooltipAnchor == TooltipAnchor.mouse) {
            _updateTooltipPosition(e.position);
            if (_overlayEntry == null) _showTooltip();
          }
        },
        onExit: (_) => _removeTooltip(),
        child: CompositedTransformTarget(
          link: _layerLink,
          child: base,
        ),
      );
    }

    return base;
  }
}


/// A simple material “bubble” so your tooltip looks nice and floats above.
class _TooltipSurface extends StatelessWidget {
  final Widget child;
  final Alignment alignment;
  const _TooltipSurface({required this.child, required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: child,
    );
    /*Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: alignment,
        child: child,
      ),
    );*/
    /*return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: AlignmentGeometry.bottomRight,
            child: child,
          ),
        ),
      ),
    );*/
  }
}