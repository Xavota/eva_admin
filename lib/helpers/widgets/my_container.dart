import 'package:flutter/material.dart';
import 'package:medicare/helpers/theme/app_themes.dart';
import 'package:medicare/helpers/widgets/my_constant.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';

class MyContainer extends StatelessWidget {
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
      });

  @override
  Widget build(BuildContext context) {
    Widget base = Container(
      width: width,
      height: height,
      alignment: alignment,
      margin: margin ?? MySpacing.all(marginAll ?? 0),
      decoration: BoxDecoration(
        color: color ?? theme.cardTheme.color,
        shape: shape,
        borderRadius: enableBorderRadius
            ? (shape == BoxShape.rectangle
            ? borderRadius ??
            BorderRadius.all(Radius.circular(borderRadiusAll ??
                MyConstant.constant.containerRadius))
            : null)
            : null,
        border: bordered
            ? border ??
            Border.all(color: borderColor ?? theme.dividerColor, width: 1)
            : null,
        boxShadow: enableShadow && shadowColor != null ? [
          BoxShadow(
            color: shadowColor!, offset: shadowOffset?? Offset.zero,
            blurRadius: shadowBlurRadius?? 0.0,
            spreadRadius: shadowSpreadRadius?? 0.0,
            blurStyle: shadowBlurStyle?? BlurStyle.normal,
          )
        ] : null,
      ),
      padding: padding ?? MySpacing.all(paddingAll ?? 16),
      clipBehavior: clipBehavior ?? Clip.none,
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        borderRadius: shape != BoxShape.circle
            ? borderRadius ??
                BorderRadius.all(Radius.circular(
                    borderRadiusAll ?? MyConstant.constant.containerRadius))
            : null,
        onTap: onTap,
        splashColor: splashColor ?? Colors.transparent,
        highlightColor: splashColor ?? Colors.transparent,
        child: base,
      );
    } else {
      return base;
    }
  }
}
