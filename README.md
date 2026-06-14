# ORBIT(orbit)

NASA の宇宙写真を「待ち受け」風に眺める Flutter アプリ。HUD オーバーレイ(時計・座標テレメトリ・レチクル・写真情報)とカスタマイズ、お気に入りコレクション、待ち受けプレビューを持つ。

毎回ちがう写真を見せるために、写真は**端末ローカルのプール(数十〜数百枚)からランダムに 1 枚選ぶ**。起動時はネットを叩かないのでオフラインでも動き、起動が速く、API レートリミットとも無縁。プールの補充は**前回更新から 24 時間以上経っていたときだけ、起動後にバックグラウンドで**行う(通信は 1 日 1 回程度に圧縮)。

## ドキュメント

- 仕様: [docs/product-spec.md](docs/product-spec.md)(プロトタイプ: [docs/prototype/orbit_space_wallpaper_app.html](docs/prototype/orbit_space_wallpaper_app.html))
- アーキテクチャ: [docs/architecture.md](docs/architecture.md)
- テスト計画: [docs/test-plan.md](docs/test-plan.md)
- ハーネス方針: [docs/harness-engineering.md](docs/harness-engineering.md)

## セットアップ

Flutter SDK は **3.44.1**(`.fvmrc` で固定。CI と同一バージョン)。

```sh
flutter pub get
```

## 開発コマンド

CI(`.github/workflows/check.yml`)と同じチェック(`/check` コマンドで一括実行できる):

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --exclude-tags golden --reporter expanded
```

golden の更新(基準 platform 上でのみ実行。詳細はハーネス方針の Golden 節 / ADR 0002):

```sh
flutter test --update-goldens test/golden
```

integration smoke test(エミュレータ / シミュレータを起動してから実行。CI では `.github/workflows/integration.yml` が main push 時に実行):

```sh
flutter test integration_test -d <device-id>
```
