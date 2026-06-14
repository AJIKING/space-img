# ADR 0003: 写真の供給元(NASA Images API)と補充トリガ

- 状態: 採用
- 日付: 2026-06-14

## 決定

- 写真の供給元は **NASA Image and Video Library(`https://images-api.nasa.gov/search`)** とする。API キーは不要。
- アクセスは `PhotoSource` 境界の裏に閉じる(本番実装 `NasaPhotoSource`、テストはフェイク)。
- 補充トリガは **起動後フォアグラウンドの非同期処理**。`RefreshPolicy` が「前回更新から 24h 以上」と判定したときだけ実行する(ADR 0001)。
- カテゴリ(観測テーマ)はプロトタイプの `CATEGORIES`(`nebula` / `galaxy` / `earth from space` / `mars surface` / `moon` / `jupiter` / `sun solar` / `hubble deep field` / `aurora` / `saturn`)の検索クエリを用いる。
- レスポンスのパースは `nasa_response.dart` に隔離し、保存した JSON サンプルで contract test する。

## 背景

写真の供給元と取得方法を決める。プロトタイプは `images-api.nasa.gov/search?q=...&media_type=image` を直接叩き、`collection.items[].links[0].href`(サムネイル)と `data[0]`(title / center / date / nasa_id)を読み、`~thumb.jpg` を `~medium.jpg` に置換して表示している。

| 候補 | 評価 |
| --- | --- |
| NASA Images API | キー不要・宇宙写真が豊富・プロトタイプ実績あり。レスポンス形が独特でパース契約が要る |
| NASA APOD API | 1 日 1 枚中心でプール補充には量が足りない。キーが要る |
| 自前 CDN に画像を用意 | 運用・著作権整理のコスト。初期 scope に過剰 |

## 理由

- プロトタイプがすでに NASA Images API で動いており、カテゴリ別検索で十分な多様性が得られる。
- キー不要なので認証ハーネスを作り込まなくてよい(`docs/harness-engineering.md` の初期決定)。
- 通信を `PhotoSource` 境界に閉じ、補充時だけ呼ぶことで、表示のオフライン性・高速性を壊さない(ADR 0001)。

## 結果

- `NasaPhotoSource` はタイムアウト付きで取得する(プロトタイプ同様 6 秒程度)。失敗・空・タイムアウトは例外ではなく「補充なし」として扱い、旧プールを保持する(ADR 0004)。
- パース規則: `links[0].href` と `data[0].title` を両方持つ item だけ採用。サムネイル URL の `~thumb.jpg` → `~medium.jpg` 昇格を行い、失敗時は thumb にフォールバックする方針はプロトタイプを踏襲する。
- 取得した画像は `ImageStore` に保存してプールに加える。プール件数の上限・追い出しは ADR 0001 の方針に従う。
- API のレスポンス形やエンドポイントが変わったら、`nasa_response.dart` と contract test の JSON サンプルを更新する。供給元自体を変える場合は新しい ADR を書く。
- 著作権・クレジット: NASA の素材は概ね利用可だが、メタの "NASA · {center}" 表記をプロトタイプ同様に表示してクレジットを残す。
