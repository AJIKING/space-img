# 同梱シード画像について

このフォルダの画像は、**初回起動・オフライン時に必ず 1 枚表示する**ための同梱シード
(ADR 0004 / docs/design-docs/0004-offline-fallback.md)。

**NASA Image and Video Library**(https://images.nasa.gov/)の実写真。NASA の
コンテンツは原則パブリックドメインで、クレジットを付して利用できる。各画像の
出所(nasa_id / センター)は `seed_photos.dart` のメタデータと一致する。

| ファイル | カテゴリ | nasa_id | タイトル | クレジット |
| --- | --- | --- | --- | --- |
| `nebula_1.jpg` | 星雲 | PIA14417 | ダンベル星雲(M27) | NASA/JPL |
| `galaxy_1.jpg` | 銀河 | PIA04921 | アンドロメダ銀河(M31) | NASA/JPL |
| `earth_1.jpg`  | 地球 | sl4-143-4707 | 地球軌道のスカイラブ | NASA/JSC |

差し替え・追加する場合は `build/seedwork/download.js`(NASA Images API から取得・
リサイズ)を参考に。ファイル名を変えなければ `seed_photos.dart` の `imageRef`
変更は不要(メタデータは更新すること)。

注: Hubble など一部は NASA/ESA 共同著作の場合がある。商用配布時は各画像の
利用条件(https://www.nasa.gov/nasa-brand-center/images-and-media/)を確認すること。
