import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/widgets.dart';

/// 音效播放
class DFAudio {
  static String prefix = "assets/audio/";

  /// 计数
  int count = 0;

  /// 定时播放
  Timer? timer;

  /// 开始播放音效序列
  void startPlay(List<String> files, {stepTime = 400, loop = false}) {
    if (files.isEmpty) {
      return;
    }
    count = 0;
    timer = Timer.periodic(Duration(milliseconds: stepTime), (t) {
      if (count == files.length) {
        if (loop) {
          count = 0;
          String file = files.elementAt(count);
          play(file);
        } else {
          timer!.cancel();
          timer = null;
        }
      } else {
        String file = files.elementAt(count);
        play(file);
      }
      count++;
    });
  }

  /// 取消播放音效序列
  void stopPlay() {
    if (timer != null) {
      timer!.cancel();
      timer = null;
      count = 0;
    }
  }

  /// 背景音乐
  static BackgroundMusic backgroundMusic = BackgroundMusic();

  /// 播放短音频
  static Future<void> play(String file, {double volume = 1.0}) {
    return FlameAudio.play(file, volume: volume);
  }

  /// 循环播放
  static Future<void> loop(String file, {double volume = 1.0}) {
    return FlameAudio.loop(file, volume: volume);
  }

  /// 播放长音频
  static Future<void> playLongAudio(String file, {double volume = 1.0}) {
    return FlameAudio.playLongAudio(file, volume: volume);
  }

  /// 循环播放长音频
  static Future<void> loopLongAudio(String file, {double volume = 1.0}){
    return FlameAudio.loopLongAudio(file, volume: volume);
  }
}

/// 背景音乐
class BackgroundMusic extends WidgetsBindingObserver {
  bool _isRegistered = false;
  
  bool isPlaying = false;

  BackgroundMusic() {
    FlameAudio.bgm.initialize();
  }

  void initialize() {
    if (_isRegistered) {
      return;
    }
    _isRegistered = true;
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> play(String filename, {double volume = 1}) async {
    return FlameAudio.bgm.play(filename, volume: volume);
  }

  // Future<Uri> load(String file) => audioCache.load(file);

  //Future<File> loadAsFile(String file) => audioCache.loadAsFile(file);

  //Future<List<Uri>> loadAll(List<String> files) => audioCache.loadAll(files);

  //void clear(Uri file) => audioCache.clear(file.path);

  //void clearAll() => audioCache.clearAll();

  Future<void> stop() async {
    isPlaying = false;
    await FlameAudio.bgm.stop();
  }

  Future<void> resume() async {
    isPlaying = true;
    await FlameAudio.bgm.resume();
  }

  Future<void> pause() async {
    isPlaying = false;
    await FlameAudio.bgm.pause();
  }

  void dispose() {
    if (!_isRegistered) {
      return;
    }
    WidgetsBinding.instance.removeObserver(this);
    _isRegistered = false;
    FlameAudio.bgm.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (isPlaying && FlameAudio.bgm.isPlaying) {
        FlameAudio.bgm.resume();
      }
    } else {
      FlameAudio.bgm.pause();
    }
  }
}
