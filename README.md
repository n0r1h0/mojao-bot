# もじゃおbot
hubotのslack連係を使って色々と遊んでいます。

## 機能
bot機能として以下の機能を実装しています。
* google画像検索
* ホッテントリの取得
* Dark Sky天気予報の取得
* YOLP降水予報の取得
* amagumo

## 変数
利用には以下の変数設定が必要です。

| 変数 | 値 | 備考 |
|-|-|-|
|HUBOT_HEROKU_KEEPALIVE_URL|https://***.herokuapp.com/|herokuのドメイン|
|HUBOT_HEROKU_SLEEP_TIME|2:00|herokuのkeep aliveをお休みする時間|
|HUBOT_HEROKU_WAKEUP_TIME|8:00|herokuのkeep aliveを始める時間|
|TZ|Asia/Tokyo|上記keep aliveのTimeZone|
|HUBOT_SLACK_TOKEN|***|slackで発行したtoken|
|HUBOT_GOOGLE_CSE_ID|***|google custom searchで作成したID|
|HUBOT_GOOGLE_CSE_KEY|***|google APIのAPIキー|
|HUBOT_YAHOO_APP_ID|***|[YOLP](https://developer.yahoo.co.jp/webapi/map/)のAPIキー|
|HUBOT_DARK_SKY_APP_ID|***|Dark SkyのAPIキー※|

※Dark SKyのAPI利用登録は停止しているため、[Rakuten Rapid API](https://api.rakuten.co.jp/ja/)から取得しました。

