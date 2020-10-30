# Description:
#   Example scripts for you to examine and try out.
#
# Commands:
#   hubot 画像 <もの> google画像検索するよ
#   hubot image <もの> google画像検索するよ

gi = require './proc/get_image'
pm = require './proc/postMessage'

module.exports = (robot) ->
	robot.error (err, res) ->

	robot.respond /(image|img|がぞう|gazo|画像)[　 ](.+)/i, (msg) ->
		msg.send "探してくるね！"
		gi.getImage msg, msg.match[2], (url) ->
			pm.postMessage robot, msg.envelope.room,
				[{ pretext: "これかな？",
				fallback: "#{msg.match[2]}の画像(検索結果)",
				image_url: url }]
