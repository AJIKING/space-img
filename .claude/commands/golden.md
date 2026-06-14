---
description: golden test を検証し、意図した UI 変更なら golden を更新する
allowed-tools: Bash(flutter:*), PowerShell(flutter:*), Read, Glob, Grep
---

golden test の検証・更新を行う。方針は `docs/harness-engineering.md` の「Golden Test 方針」に従う。

手順:

1. `flutter test --tags golden` を実行する(golden test がまだ無い場合はタグ 0 件で成功する。その旨を報告して終了)。
2. 失敗した場合、差分の原因を調査する:
   - 直近の差分(git diff)に UI 変更が含まれるか確認する。
   - **意図した UI 変更による差分**であれば、基準 platform(Linux)で baseline を再生成する。**Windows / macOS のローカルでは `--update-goldens` でコミットしない**(platform 差で baseline が壊れる。ADR 0002)。代わりに `.github/workflows/golden.yml` を workflow_dispatch し、artifact `golden-baselines` を `test/golden/goldens/` に展開してコミットする手順を案内する。
   - **意図しない差分**(UI 変更のない PR で golden が割れた等)であれば更新せず、回帰として原因ファイルと見立てを報告する。
3. 判断がつかない場合は更新せず、差分内容を説明してユーザーに確認する。

ルール:

- golden は視覚契約。失敗を黙らせるために無条件で `--update-goldens` を実行しない。
- 基準 platform は Linux(ADR 0002)。非 Linux で生成した画像はコミットしない。
- 新しい golden test を書くときは device size / text scale / theme / locale / font loading を固定し、**写真レイヤは固定プレースホルダ**にする(remote 画像を golden に含めない)。

対象(任意): $ARGUMENTS
