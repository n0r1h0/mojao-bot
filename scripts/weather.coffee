
# Description:
#   Example scripts for you to examine and try out.
#
# Commands:
#   hubot 雨 <場所> Yahoo!を使って降水予測を出すよ
#   hubot 天気 <場所> Dark Skyを使って天気予報を出すよ
#   hubot 天気 <場所> h Dark Skyを使って３時間毎の予報を出すよ
#   hubot 天気 <場所> d Dark Skyを使って週間予報を出すよ

cron = require './proc/cronbot'
yolp = require './proc/yolp'
ds = require './proc/get_darksky'
pm = require './proc/postMessage'

module.exports = (robot) ->
	robot.respond /(雨|ame)[　 ](.+)/i, (msg) ->
		msg.send "えーっと"
		yolp.fetchRainfall msg.match[2], (text) ->
			msg.send text

	robot.respond /雨(ふ|降|止|や)る？?$/i, (msg) ->
		yolp.fetchRainfall "目黒", (text) ->
			msg.send text

	robot.respond /雨(ふ|降|止|や)る？?[　 ](.+)$/i, (msg) ->
		yolp.fetchRainfall msg.match[2], (text) ->
			msg.send text

	# 今日の予報
	robot.respond /(天気|tenn?ki)[　 ]([^ 　]+)$/i, (msg) ->
		msg.send "ちょっと聞いてみるね"
		getWeather "c", msg.match[2], (tz, fields, imageUrl) ->
			pm.postMessage robot, msg.envelope.room,
				[{ pretext: "#{tz} の今日の予報だよ", fields, thumb_url: imageUrl }], (ts) ->

	# の予報
	robot.respond /(天気|tenn?ki)[　 ]([^ 　]+)(　| )[hd]/i, (msg) ->
		msg.send "ちょっと聞いてみるね"
		getWeather msg.match[3], msg.match[2], (tz, fields) ->
			pm.postMessage robot, msg.envelope.room,
				[{ pretext: "#{tz} の#{if msg.match[3] == 'h' then '2時間毎の' else '週間'}天気", fields }], (ts) ->

	cron.set "0 0 9 * * *", ->
		d = new Date().getHours()
		robot.send { room: "general" }, "ヤッホー #{d} 時だよ"
		robot.send { room: "general" }, "今日の天気はコチラ！"
		getWeather 'h', '目黒', (tz, fields) ->
			pm.postMessage robot, msg.envelope.room,
				[{ pretext: "#{tz} の#{if msg.match[3] == 'h' then '2時間毎の' else '週間'}天気", fields }], (ts) ->

getWeather = (option, place, cb) ->
	timestamp = new Date / 1000 | 0
	ds.fetchWeather place, (currently, hourly, daily) ->
		fields = []
		if option == "c"
			# 今日の予報は週間予報の当日から取得（否現在の天気）
			pred = daily[0]
			text = "#{pred.time}\n" + "#{pred.summary}\n" +
				"気温：#{pred.temperatureHigh}°C / #{pred.temperatureLow}°C\n" +
				"降水量/降水確率：#{pred.precipIntensity}mm / #{pred.precipProbability}%\n"
			fields.push { short: true, value: text }
			imageUrl = pred.imageUrl
		else if option == "h"
			for i in [0...16] by 2
				pred = hourly[i]
				text = "#{pred.time}\n" + "#{pred.summary}\n" +
					"気温/湿度：#{pred.temperature}°C / #{pred.humidity}%\n" +
					"降水量/降水確率：#{pred.precipIntensity}mm / #{pred.precipProbability}%\n"
				fields.push { short: true, value: text }
		else
			for i in [0...8]
				pred = daily[i]
				text = "#{pred.time}\n" + "#{pred.summary}\n" +
					"気温：#{pred.temperatureHigh}°C / #{pred.temperatureLow}°C\n" +
					"降水量/降水確率：#{pred.precipIntensity}mm / #{pred.precipProbability}%\n"
				fields.push { short: true, value: text }
		cb currently[0].timezone, fields, imageUrl
