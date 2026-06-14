# ORBIT — テスト計画

`docs/harness-engineering.md` の方針を `docs/product-spec.md` の仕様に適用した具体計画。新しい機能を実装するときは、この表に対応する層のテストを同じ PR に含める。

## 差し替え境界の具体化

ハーネス方針の差し替え対象候補を、このアプリでは次のとおり具体化する。

| 境界 | このアプリでの用途 | 既定実装 / テスト実装 |
| --- | --- | --- |
| `Clock` | 補充間隔(24h)判定、時計表示 | システム時刻 / 固定・手動進行の fake |
| `Random` | プールからの 1 枚選択、補充対象の選択 | 非決定 seed / **seed 注入で決定的に** |
| `PhotoSource` | NASA Images API から写真メタ + 画像取得 | http 実装 / 成功・空・失敗・遅延を返す fake |
| `PoolStore` | プール(写真リスト + lastRefreshedAt)の永続化 | shared_preferences / インメモリ fake |
| `ImageStore` | 画像バイナリのローカルキャッシュ | path_provider + ファイル / インメモリ fake |
| `SettingsStore` | カスタマイズ設定の永続化 | shared_preferences / インメモリ fake |
| `CollectionStore` | お気に入りの永続化 | shared_preferences / インメモリ fake |

通信は `PhotoSource` 境界に閉じる。シャッフル / 選択はプロトタイプの `Math.random()` 直叩きを踏襲せず、`Random(seed)` を注入し失敗時に seed をログへ出す。

## Unit test(`test/unit/`)

| 対象 | 守る振る舞い |
| --- | --- |
| プール選択(`RandomPhotoPicker`) | 空プールで null / 1 枚プールでそれを返す / seed 固定で同じ選択を再現 / 直前と同じ写真を避ける(連続回避の方針を採るなら) |
| 補充判定(`RefreshPolicy`) | `lastRefreshedAt` から 24h 未満は false / 24h 以上は true / 未補充(null)は true / 境界値(ちょうど 24h)/ すべて fake clock で実時間を使わない |
| プール更新 | 補充成功で新プールに入れ替え + `lastRefreshedAt` 更新 / 補充失敗で旧プール維持(件数が下限を割らない) / id 重複の排除 |
| Photo モデル | カテゴリの妥当性 / 等価性(id ベース)/ シリアライズ往復 |
| NASA レスポンスのパース(contract) | 画像 href とタイトルを持つ item だけ採用 / thumb → medium への URL 昇格 / 空 collection で空リスト / 想定外フィールド欠落でも落ちない |
| 永続化スキーマ | プール / 設定 / お気に入りの snapshot 往復 / 壊れた JSON で初期値にフォールバック(例外を投げない) |
| 表示フォーマット | 時刻 `HH:mm`(24h / 12h)/ 日付 `M月D日 (曜)` / フレーム番号ゼロ詰め |

## Widget test(`test/widget/`)

| 対象 | 守る振る舞い |
| --- | --- |
| ビューア | プールの写真が表示される / **表示経路でフェイク `PhotoSource` が呼ばれない**(呼び出し回数 0 を assert) |
| ジェスチャー | 左右スワイプで前後の写真 / タップで HUD 表示・非表示トグル / スワイプ中のタップは誤発火しない |
| HUD 表示分岐 | 時計 ON/OFF・位置・サイズ・24h / テレメトリ・レチクル・写真情報の ON/OFF が反映される |
| カスタマイズ(TUNE) | テーマチップ選択で対象カテゴリに切替 / 各トグル・セグメントが設定に反映 / 間隔の選択 |
| 自動スライド | ON で間隔ごとに次へ(fake clock / `pump` で進める。実時間 `sleep` を使わない) |
| コレクション(SAVED) | SAVE でお気に入り追加・解除 / グリッド表示 / セルタップでその写真を表示 / 空状態の案内 |
| 待ち受けプレビュー | 現在の写真がプレビューされる / 日付・時刻の表示 / 閉じる |
| オフライン起動 | プールがあればオフラインでも 1 枚表示される(フェイク source は失敗を返す) |
| Semantics | ドックボタン・トグル・チップに意味ラベルがある |

widget test では animation を `pumpAndSettle` または明示 `pump` で進め、実時間 `sleep` を使わない。スキャン・フェードも fake 化した時間で検証する。

## Golden test(`test/golden/`)

対象(写真レイヤは固定プレースホルダに差し替える。remote 画像を golden に含めない):

- HUD オーバーレイ(時計上/中/下、テレメトリ ON/OFF、レチクル ON/OFF)。
- 設定シートの行・トグル・セグメント・テーマチップ。
- コレクションの空状態 / セル。
- ローダー / オフライン時のトースト。

固定条件: device size、text scale 1.0、locale ja、カスタムフォントをテスト内でロード、写真はプレースホルダ。基準 platform は CI(Linux)— 詳細は `docs/harness-engineering.md` の Golden 方針と ADR 0002。全画面 snapshot(実写真込み)は撮らない。

**実装済み**(共通セットアップは `test/golden/golden_setup.dart`、各ファイル `@Tags(['golden'])`・非 Linux 自動 skip):

- `test/golden/hud_overlay_golden_test.dart` — HUD 既定 / 時計中央・テレメトリ&レチクル非表示。
- `test/golden/dock_golden_test.dart` — Dock(SAVE オフ / オン)。

**baseline は未生成**。基準 platform(Linux)で生成してコミットするまで、CI の golden job は赤になる(ローカル `--exclude-tags golden` は緑のまま)。生成手順:

1. `.github/workflows/golden.yml` を workflow_dispatch で実行(ubuntu-latest 上で `flutter test --update-goldens --tags golden`)。
2. artifact `golden-baselines` をダウンロードし、`test/golden/goldens/` に展開してコミットする(ADR 0002)。

## Integration smoke(`integration_test/`)

journey: **オフライン起動**(フェイク source は候補ゼロ=補充なし)→ シードプールから 1 枚表示 → スワイプ → お気に入り保存。

- **実装済み: `integration_test/smoke_test.dart`**。インメモリ store・固定 seed・フェイク source・`buildSeedPools()` で `OrbitApp` を直接組み立てて起動する。
- 手動確認 / launch 用のオフライン構成は `lib/main_test.dart`(常に候補ゼロを返す source + Prefs store + 固定 seed)。
- 実行はエミュレータ / シミュレータが必要(`flutter test integration_test -d <device>`)。CI は `.github/workflows/integration.yml`(main push と手動実行のみ。PR では必須にしない)。

## Fixture(`test/fixtures/`)

- 共有 fake: `fake_clock.dart` / `in_memory_pool_store.dart` / `in_memory_settings_store.dart` / `in_memory_collection_store.dart` / `fake_image_cache.dart` / `fake_photo_source.dart`(成功・空・失敗・遅延を切替可能)。
- 最小プール fixture: 1 枚 / 3 枚 / 空 / 同一カテゴリ複数。命名は「3 枚の星雲プール」のように検証したい振る舞いで付ける。
- NASA レスポンスのパース用に、サニタイズした小さな JSON サンプルを 1〜2 件置く(成功 1 件 + 空 collection 1 件)。本番データ snapshot は使わない。

## 実装順(ハーネス先行)

1. プール選択(`RandomPhotoPicker`)+ 補充判定(`RefreshPolicy`)の pure Dart ロジック + unit test(UI なしで最初の green を作る)。
2. `Photo` / `Pool` モデル + NASA パースの contract test。
3. 境界インターフェースと fake(`test/fixtures/`)。
4. 状態管理(`ViewerController` / `PoolController` / `SettingsController` / `CollectionController`)+ unit / widget test。表示経路が通信しないことを assert。
5. 画面実装(ビューア → HUD → 各シート)+ widget test(画面ごと)。
6. golden test(共有コンポーネントが安定してから)。
7. integration smoke + `main_test.dart`(オフライン起動 → プール表示)。
