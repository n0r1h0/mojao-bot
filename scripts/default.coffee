# Description:
#   Example scripts for you to examine and try out.
#

cronJob = require('cron').CronJob

module.exports = (robot) ->
	robot.error (err, res) ->

	cronjob = new cronJob(
		cronTime: "0 0 9 * * *" # 実行する時間
		start: true # すぐにcronのjobを実行するかどうか
		timeZone: "Asia/Tokyo" # タイムゾーン
		onTick: -> # 実行処理
			# url = 'http://b.hatena.ne.jp/hotentry/it.rss'
			d = new Date().getHours()
			robot.send {room: "general"}, "ヤッホー #{d} 時だよ"
			# hatebuMe robot, nothing, "テクノロジー", url
	)
