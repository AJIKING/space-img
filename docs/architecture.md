# ORBIT — Flutter アーキテクチャとフォルダ構成

`docs/product-spec.md` の仕様と `docs/test-plan.md` の差し替え境界を実現するためのアプリ構造を定義する。判断基準はハーネス方針(`docs/harness-engineering.md`)と同じ: **決定的にテストできること、必要になるまで複雑にしないこと。**

## 全体像

4 層のレイヤードアーキテクチャ。依存は必ず上から下への一方向。

```text
ui           画面・HUD・テーマ(Flutter)
  ↓
application  画面をまたぐ状態と操作(ChangeNotifier)
  ↓
domain       モデル・プール選択・補充判定(pure Dart)
  ↓ (インターフェースのみ)
data         domain のインターフェース実装(NASA API・永続化・画像キャッシュ)
```

- **domain は pure Dart**。`dart:ui` / `package:flutter` を import しない。プール選択・補充間隔判定・モデルが最速の unit test で守れる。
- **data は domain が定義したインターフェースを実装する**(依存性逆転)。domain は data を知らない。
- **ui は application を通じて状態を読む**。ui から domain のモデルを参照するのは可(表示のため)、data を直接触るのは不可。

## このアプリの肝: 表示と通信の分離

ORBIT の設計上もっとも重要なのは、**表示経路と補充経路を分けること**。

```text
[起動] → PoolStore からプール読込 → RandomPhotoPicker で 1 枚選択 → 表示
                                                              (ここまで通信なし・同期)

[起動後・非同期] → RefreshPolicy.shouldRefresh(now, lastRefreshedAt) が true のときだけ
                 → PhotoSource(NASA API)で取得 → ImageStore に保存 → PoolStore 更新
                 (失敗しても表示中のプールは壊さない)
```

- 表示経路(`ViewerController`)は `PhotoSource` を呼ばない。これを application 層の責務分離とテストで担保する。
- 補充経路(`PoolController` / `PoolRefresher`)だけが `PhotoSource` を呼ぶ。`RefreshPolicy`(`Clock` 注入)が 24h 判定を持つ。

## 主要な設計判断

| 判断 | 採用 | 理由 |
| --- | --- | --- |
| 状態管理 | `ChangeNotifier` + `ListenableBuilder`(Flutter 標準のみ) | 1 画面 + シートの規模に外部フレームワークは過剰。依存ゼロでテストも素直。破綻し始めたら Riverpod 移行を再検討 |
| DI | composition root でのコンストラクタ注入(DI コンテナなし) | 差し替え境界が数個。`main_*.dart` で組み立てれば十分 |
| ナビゲーション | ボトムシート / ダイアログ(`showModalBottomSheet` 等)中心 | 単一ビューア + オーバーレイ。多画面遷移がないので go_router は不要 |
| 不変モデル | `Photo` / `Pool` / 設定は immutable | 状態変化の追跡を application 層に限定する |
| 乱数 | `Random(seed)` を注入 | プロトタイプの `Math.random()` 直叩きは踏襲しない。失敗再現に seed を使う |
| 通信 | `PhotoSource` 境界の裏のみ。補充時だけ | 表示をオフライン・高速に保ち、レートリミットを避ける(ADR 0001) |
| 画像キャッシュ | `ImageStore` 境界(ファイル保存) | プールの実体。テストはインメモリ fake で決定的に |

## 差し替え境界とエントリーポイント

domain / core にインターフェース、data に本番実装、テストに fake を置く。

| 境界 | インターフェースの場所 | 本番実装 | テスト実装 |
| --- | --- | --- | --- |
| `Clock` | `core/` | システム時刻 | 固定・手動進行 fake |
| `Random` | (Dart 標準をそのまま注入) | 非決定 seed | 固定 seed |
| `PhotoSource` | `domain/photos/` | NASA Images API(http) | 成功 / 空 / 失敗 / 遅延を返す fake |
| `PoolStore` | `domain/pool/` | shared_preferences(メタ JSON) | インメモリ fake |
| `ImageStore` | `domain/pool/` | path_provider + ファイル | インメモリ fake |
| `SettingsStore` | `domain/settings/` | shared_preferences | インメモリ fake |
| `CollectionStore` | `domain/collection/` | shared_preferences | インメモリ fake |

composition root は 3 つ。組み立てロジックは共通化し、差分(clock / seed / store / source)だけを変える。

- `lib/main.dart` — 本番構成。
- `lib/main_dev.dart` — 開発用(デバッグ向け設定があれば)。
- `lib/main_test.dart` — integration test 用。fake clock・固定 seed・インメモリ store・フェイク source(または同梱シードのみ)で起動。

## フォルダ構成

実装はこの構成に沿って育てる(初期スケルトンは一部のみ存在し、機能実装で埋めていく)。

```text
lib/
├── main.dart                 # 本番 composition root
├── main_dev.dart             # 開発用 composition root
├── main_test.dart            # integration test 用 composition root
└── src/
    ├── app.dart              # MaterialApp・テーマ適用・ビューア起動
    ├── core/
    │   └── clock.dart        # Clock インターフェースと SystemClock
    ├── domain/
    │   ├── photos/
    │   │   ├── photo.dart              # Photo / Category(immutable モデル)
    │   │   └── photo_source.dart       # NASA から写真メタ+画像を取得する境界
    │   ├── pool/
    │   │   ├── photo_pool.dart         # Pool(写真リスト + lastRefreshedAt)
    │   │   ├── random_photo_picker.dart# プールから 1 枚選ぶ(Random 注入)
    │   │   ├── refresh_policy.dart     # 24h 補充判定(Clock 注入・pure)
    │   │   ├── pool_store.dart         # プールメタ永続化インターフェース
    │   │   ├── image_store.dart        # 画像バイナリのキャッシュ境界
    │   │   ├── image_cache_cleaner.dart # 全カテゴリ横断の画像掃除(pure)
    │   │   └── pool_refresher.dart      # 補充オーケストレーション(pure・境界を協調)
    │   ├── settings/
    │   │   ├── viewer_settings.dart    # 時計 / HUD / アンビエント設定(immutable)
    │   │   └── settings_store.dart     # 設定永続化インターフェース
    │   └── collection/
    │       └── collection_store.dart   # お気に入り永続化インターフェース
    ├── data/
    │   ├── nasa_photo_source.dart      # PhotoSource 実装(images-api.nasa.gov)
    │   ├── nasa_response.dart          # NASA レスポンスのパース(contract test 対象)
    │   ├── prefs_pool_store.dart       # PoolStore 実装
    │   ├── file_image_store.dart       # ImageStore 実装(path_provider)
    │   ├── prefs_settings_store.dart   # SettingsStore 実装
    │   ├── prefs_collection_store.dart # CollectionStore 実装
    │   └── seed_photos.dart            # 同梱シード(初回オフライン用。ADR 0004)
    ├── application/
    │   ├── dependencies.dart       # 差し替え境界の束(composition root が生成)
    │   ├── viewer_controller.dart  # 表示中の写真・切替・HUD トグル(通信しない)
    │   ├── pool_controller.dart    # 起動時のプール読込 + 補充の起動(PoolRefresher)
    │   ├── settings_controller.dart# 設定の読み書き + 永続化
    │   └── collection_controller.dart # お気に入りの読み書き + 永続化
    └── ui/
        ├── theme/
        │   └── orbit_theme.dart    # デザイントークン(色・フォント・spacing)
        ├── viewer/
        │   ├── viewer_screen.dart
        │   ├── photo_layer.dart    # クロスフェード + ビネット
        │   ├── hud_overlay.dart    # 時計・テレメトリ・レチクル・メタ・進捗
        │   ├── dock.dart           # SAVE / SAVED / WALLPAPER / TUNE
        │   └── scan_overlay.dart   # 再取得スキャン演出
        ├── customize/
        │   └── customize_sheet.dart # TUNE シート(テーマ/時計/HUD/アンビエント)
        ├── collection/
        │   └── collection_sheet.dart # SAVED シート
        ├── wallpaper/
        │   └── wallpaper_preview.dart # WALLPAPER モーダル
        └── widgets/
            ├── telemetry_readout.dart
            ├── reticle.dart
            └── toggle_row.dart
```

ファイル名は実装時の目安。1 ファイルが肥大したら同じフォルダ内で分割してよいが、**フォルダの責務と依存方向は変えない**。

## テストのミラー構成

`test/` は `lib/src/` をミラーし、層ごとのフォルダに置く(`docs/test-plan.md` の対応表に従う)。

```text
test/
├── unit/
│   ├── pool/               # プール選択・補充判定(RefreshPolicy)
│   ├── photos/             # Photo モデル・カテゴリ
│   └── data/               # NASA レスポンスのパース contract test
├── widget/
│   ├── viewer/             # HUD 表示分岐・ジェスチャー
│   ├── customize/          # 設定の反映
│   └── collection/
├── golden/                 # HUD パーツ・設定シート行(写真はプレースホルダ)
├── fixtures/               # 最小プール・fake 実装(fake_clock, in_memory_store, fake_photo_source)
integration_test/
└── smoke_test.dart         # オフライン起動 → プールから 1 枚表示 → 設定変更
```

fake は fixture と同様に共有資産として `test/fixtures/` に置き、各テストで重複定義しない。

## 依存ルールの守り方

- domain のファイルに `package:flutter` を import しない。違反は `/harness-review` のレビュー観点に含まれる。
- ui から `data/` を import しない。必要な操作はすべて application の controller を経由する。
- **`ViewerController`(表示経路)から `PhotoSource` を呼ばない**。通信は `PoolController` / `PoolRefresher`(補充経路)に限定する。
- 境界インターフェースにメソッドを足すときは、本番実装と fake の両方を同じ PR で更新する。
- `DateTime.now()` の直叩き、seed なしの `Random()`、`sleep` / 固定 `Future.delayed` による同期を書かない。

## このドキュメントの見直し時期

- 最初のビューア + HUD が実装された後(構成が実態と合っているか)。
- 状態管理が `ChangeNotifier` で苦しくなったとき(Riverpod 移行判断)。
- 補充を OS バックグラウンド実行へ広げるとき。
