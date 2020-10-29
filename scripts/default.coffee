# Description:
#   Example scripts for you to examine and try out.
#
# Commands:
#   hubot 画像 <もの> google画像検索するよ
#   hubot image <もの> google画像検索するよ

cron = require './proc/cronbot'
gh = require './proc/get_hotentory'
gi = require './proc/google-images'
pm = require './proc/postMessage'

module.exports = (robot) ->
	robot.error (err, res) ->

	robot.respond /(image|img|がぞう|gazo|画像)(　| )(.+)/i, (msg) ->
		msg.send "探してくるね！"
		gi.imageMe msg, msg.match[3], (url) ->
			pm.postMessage robot, msg.envelope.room,
				[{ pretext: "これかな？", fallback: "#{msg.match[3]}の画像(検索結果)", image_url: url }]

	# cron.set "0 0 9 * * *", ->
	# 	d = new Date().getHours()
	# 	robot.send { room: "general" }, "ヤッホー #{d} 時だよ"
	# 	url = 'http://b.hatena.ne.jp/hotentry/it.rss'
	# 	gh.hatebuMe robot.name, "テクノロジー", url, (ret) ->
	# 		for val in ret
	# 			if !robot.message.thread_ts?
	# 				robot.message.thread_ts = robot.message.rawMessage.ts
	# 			robot.send { room: "general" } , { text: val, unfurl_links: true }
