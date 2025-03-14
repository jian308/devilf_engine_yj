import 'dart:math';
import 'package:devilf_engine_yj/core/df_offset.dart';
import 'package:devilf_engine_yj/core/df_position.dart';
import 'package:devilf_engine_yj/core/df_rect.dart';
import 'package:devilf_engine_yj/core/df_size.dart';
import 'package:devilf_engine_yj/game/df_assets_loader.dart';
import 'package:devilf_engine_yj/sprite/df_sprite.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;

/// 图片精灵类
class DFImageSprite extends DFSprite {
  /// 精灵图片
  ui.Image image;

  /// 截取图片区域
  DFRect rect;

  /// 坐标偏移
  DFOffset offset;

  /// 是否旋转
  bool rotated;

  /// x轴镜像
  bool flippedX;

  /// 混合模式
  BlendMode blendMode;

  /// 颜色
  Color color;

  /// 创建图片精灵
  DFImageSprite(
    this.image, {
    DFSize size = const DFSize(64, 64),
    required this.rect,
    this.offset = const DFOffset(0, 0),
    this.color = const Color(0xFFFFFFFF),
    this.rotated = false,
    this.flippedX = false,
    this.blendMode = BlendMode.srcOver,
  }) : super(position: DFPosition(0, 0), size: size);

  /// 加载图片资源
  static Future<DFImageSprite> load(String src) async {
    ui.Image image = await DFAssetsLoader.loadImage(src);
    return DFImageSprite(image, rect: DFRect(0, 0, image.width.toDouble(), image.height.toDouble()));
  }

  /// 精灵渲染
  /// 代码没几行,坐标计算有点复杂
  @override
  void render(Canvas canvas) {
    /// 画布暂存
    canvas.save();

    /// 目标位置
    Rect dstRect;

    if (rotated) {
      /// 将子精灵转换为相对坐标
      if (parent == null) {
        canvas.translate(position.y, position.x);
      } else {
        canvas.translate(position.y - parent!.size.height / 2, position.x - parent!.size.width / 2);
      }

      /// 针对json中的图像旋转
      canvas.rotate(-90 * pi / 180); //弧度

      dstRect = Rect.fromCenter(center: Offset(0, 0), width: rect.width * scale, height: rect.height * scale);
    } else {
      /// 将子精灵转换为相对坐标
      if (parent == null) {
        canvas.translate(position.x, position.y);
      } else {
        canvas.translate(position.x - parent!.size.width / 2, position.y - parent!.size.height / 2);
      }
      canvas.rotate(this.angle * pi / 180); //弧度

      dstRect =
          Rect.fromCenter(center: Offset(0, -rect.height / 2), width: rect.width * scale, height: rect.height * scale);
    }

    /// 水平镜像
    if (flippedX) {
      if (rotated) {
        canvas.scale(1, -1); //左右镜像翻转
      } else {
        canvas.scale(-1, 1); //左右镜像翻转
      }
    }

    /// 目标绘制位置
    if (rotated) {
      dstRect = Rect.fromCenter(center: Offset(offset.dx, offset.dy), width: rect.width, height: rect.height);
    } else {
      dstRect = Rect.fromCenter(center: Offset(offset.dx, -offset.dy), width: rect.width, height: rect.height);
    }

    /// 处理缩放
    Rect outputRect = Rect.fromCenter(
        center: Offset(dstRect.center.dx * scale, dstRect.center.dy * scale),
        width: dstRect.width * scale,
        height: dstRect.height * scale);

    /// 绘制图像
    Paint paintImage = Paint()..color = color;
    paintImage.blendMode = this.blendMode;
    canvas.drawImageRect(this.image, rect.toRect(), outputRect, paintImage);

    /// 画布恢复
    canvas.restore();
  }
}
