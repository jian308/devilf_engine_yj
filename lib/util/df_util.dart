import 'dart:math';
import 'package:devilf_engine_yj/core/df_position.dart';
import 'package:devilf_engine_yj/game/df_animation.dart';

/// 工具类
class DFUtil {
  /// 获取标准8方向
  static String getDirection(double radians) {
    /// 判断8方向
    String direction = DFDirection.NONE;

    /// 换算角度
    double angle = 180 / pi * radians;
    if (angle < 0) {
      angle = angle + 360;
    }

    /// 顺时针 0~360
    /// print("angle:" + angle.toString());

    /// 右边
    if ((angle >= 0 && angle < 22.5) || (angle >= 337.5 && angle <= 360)) {
      direction = DFDirection.RIGHT;
    }

    /// 右下
    if (angle >= 22.5 && angle < 67.5) {
      direction = DFDirection.DOWN_RIGHT;
    }

    /// 下
    if (angle >= 67.5 && angle < 112.5) {
      direction = DFDirection.DOWN;
    }

    /// 左下
    if (angle >= 112.5 && angle < 157.5) {
      direction = DFDirection.DOWN_LEFT;
    }

    /// 左
    if (angle >= 157.5 && angle < 202.5) {
      direction = DFDirection.LEFT;
    }

    /// 左上
    if (angle >= 202.5 && angle < 247.5) {
      direction = DFDirection.UP_LEFT;
    }

    /// 上
    if (angle >= 247.5 && angle < 292.5) {
      direction = DFDirection.UP;
    }

    /// 右上
    if (angle >= 292.5 && angle < 337.5) {
      direction = DFDirection.UP_RIGHT;
    }

    /// 返回结果
    return direction;
  }

  /// 获取弧度
  static double getRadians(String direction) {
    double radians = 0;

    if (direction == DFDirection.DOWN_RIGHT) {
      radians = 45 * pi / 180.0;
    } else if (direction == DFDirection.UP_LEFT) {
      radians = 225 * pi / 180.0;
    } else if (direction == DFDirection.UP_RIGHT) {
      radians = 315 * pi / 180.0;
    } else if (direction == DFDirection.DOWN_LEFT) {
      radians = 135 * pi / 180.0;
    } else if (direction == DFDirection.RIGHT) {
      radians = 0;
    } else if (direction == DFDirection.LEFT) {
      radians = 180 * pi / 180.0;
    } else if (direction == DFDirection.DOWN) {
      radians = 90 * pi / 180.0;
    } else if (direction == DFDirection.UP) {
      radians = 270 * pi / 180.0;
    }

    /// 返回结果
    return radians;
  }

  /// Get [o] point distance [o1] and [o2] line segment distance
  static double getNearestDistance(DFPosition o1, DFPosition o2, DFPosition o) {
    if (o1 == o || o2 == o) return 0;

    final a = DFUtil.distanceTo(o2, o);
    final b = DFUtil.distanceTo(o1, o);
    final c = DFUtil.distanceTo(o1, o2);

    if (a * a >= b * b + c * c) return b;
    if (b * b >= a * a + c * c) return a;

    // 海伦公式
    final l = (a + b + c) / 2;
    final area = sqrt(l * (l - a) * (l - b) * (l - c));
    return 2 * area / c;
  }

  /// 获取距离
  static double distanceTo(DFPosition point1, DFPosition point2) => sqrt(distanceToSquared(point1, point2));

  /// 距离的平方
  static double distanceToSquared(DFPosition point1, DFPosition point2) {
    final dx = point1.x - point2.x;
    final dy = point1.y - point2.y;

    return dx * dx + dy * dy;
  }

  /// 将double转换为4位小数
  static double fixDouble4(double value) {
    return double.parse(value.toStringAsFixed(4));
  }

  /// 转换为二维数组
  static List<List<int>> to2dList(List<int> data,int columnSize,int fillValue) {
    int rowSize = (data.length / columnSize).ceil();
    List<List<int>> dataNew = List.generate(rowSize,(index)=> List.generate(columnSize, (index) => 0));
    /// print(dataNew.toString());
    for (int i = 0; i < data.length; i++) {
      int row = (i / columnSize).floor();
      int column = i % columnSize;
      /// print(row.toString() +","+ column.toString()+ ",value:" + data[i].toString());
      if (data[i] != 0) {
        dataNew[row][column] = 1;
      } else {
        dataNew[row][column] = 0;
      }
    }
    return dataNew;
  }
}
