
# Description:
#   Example scripts for you to examine and try out.
#
# Commands:
#   hubot 雨 <場所> Yahoo!を使って降水予測を出すよ
#   hubot 天気 <場所> Dark Skyを使って天気予報を出すよ
#   hubot 天気 <場所> h Dark Skyを使って３時間毎の予報を出すよ
#   hubot 天気 <場所> d Dark Skyを使って週間予報を出すよ

cron = require './proc/cronbot'
yw = require './proc/rainfall'
ds = require './proc/weather'
pm = require './proc/postMessage'

module.exports = (robot) ->
	robot.respond /(雨|ame)(　| )(.+)/i, (msg) ->
		msg.send "えーっと"
		yw.fetchRainfall msg.match[3], (text) ->
			msg.send text

	robot.respond /雨(ふ|降)る(？)?$/i, (msg) ->
		yw.fetchRainfall "目黒", (text) ->
			msg.send text

	robot.respond /雨(止|や)む(？)?$/i, (msg) ->
		yw.fetchRainfall "目黒", (text) ->
			msg.send text

	robot.respond /雨(ふ|降)る(？)?(　| )(.+)$/i, (msg) ->
		yw.fetchRainfall msg.match[4], (text) ->
			msg.send text

	robot.respond /雨(止|や)む(？)?(　| )(.+)$/i, (msg) ->
		yw.fetchRainfall msg.match[4], (text) ->
			msg.send text

	robot.respond /(天気|tenn?ki)(　| )([^ 　]+)$/i, (msg) ->
		msg.send "ちょっと聞いてみるね"
		ds.fetchWeather msg.match[3], (currently, hourly, daily) ->
			pm.postMessage robot, msg.envelope.room, [{ pretext: currently[0], text: currently[1], thumb_url: currently[2] }], (ts) ->

	robot.respond /(天気|tenn?ki)(　| )([^ 　]+)(　| )h/i, (msg) ->
		timestamp = new Date / 1000 | 0
		msg.send "ちょっと聞いてみるね"
		ds.fetchWeather msg.match[3], (currently, hourly, daily) ->
			fields = []
			for i in [0...16] by 2
				fields.push { short: true, value: hourly[i] }
			pm.postMessage robot, msg.envelope.room, [{ pretext: "2時間毎の天気", fields }], (ts) ->
			# msg.send { text: "3時間毎の天気", unfurl_links: true }

	robot.respond /(天気|tenn?ki)(　| )([^ 　]+)(　| )d/i, (msg) ->
		msg.send "ちょっと聞いてみるね"
		ds.fetchWeather msg.match[3], (currently, hourly, daily) ->
			fields = []
			for i in [0...hourly.length] by 2
				fields.push { short: true, value: daily[i] }
			pm.postMessage robot, msg.envelope.room, [{ pretext: "週間天気", fields }], (ts) ->

	# cron.set "0 0 9 * * *", ->
	# 	d = new Date().getHours()
	# 	robot.send { room: "general" }, "ヤッホー #{d} 時だよ"
	# 	url = 'http://b.hatena.ne.jp/hotentry/it.rss'
	# 	gh.hatebuMe robot.name, "テクノロジー", url, (ret) ->
	# 		for val in ret
	# 			if !robot.message.thread_ts?
	# 				robot.message.thread_ts = robot.message.rawMessage.ts
	# 			robot.send { room: "general" } , { text: val, unfurl_links: true }

	cron.set "0 0 9 * * *", ->
		d = new Date().getHours()
		robot.send { room: "general" }, "ヤッホー #{d} 時だよ"
		robot.send { room: "general" }, "今日の天気はコチラ！"
		ds.fetchWeather "目黒", (currently, hourly, daily) ->
			fields = []
			for i in [0...16] by 2
				fields.push { short: true, value: hourly[i] }
			pm.postMessage robot, "general", [{ pretext: "2時間毎の天気", fields }], (ts) ->