import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:orbit/l10n/app_localizations.dart';
import 'package:orbit/src/domain/photos/photo.dart';
import 'package:orbit/src/ui/category_labels.dart';

/// 多言語対応(日本語 / 英語 / 簡体字)の正典テスト。
/// 端末ロケール追従のため UI 側にロケール切替はなく、ここでは各ロケールの
/// AppLocalizations を直接ロードして翻訳・カテゴリ名・日付整形を検証する。
void main() {
  setUpAll(() async {
    // hudDate はロケール依存の DateFormat を使うため、日付シンボルを初期化する。
    await initializeDateFormatting();
  });

  Future<AppLocalizations> load(String code) =>
      AppLocalizations.delegate.load(Locale(code));

  test('対応ロケールは日本語 / 英語 / 簡体字の 3 つ', () {
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
      {'en', 'ja', 'zh'},
    );
  });

  test('未対応ロケールのフォールバックは英語(supportedLocales 先頭)', () {
    expect(AppLocalizations.supportedLocales.first, const Locale('en'));
  });

  test('英語の主要文字列', () async {
    final l = await load('en');
    expect(l.tuneTitle, 'Customize');
    expect(l.retry, 'Reload');
    expect(l.emptyTitle, 'No photos yet');
    expect(l.collectionTitle, 'Collection');
  });

  test('日本語の主要文字列', () async {
    final l = await load('ja');
    expect(l.tuneTitle, 'カスタマイズ');
    expect(l.retry, '再取得');
    expect(l.emptyTitle, 'まだ写真がありません');
    expect(l.collectionTitle, 'コレクション');
  });

  test('簡体字の主要文字列', () async {
    final l = await load('zh');
    expect(l.tuneTitle, '自定义');
    expect(l.retry, '重新获取');
    expect(l.emptyTitle, '还没有照片');
    expect(l.collectionTitle, '收藏');
  });

  test('カテゴリ名がロケール別に解決される', () async {
    final en = await load('en');
    final ja = await load('ja');
    final zh = await load('zh');
    expect(categoryName(en, PhotoCategory.nebula), 'Nebula');
    expect(categoryName(ja, PhotoCategory.nebula), '星雲');
    expect(categoryName(zh, PhotoCategory.nebula), '星云');
    expect(categoryName(zh, PhotoCategory.galaxy), '星系');
    // 全カテゴリが各ロケールで非空に解決される(キー漏れ検出)。
    for (final c in PhotoCategory.values) {
      expect(categoryName(en, c), isNotEmpty);
      expect(categoryName(ja, c), isNotEmpty);
      expect(categoryName(zh, c), isNotEmpty);
    }
  });

  test('日付はロケール依存で整形される', () async {
    final d = DateTime(2026, 6, 14);
    expect((await load('ja')).hudDate(d), contains('6月14日'));
    expect((await load('en')).hudDate(d), contains('Jun 14'));
  });

  test('プレースホルダ付き文字列(現在時刻)が埋め込まれる', () async {
    expect((await load('ja')).semCurrentTime('09:05'), '現在時刻 09:05');
    expect((await load('en')).semCurrentTime('09:05'), 'Current time 09:05');
  });
}
