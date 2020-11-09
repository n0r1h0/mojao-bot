
# Description:
#   Example scripts for you to examine and try out.
#
# Commands:
#   hubot 雨 <場所> - Yahoo!を使って降水予測を出すよ
#   hubot 天気 <場所> - Dark Skyを使って天気予報を出すよ
#   hubot 天気 <場所> h - Dark Skyを使って３時間毎の予報を出すよ
#   hubot 天気 <場所> d - Dark Skyを使って週間予報を出すよ

cron = require './proc/cronbot'
yolp = require './proc/yolp'
weather = require './proc/get_weatherapi'
pm = require './proc/postMessage'
moment = require 'moment'

module.exports = (robot) ->
	robot.respond /雨([ふ降止や]る？?)?[　 ](.+)$/i, (msg) ->
		msg.send "えーっと"
		yolp.fetchRainfall msg.match[2], (text) ->
			if !text?
				msg.send "#{msg.match[2]}がどこだかわからなかった。。。ごめんね。\n駅名とかじゃなくて地名だとわかりやすいかも・・・？"
			else
				msg.send text

	# 今日の予報
	robot.respond /(天気|tenn?ki)[　 ]([^ 　]+)([　 ]([hd])?)?/i, (msg) ->
		option = if msg.match[4]? then msg.match[4] else 'c'
		msg.send "ちょっと聞いてみるね" if option != 'd'
		msg.send "ちょっと待っててね。。。" if option == 'd'
		getWeather option, msg.match[2], (tz, fields, imageUrl) ->
			if !tz?
				msg.send "#{msg.match[2]}がどこだかわからなかった。。。ごめんね。\n駅名とかじゃなくて地名だとわかりやすいかも・・・？"
			else
				pm.postMessage robot, msg.envelope.room,
					[{ pretext: "#{tz} の" +
					"#{if option == 'c' then '今日の' else if option == 'h' then '2時間毎の' else '週間'}" +
					"予報だよ", fields, thumb_url: imageUrl }], (ts) ->

	cron.set "0 0 8 * * *", ->
		d = new Date().getHours()
		robot.send { room: "general" }, "ヤッホー #{d} 時だよ"
		robot.send { room: "general" }, "今日の天気はコチラ！"
		getWeather 'h', '目黒本町', (tz, fields) ->
			pm.postMessage robot, "#general",
				[{ pretext: "#{tz} の2時間毎の天気", fields }], (ts) ->

getWeather = (option, place, cb) ->
	timestamp = new Date / 1000 | 0
	weather.fetchWeather place, option, (currently, hourly, daily) ->
		return cb() if !currently?
		fields = []
		if option == "c"
			# 今日の予報は週間予報の当日から取得（否現在の天気）
			pred = currently[0]
			text = "#{pred.date}\n" + "#{pred.summary}\n" +
				":thermometer:：#{pred.maxTemperature}°C / #{pred.minTemperature}°C\n" +
				":umbrella:：#{pred.precipIntensity}mm / #{pred.precipProbability}%\n"
			fields.push { short: true, value: text }
			imageUrl = pred.imageUrl
		else if option == 'd'
			for pred in daily
				text = "#{pred.date}\n" + "#{pred.summary}\n" +
					":thermometer:：#{pred.maxTemperature}°C / #{pred.minTemperature}°C\n" +
					":umbrella:：#{pred.precipIntensity}mm / #{pred.precipProbability}%\n"
				fields.push { short: true, value: text }
		else
			h = parseInt(moment().format('H'), 10)
			for i in [h...h + 24] by 3
				pred = hourly[i]
				text = "#{pred.date}\n" + "#{pred.summary}\n" +
					":thermometer:/:umbrella:：#{pred.temperature}°C / #{pred.precipProbability}%\n"
				fields.push { short: true, value: text }
		cb currently[0].cityname, fields, imageUrl
