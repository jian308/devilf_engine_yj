import 'dart:collection';
import 'dart:ui';
import 'package:devilf_engine_yj/game/df_animation.dart';
import 'package:devilf_engine_yj/game/df_assets_loader.dart';
import 'package:devilf_engine_yj/core/df_offset.dart';
import 'package:devilf_engine_yj/core/df_rect.dart';
import 'package:devilf_engine_yj/sprite/df_sprite.dart';
import 'package:devilf_engine_yj/core/df_position.dart';
import 'package:devilf_engine_yj/core/df_size.dart';
import 'dart:ui' as ui;
import 'df_image_sprite.dart';

/// 动画精灵
class DFAnimationSprite extends DFSprite {
  /// 这个动画的全部帧
  Map<String, List<DFImageSprite>> frames = HashMap<String, List<DFImageSprite>>();

  /// 绑定动画
  List<DFAnimationSprite> bindSprites = [];

  /// 当前是的Index
  int currentIndex = 0;

  /// 是否循环动画
  bool loop = true;

  /// 帧速率
  int stepTime;

  /// 当前动画类型
  String currentAnimation = DFAction.NONE + DFDirection.NONE;

  /// x轴镜像
  bool currentAnimationFlippedX = false;

  /// 颜色
  Color color;

  /// 被绑定状态
  bool isBind = false;

  /// 帧绘制时钟
  int frameClock = 0;

  /// 完成事件
  Function(DFAnimationSprite)? onComplete;

  /// 创建动画精灵
  DFAnimationSprite({
    this.stepTime = 200,
    this.loop = true,
    this.color = const Color(0xFFFFFFFF),
    DFSize size = const DFSize(128, 128),
  }) : super(position: DFPosition(0, 0), size: size);

  /// 将plist转换Json后读取精灵
  /// {
  /// 	"frames": {
  /// 		"idle_00000.png":
  ///     {
  /// 	       "frame": "{{929,291},{76,110}}",
  /// 	       "offset": "{-19,24}",
  ///          "rotated": true
  ///      }
  ///   }
  /// }
  static Future<DFAnimationSprite> load(String json, {scale = 0.5, blendMode = BlendMode.srcOver}) async {
    print("DFAnimationSprite Load:" + json);
    DFAnimationSprite animationSprite = DFAnimationSprite(stepTime: 100, loop: true);
    DFAnimation.keys.forEach((element) {
      animationSprite.frames[element] = [];
    });
    Map<String, dynamic> jsonMap = await DFAssetsLoader.loadJson(json);
    ui.Image image = await DFAssetsLoader.loadImage(json.replaceAll(".json", ".png"));
    final jsonFrames = jsonMap['frames'] as Map<String, dynamic>;

    /// final jsonMetadata = jsonMap['metadata'] as Map<String, dynamic>;
    jsonFrames.forEach((key, value) {
      final map = value as Map;

      bool rotated = false;
      if (map['rotated'] != null) {
        rotated = map['rotated'] as bool;
      }

      final frame = map['frame'] as String;
      final offset = map['offset'] as String;
      List<String> frameText = frame.replaceAll("{{", "").replaceAll("},{", ",").replaceAll("}}", "").split(",");
      List<String> offsetText = offset.replaceAll("{", "").replaceAll("}", "").split(",");

      DFRect frameRect = DFRect(double.parse(frameText[0]), double.parse(frameText[1]), double.parse(frameText[2]),
          double.parse(frameText[3]));
      DFOffset frameOffset = DFOffset(double.parse(offsetText[0]), double.parse(offsetText[1]));

      /// 如果是旋转的参数也修改一下
      if (rotated) {
        frameRect = DFRect(double.parse(frameText[0]), double.parse(frameText[1]), double.parse(frameText[3]),
            double.parse(frameText[2]));
        frameOffset = DFOffset(double.parse(offsetText[1]), double.parse(offsetText[0]));
      }

      /// print("frameSize:" + frameRect.toString());
      /// print("frameOffset:" + frameOffset.toString());

      DFImageSprite sprite = DFImageSprite(
        image,
        offset: frameOffset,
        rect: frameRect,
        rotated: rotated,
        blendMode: blendMode,
      );
      sprite.scale = scale;

      /// idle_00000.png
      String actionText = "idle_";
      String action = DFAction.IDLE;
      if (key.contains("idle_")) {
        actionText = "idle_";
        action = DFAction.IDLE;
      } else if (key.contains("run_")) {
        actionText = "run_";
        action = DFAction.RUN;
      } else if (key.contains("attack_")) {
        actionText = "attack_";
        action = DFAction.ATTACK;
      } else if (key.contains("casting_")) {
        actionText = "casting_";
        action = DFAction.CASTING;
      } else if (key.contains("collect_")) {
        actionText = "collect_";
        action = DFAction.COLLECT;
      } else if (key.contains("death_")) {
        actionText = "death_";
        action = DFAction.DEATH;
      } else if (key.contains("track_")) {
        actionText = "track_";
        action = DFAction.TRACK;
      } else if (key.contains("explode_")) {
        actionText = "explode_";
        action = DFAction.EXPLODE;
      }

      String keyNumber = key.replaceAll(actionText, "").replaceAll(".png", "");
      if (keyNumber.startsWith("000")) {
        animationSprite.frames[action + DFDirection.UP]?.add(sprite);
      }
      if (keyNumber.startsWith("100")) {
        animationSprite.frames[action + DFDirection.UP_RIGHT]?.add(sprite);
        animationSprite.frames[action + DFDirection.UP_LEFT]?.add(sprite);
      }
      if (keyNumber.startsWith("200")) {
        animationSprite.frames[action + DFDirection.RIGHT]?.add(sprite);
        animationSprite.frames[action + DFDirection.LEFT]?.add(sprite);
      }
      if (keyNumber.startsWith("300")) {
        animationSprite.frames[action + DFDirection.DOWN_RIGHT]?.add(sprite);
        animationSprite.frames[action + DFDirection.DOWN_LEFT]?.add(sprite);
      }
      if (keyNumber.startsWith("400")) {
        animationSprite.frames[action + DFDirection.DOWN]?.add(sprite);
      }
    });

    return animationSprite;
  }

  /// 绑定动画同步子精灵
  void bindChild(DFAnimationSprite sprite) {
    sprite.isBind = true;
    sprite.position = DFPosition(sprite.position.x - size.width / 2, sprite.position.y - size.height / 2);
    this.bindSprites.add(sprite);
  }

  /// 移除绑定精灵
  void removeBindChild(DFAnimationSprite sprite) {
    sprite.visible = false;
    sprite.recyclable = true;
  }

  /// 播放动画
  void play(String animation, {int stepTime = 200, bool loop = true, onComplete}) {
    if (this.currentAnimation != animation) {
      this.currentIndex = 0;
      this.currentAnimation = animation;
      this.stepTime = stepTime;
      this.loop = loop;
      this.onComplete = onComplete;
      /*print("Play:" +
          animation.toString() +
          ",frames:" +
          this.frames[this.currentAnimation]!.length.toString() +
          ",stepTime:" +
          stepTime.toString());*/
    }
  }

  /// 精灵更新
  @override
  void update(double dt) {
    /// 控制动画帧切换
    if (this.frames[this.currentAnimation] != null && this.frames[this.currentAnimation]!.length > 0) {
      List<DFImageSprite> sprites = this.frames[this.currentAnimation]!;

      /// 控制动画帧按照stepTime进行更新
      if (DateTime.now().millisecondsSinceEpoch - this.frameClock > this.stepTime) {
        this.frameClock = DateTime.now().millisecondsSinceEpoch;
        if (sprites.length > this.currentIndex + 1) {
          this.currentIndex = this.currentIndex + 1;
        } else {
          /// 如果循环就从0再次开始
          if (this.loop) {
            this.currentIndex = 0;
          } else {
            /// 动画播放到完成
            if (onComplete != null) {
              onComplete!(this);
            }
          }
        }
      }
    }
    super.update(dt);
  }

  /// 精灵渲染
  @override
  void render(Canvas canvas) {
    /// 画布暂存
    canvas.save();

    /// 将子精灵转换为相对坐标
    if (parent == null) {
      canvas.translate(position.x, position.y);
    } else {
      canvas.translate(position.x - parent!.size.width / 2, position.y - parent!.size.height / 2);
    }

    /// 精灵矩形边界
    /// var paint = new Paint()..color = Color(0x6000FF00);
    /// canvas.drawRect(Rect.fromLTWH(- size.width/2,- size.height/2, size.width, size.height), paint);

    /// 渲染动画帧
    if (this.frames[this.currentAnimation] != null && this.frames[this.currentAnimation]!.length > 0) {
      List<DFImageSprite> sprites = this.frames[this.currentAnimation]!;
      sprites[this.currentIndex].flippedX = currentAnimationFlippedX;
      sprites[this.currentIndex].color = color;
      sprites[this.currentIndex].render(canvas);
    }

    /// 渲染子精灵
    if (children.length > 0) {
      children.forEach((sprite) {
        sprite.render(canvas);
      });
    }

    /// 渲染绑定精灵
    bindSprites.forEach((sprite) {
      if (sprite.visible &&
          sprite.frames[this.currentAnimation] != null &&
          this.frames[this.currentAnimation] != null) {
        /// 绑定精灵帧数不一定完全对应 所以这里计算一下接近值，保证速度和最后动画结束时间一致
        double offset = sprite.frames[this.currentAnimation]!.length / this.frames[this.currentAnimation]!.length;
        sprite.currentIndex = (this.currentIndex * offset).round();
        sprite.currentAnimation = this.currentAnimation;
        sprite.currentAnimationFlippedX = currentAnimationFlippedX;
        sprite.render(canvas);
      }
    });

    /// 画布恢复
    canvas.restore();
  }
}
