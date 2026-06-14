import '../photos/photo.dart';

/// 時計の表示位置。
enum ClockPosition { top, center, bottom }

/// 時計の大きさ。
enum ClockSize { s, m, l }

/// ビューアのカスタマイズ設定(immutable)。プロトタイプの `state.settings` に対応。
///
/// 既定値はプロトタイプ準拠。永続化・編集 UI(TUNE シート)は別タスクで、
/// ここではモデルと既定値だけを定義する。
class ViewerSettings {
  const ViewerSettings({
    this.category = PhotoCategory.nebula,
    this.showClock = true,
    this.clockPosition = ClockPosition.top,
    this.clockSize = ClockSize.m,
    this.use24h = true,
    // 観測機器の装飾(座標テレメトリ / レチクル + 四隅ブラケット)は既定で非表示。
    // TUNE で ON にできる。
    this.showTelemetry = false,
    this.showReticle = false,
    this.showMeta = true,
    this.autoAdvance = false,
    this.intervalSeconds = 6,
    this.keepAwake = false,
  });

  /// 観測テーマ(表示するプールのカテゴリ)。
  final PhotoCategory category;

  final bool showClock;
  final ClockPosition clockPosition;
  final ClockSize clockSize;
  final bool use24h;

  final bool showTelemetry;
  final bool showReticle;
  final bool showMeta;

  final bool autoAdvance;
  final int intervalSeconds;

  /// 画面スリープ防止(常時表示の“眺める待ち受け”用)。
  final bool keepAwake;

  ViewerSettings copyWith({
    PhotoCategory? category,
    bool? showClock,
    ClockPosition? clockPosition,
    ClockSize? clockSize,
    bool? use24h,
    bool? showTelemetry,
    bool? showReticle,
    bool? showMeta,
    bool? autoAdvance,
    int? intervalSeconds,
    bool? keepAwake,
  }) {
    return ViewerSettings(
      category: category ?? this.category,
      showClock: showClock ?? this.showClock,
      clockPosition: clockPosition ?? this.clockPosition,
      clockSize: clockSize ?? this.clockSize,
      use24h: use24h ?? this.use24h,
      showTelemetry: showTelemetry ?? this.showTelemetry,
      showReticle: showReticle ?? this.showReticle,
      showMeta: showMeta ?? this.showMeta,
      autoAdvance: autoAdvance ?? this.autoAdvance,
      intervalSeconds: intervalSeconds ?? this.intervalSeconds,
      keepAwake: keepAwake ?? this.keepAwake,
    );
  }
}
