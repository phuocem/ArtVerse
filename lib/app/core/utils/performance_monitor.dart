import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final List<Duration> _frameTimes = [];

  void start() {
    if (!kDebugMode) return;

    _frameTimes.clear();

    SchedulerBinding.instance.addTimingsCallback(_onFrame);
  }

  void stop() {
    if (!kDebugMode) return;

    SchedulerBinding.instance.removeTimingsCallback(_onFrame);
    _printStats();
  }

  void _onFrame(List<FrameTiming> timings) {
    for (final timing in timings) {
      final frameDuration = timing.totalSpan;
      _frameTimes.add(frameDuration);
    }
  }

  void _printStats() {
  }

  static void logMemory(String tag) {
    if (!kDebugMode) return;
  }

  static void logBuild(String widgetName) {
    if (!kDebugMode) return;
  }

  static Future<T> measure<T>(String operation, Future<T> Function() fn) async {
    if (!kDebugMode) return await fn();

    final stopwatch = Stopwatch()..start();
    final result = await fn();
    stopwatch.stop();

    return result;
  }

  static T measureSync<T>(String operation, T Function() fn) {
    if (!kDebugMode) return fn();

    final stopwatch = Stopwatch()..start();
    final result = fn();
    stopwatch.stop();

    return result;
  }
}
