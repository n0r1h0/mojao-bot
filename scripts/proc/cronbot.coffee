# Description:
#   cronでスケジュールする用
#

cronJob = require('cron').CronJob

module.exports = {
	set: (time, script) ->
		cronjob = new cronJob({
			cronTime: time # 実行する時間
			start: true # すぐにcronのjobを実行するかどうか
			timeZone: "Asia/Tokyo" # タイムゾーン
			onTick: -> # 実行処理
				script()
		})
}
