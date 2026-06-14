# 同梱シード画像について

このフォルダの画像は、**初回起動・オフライン時に必ず 1 枚表示する**ための同梱シード
(ADR 0004 / docs/design-docs/0004-offline-fallback.md)。

現状の `*.jpg` は**プレースホルダ**(プログラム生成した宇宙風グラデ + 星)で、
本物の天体写真ではない。リリース前に **NASA Image and Video Library**(パブリック
ドメイン)などの実画像へ差し替え、各画像のクレジット(例: "NASA / STScI")を
`seed_photos.dart` の `center` と本ファイルに明記すること。

- `nebula_1.jpg` — カテゴリ: 星雲(nebula)
- `galaxy_1.jpg` — カテゴリ: 銀河(galaxy)
- `earth_1.jpg`  — カテゴリ: 地球(earth)

差し替え時はファイル名を変えず中身だけ置き換えれば、`seed_photos.dart` の
`imageRef` 変更は不要。
