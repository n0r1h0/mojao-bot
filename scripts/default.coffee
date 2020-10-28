# Description:
#   Example scripts for you to examine and try out.
#
# Commands:
#   hubot 画像 <もの> google画像検索するよ
#   hubot image <もの> google画像検索するよ
#   hubot 雨 <場所> Yahoo!を使って降水予測を出すよ
#   hubot 天気 <場所> Dark Skyを使って天気予報を出すよ
#   hubot 天気 <場所> h Dark Skyを使って３時間毎の予報を出すよ
#   hubot 天気 <場所> w Dark Skyを使って週間予報を出すよ

cron = require './proc/cronbot'
gh = require './proc/get_hotentory'
gi = require './proc/google-images'
yw = require './proc/rainfall'
ds = require './proc/weather'

module.exports = (robot) ->
	robot.error (err, res) ->

	robot.respond /(image|img|がぞう|gazo|画像)(　| )(.+)/i, (msg) ->
		msg.send "探してくるね！"
		gi.imageMe msg, msg.match[3], (url) ->
			msg.send url
		
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

	robot.respond /(天気|tenki)(　| )([^ 　]+)$/i, (msg) ->
		ds.fetchWeather msg.match[3], (currently, hourly, daily) ->
			msg.send { text: currently[0], unfurl_links: true }
			msg.send { text: currently[1], unfurl_links: true }

	robot.respond /(天気|tenki)(　| )([^ 　]+)(　| )h/i, (msg) ->
		ds.fetchWeather msg.match[3], (currently, hourly, daily) ->
			if !msg.message.thread_ts?
				msg.message.thread_ts = msg.message.rawMessage.ts
			msg.send { text: "3時間毎の天気", unfurl_links: true }
			for t in hourly
				msg.send { text: t, unfurl_links: true }

	robot.respond /(天気|tenki)(　| )([^ 　]+)(　| )w/i, (msg) ->
		ds.fetchWeather msg.match[3], (currently, hourly, daily) ->
			if !msg.message.thread_ts?
				msg.message.thread_ts = msg.message.rawMessage.ts
			msg.send { text: "週間天気", unfurl_links: true }
			for t in daily
				msg.send { text: t, unfurl_links: true }



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
		url = 'http://b.hatena.ne.jp/hotentry/it.rss'
		ds.fetchWeather "目黒", (currently, hourly, daily) ->
			msg.send { text: currently[0], unfurl_links: true }
			msg.send { text: currently[1], unfurl_links: true }