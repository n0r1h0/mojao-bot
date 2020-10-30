
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

	robot.respond /(天気|tenn?ki)[　 ]([^ 　]+)$/i, (msg) ->
		msg.send "ちょっと聞いてみるね"
		ds.fetchWeather msg.match[2], (currently, hourly, daily) ->
			pred = daily[0]
			text = "#{pred.time}\n" + "#{pred.summary}\n" +
				"気温：#{pred.temperatureHigh}°C / #{pred.temperatureLow}°C\n" +
				"降水量/降水確率：#{pred.precipIntensity}mm / #{pred.precipProbability}%\n"
			attachment = [{
				pretext: "#{currently[0].timezone} の予報だよ",
				text: text,
				thumb_url: pred.imageUrl
			}]
			pm.postMessage robot, msg.envelope.room, attachment, (ts) ->

	robot.respond /(天気|tenn?ki)[　 ]([^ 　]+)(　| )h/i, (msg) ->
		timestamp = new Date / 1000 | 0
		msg.send "ちょっと聞いてみるね"
		ds.fetchWeather msg.match[2], (currently, hourly, daily) ->
			fields = []
			for i in [0...16] by 2
				pred = hourly[i]
				text = "#{pred.time}\n" + "#{pred.summary}\n" +
					"気温/湿度：#{pred.temperature}°C / #{pred.humidity}%\n" +
					"降水量/降水確率：#{pred.precipIntensity}mm / #{pred.precipProbability}%\n"
				fields.push { short: true, value: text }
			pm.postMessage robot, msg.envelope.room,
				[{ pretext: "#{currently[0].timezone} の2時間毎の天気", fields }], (ts) ->
			# msg.send { text: "3時間毎の天気", unfurl_links: true }

	robot.respond /(天気|tenn?ki)(　| )([^ 　]+)(　| )d/i, (msg) ->
		msg.send "ちょっと聞いてみるね"
		ds.fetchWeather msg.match[3], (currently, hourly, daily) ->
			fields = []
			for i in [0...8]
				pred = daily[i]
				text = "#{pred.time}\n" + "#{pred.summary}\n" +
					"気温：#{pred.temperatureHigh}°C / #{pred.temperatureLow}°C\n" +
					"降水量/降水確率：#{pred.precipIntensity}mm / #{pred.precipProbability}%\n"
				fields.push { short: true, value: text }
			pm.postMessage robot, msg.envelope.room,
				[{ pretext: "#{currently[0].timezone} の週間天気", fields }], (ts) ->

	cron.set "0 0 9 * * *", ->
		d = new Date().getHours()
		robot.send { room: "general" }, "ヤッホー #{d} 時だよ"
		robot.send { room: "general" }, "今日の天気はコチラ！"
		ds.fetchWeather "目黒", (currently, hourly, daily) ->
			fields = []
			for i in [0...16] by 2
				fields.push { short: true, value: hourly[i] }
			pm.postMessage robot, "general", [{ pretext: "2時間毎の天気", fields }], (ts) ->