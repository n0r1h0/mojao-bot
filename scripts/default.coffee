# Description:
#   Example scripts for you to examine and try out.
#

cron = require './proc/cronbot'
gh = require './proc/get_hotentory'

module.exports = (robot) ->
	robot.error (err, res) ->

	cron.set "0 0 9 * * *", ->
		url = 'http://b.hatena.ne.jp/hotentry/it.rss'
		gh.hatebuMe robot.name, "テクノロジー", url, (ret) ->
			d = new Date().getHours()
			post="ヤッホー #{d} 時だよ\n"
			for val in ret
				post=post+val+"\n"
			robot.send {room: "general"}, {text:post, unfurl_links:false}

	cron.set "0 0 12 * * *", ->
		url = 'http://b.hatena.ne.jp/hotentry/it.rss'
		gh.hatebuMe robot.name, "テクノロジー", url, (ret) ->
			d = new Date().getHours()
			post="ヤッホー #{d} 時だよ\n"
			for val in ret
				post=post+val+"\n"
			robot.send {room: "general"}, {text:post, unfurl_links:false}
