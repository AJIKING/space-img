/// 観測テーマ(カテゴリ)。プロトタイプ(orbit_space_wallpaper_app.html)の
/// CATEGORIES に対応する。検索クエリ・表示名は実装フェーズで肉付けする。
enum PhotoCategory {
  nebula,
  galaxy,
  earth,
  mars,
  moon,
  jupiter,
  sun,
  deepField,
  aurora,
  saturn,
}

/// プールに格納する 1 枚の宇宙写真(immutable)。
///
/// 等価性は [id] のみで判定する(同じ写真の重複をプールから排除するため)。
class Photo {
  const Photo({
    required this.id,
    required this.title,
    required this.center,
    required this.category,
    required this.imageRef,
    this.date,
    this.sourceUrl,
  });

  /// 一意な識別子(NASA の nasa_id 等)。
  final String id;
  final String title;

  /// NASA センター名(JPL / GSFC / STScI など)。クレジット表示に使う。
  final String center;
  final PhotoCategory category;

  /// ローカルキャッシュ上の画像参照(ファイルパスやキー)。表示はここから読む。
  final String imageRef;
  final String? date;

  /// 取得元 URL(補充時の出所。表示には使わない)。
  final String? sourceUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Photo && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
