# 同梱シード画像について

このフォルダの画像は、**初回起動・オフライン時、および未取得カテゴリへ切り替えた
直後に必ず 1 枚表示する**ための同梱シード(ADR 0004)。全 10 カテゴリ分を用意。

**NASA Image and Video Library**(https://images.nasa.gov/)の実写真。NASA の
コンテンツは原則パブリックドメインで、クレジットを付して利用できる。出所
(nasa_id / センター)は `seed_photos.dart` のメタデータと一致する。

| ファイル | カテゴリ | nasa_id | クレジット |
| --- | --- | --- | --- |
| `nebula_1.jpg` | 星雲 | PIA14417 | NASA/JPL |
| `galaxy_1.jpg` | 銀河 | PIA04921 | NASA/JPL |
| `earth_1.jpg` | 地球 | sl4-143-4707 | NASA/JSC |
| `mars_1.jpg` | 火星 | PIA05445 | NASA/JPL |
| `moon_1.jpg` | 月 | PIA12235 | NASA/JPL |
| `jupiter_1.jpg` | 木星 | PIA01527 | NASA/JPL |
| `sun_1.jpg` | 太陽 | PIA26681 | NASA/JPL(SDO) |
| `deepfield_1.jpg` | 深宇宙 | PIA12110 | NASA/STScI(Hubble) |
| `aurora_1.jpg` | オーロラ | (Hubble Jupiter auroras) | NASA/ESA/GSFC |
| `saturn_1.jpg` | 土星 | PIA06423 | NASA/JPL |

差し替え・追加は `build/seedwork/download.js`(NASA Images API から取得・リサイズ)
を参照。ファイル名を変えなければ `seed_photos.dart` の `imageRef` 変更は不要。

注: 深宇宙 / オーロラは NASA/ESA(Hubble)共同著作。商用配布時は各画像の利用条件
(https://www.nasa.gov/nasa-brand-center/images-and-media/ および ESA/Hubble の条件)
を確認すること。
