import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/data/nasa_response.dart';
import 'package:orbit/src/domain/photos/photo.dart';
import 'package:orbit/src/domain/photos/photo_source.dart';

void main() {
  test('links と title を持つ item だけ採用する(契約)', () {
    final body = File(
      'test/fixtures/nasa_search_sample.json',
    ).readAsStringSync();

    final photos = parseNasaSearch(body, PhotoCategory.nebula);

    expect(photos.length, 1);
    final p = photos.single;
    expect(p.id, 'PIA00001');
    expect(p.title, 'Carina Nebula');
    expect(p.center, 'JPL');
    expect(p.date, '2022-07-12');
    expect(p.category, PhotoCategory.nebula);
    expect(p.imageUrl, endsWith('PIA00001~medium.jpg'));
  });

  test('空 collection は空リスト', () {
    expect(
      parseNasaSearch('{"collection":{"items":[]}}', PhotoCategory.mars),
      isEmpty,
    );
  });

  test('collection を持たない JSON でも落ちない', () {
    expect(parseNasaSearch('{}', PhotoCategory.mars), isEmpty);
  });

  test('不正な JSON は PhotoSourceException', () {
    expect(
      () => parseNasaSearch('not json', PhotoCategory.mars),
      throwsA(isA<PhotoSourceException>()),
    );
  });

  test('nasaQuery はカテゴリごとの検索クエリを返す', () {
    expect(nasaQuery(PhotoCategory.deepField), 'hubble deep field');
    expect(nasaQuery(PhotoCategory.mars), 'mars surface');
  });

  test('upgradeThumb は ~thumb を ~medium に昇格する', () {
    expect(upgradeThumb('x/foo~thumb.jpg'), 'x/foo~medium.jpg');
    expect(upgradeThumb('x/foo~THUMB.JPG'), 'x/foo~medium.jpg');
  });
}
