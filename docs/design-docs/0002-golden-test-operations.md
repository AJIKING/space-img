# ADR 0002: golden test の基準 platform と baseline 運用

- 状態: 採用
- 日付: 2026-06-14

## 決定

- golden test の**基準 platform は CI と同じ Linux(ubuntu-latest)**とする。
- 非 Linux(Windows / macOS の開発機)では、golden test は `skip: !Platform.isLinux` で**自動 skip** する(`test/golden/golden_setup.dart` の `skipGoldens`)。ローカルの `flutter test --exclude-tags golden` は golden 抜きで全 green を保つ。
- baseline 画像(`test/golden/goldens/`)は、**`.github/workflows/golden.yml`(workflow_dispatch)で生成し、artifact `golden-baselines` をダウンロードしてコミットする**。ローカルで `--update-goldens` した画像はコミットしない。
- golden test には `@Tags(['golden'])` を付け、`.github/workflows/check.yml` は test ステップ(`--exclude-tags golden`)と golden 比較 job(`--tags golden`)を分ける。
- **写真レイヤは固定プレースホルダに差し替える**。remote 画像を golden の比較対象に含めない(`docs/harness-engineering.md` の Golden 方針)。

## 背景

golden 画像はフォントレンダリング(ヒンティング・アンチエイリアス)が実行 platform に依存し、Windows 開発機と CI(Linux)で同じコードから生成した画像が一致しない。加えて本アプリは remote 画像が支配的なため、写真をそのまま含めると golden が安定しない。候補:

| 候補 | 評価 |
| --- | --- |
| platform ごとに baseline を持つ | 画像が platform 数だけ増え、更新責任が曖昧になる |
| 許容誤差つき比較(カスタム comparator) | false negative の調整コストが高く、視覚契約が緩む |
| 基準 platform を Linux に固定し、非 Linux は skip + 写真はプレースホルダ | baseline が 1 系統。CI で常に比較できる。ローカルでは見た目検証ができない制約のみ |

## 理由

- ローカルと CI の品質シグナルを両立する: ローカルは「golden 以外の全テスト green」、CI は「baseline と一致」という明確な責務分担になる。
- baseline の生成経路を workflow に一本化することで、「どの環境で生成した画像か」が常に追跡できる(ハーネス方針の再現可能性)。
- タグ分離により、baseline 未コミットの過渡期でも check.yml を赤くしない(golden 比較はタグ 0 件で成功)。
- 写真をプレースホルダにすることで、検証対象を HUD・UI レイヤの視覚契約に絞れる。

## 結果

- bootstrap 手順: golden.yml を workflow_dispatch で実行 → artifact `golden-baselines` をダウンロード → `test/golden/goldens/` に展開してコミット。
- check.yml の `golden` job は `flutter test --tags golden`(失敗時は `test/golden/failures/` の diff を artifact upload)。`--exclude-tags golden` の test job と並走する。
- UI 変更で golden が意図して変わる PR では、同じ手順で baseline を再生成して差分をコミットする。Windows / macOS で生成した画像をコミットした時点でこの運用は壊れるため、レビューで弾く。
- visual regression を release blocker にするかは `docs/harness-engineering.md` の初期方針(blocker にしない)に従う。
