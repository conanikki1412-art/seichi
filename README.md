# 聖地巡礼マップ

スマホ用の聖地巡礼記録アプリ。地図に聖地を登録し、訪問済みチェック・写真・メモを残せる。
「みんなの聖地（共有）」と「自分の記録（この端末だけ）」の2モード構成。

公開URL: https://conanikki1412-art.github.io/seichi/

---

## ファイル

| ファイル | 用途 | GitHubへのアップ |
|---|---|---|
| `index.html` | アプリ本体。これ1つで完結 | 必要 |
| `apple-touch-icon.png` | ホーム画面アイコン（180px） | 必要 |
| `icon-512.png` | ファビコン・予備アイコン（512px） | 必要 |
| `supabase-setup.sql` | 共有モード用のDB初期設定＋デフォルト聖地12件 | 不要（Supabaseで実行するだけ） |
| `README.md` | このファイル | 任意 |

---

## セットアップ

### 1. GitHub Pages で公開

1. リポジトリに `index.html` と2つのPNGをアップロード
2. Settings → Pages → Source: `Deploy from a branch` / Branch: `main` `(root)` → Save
3. 1〜2分で `https://ユーザー名.github.io/リポジトリ名/` が有効になる

### 2. 共有モードを有効にする（Supabase・無料）

1. [supabase.com](https://supabase.com) で無料登録（カード不要）
2. New project を作成（リージョンは `Northeast Asia (Tokyo)` 推奨）
3. SQL Editor に `supabase-setup.sql` の中身を貼り付けて Run
4. Settings → API から `Project URL` と `anon public` キーをコピー
5. `index.html` 内の下記2行に貼り付けて、GitHubにアップし直す

```js
var SUPABASE_URL      = "https://xxxxx.supabase.co";
var SUPABASE_ANON_KEY = "eyJhbGci...";
```

設定画面の「共有サーバー」が緑●「接続OK」になれば完了。
未設定のままでも「自分の記録」モードだけで問題なく動く。

### 3. iPhoneでアプリ化

Safariで公開URLを開く → 共有ボタン → 「ホーム画面に追加」
以後は必ずホーム画面のアイコンから開く（Safariで開いた分とデータが別になるため）

---

## 更新のしかた

1. `index.html` を修正
2. GitHubのリポジトリで「Add file → Upload files」に同名でドラッグ → Commit changes
3. iPhoneはアプリを完全終了して開き直す。古いままなら10分待つか `?v=2` を付けて開く

記録データはブラウザ内に別枠で保存されるので、ファイルを差し替えても消えない。

---

## 使いかた

- **モード切替** … 地図上部のボタン。共有ピン＝紺、自分の記録＝赤（訪問済み）／白（未訪問）
- **登録** … 「聖地を登録」→ 地図を動かすか住所で検索 → 「ここに登録」→ 登録先（みんな／自分だけ）を選ぶ
- **共有 → 自分に追加** … 共有ピンの「自分の記録に追加」。そのまま編集画面が開くので訪問日や写真を足せる
- **自分 → 共有に登録** … 自分の記録の「みんなの聖地にも登録」
- **削除** … 自分が登録した共有ピンだけゴミ箱ボタンが出る（削除用の鍵を端末に保存している）
- **地図の種類** … 右下の🗺ボタン。標準／ブライト／淡色／地理院地図2種／航空写真

---

## 仕組み

- 地図: MapLibre GL JS + OpenFreeMap（キー不要・無料）、国土地理院タイル
- 地名検索・住所取得: Nominatim（OpenStreetMap）
- 自分の記録: ブラウザの localStorage（端末内のみ、写真はJPEG圧縮してBase64保存）
- 共有データ: Supabase（PostgreSQL + REST API）
- ホスティング: GitHub Pages

すべて無料枠で運用可能。全体の費用は0円。

---

## 注意点

- **自分の記録は端末内にしかない。** 設定 →「自分の記録を書き出す」で定期的にバックアップを
- **共有データは全員に見える。** 自宅など特定されたくない場所は登録しない
- **Supabase無料プランは7日間アクセスがないと一時停止する。** データは消えないが、管理画面から手動で再開が必要
- anonキーはソースに載るが、DBの権限を「閲覧と追加のみ」に絞っているため、他人がデータを改ざん・全削除することはできない
- 荒らし投稿は Supabase の Table Editor → `spots` から行を削除できる

---

## 今後やれること

- 共有モードの写真対応（Supabase Storage・無料枠1GB）
- 訪問ルートの提案、都道府県別の達成率
- 聖地の通報機能
