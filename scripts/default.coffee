# Description:
#   Example scripts for you to examine and try out.
#

cron = require './proc/cronbot'
gh = require './proc/get_hotentory'

module.exports = (robot) ->
	robot.error (err, res) ->

	cron.set "0 0 9 * * *", ->
		d = new Date().getHours()
		robot.send { room: "general" }, "ヤッホー #{d} 時だよ"
		url = 'http://b.hatena.ne.jp/hotentry/it.rss'
		gh.hatebuMe robot.name, "テクノロジー", url, (ret) ->
			for val in ret
				if !robot.message.thread_ts?
					robot.message.thread_ts = robot.message.rawMessage.ts
				robot.send { room: "general" } , { text: val, unfurl_links: true }

	cron.set "0 0 12 * * *", ->
		d = new Date().getHours()
		robot.send { room: "general" }, "ヤッホー #{d} 時だよ"
		url = 'http://b.hatena.ne.jp/hotentry/it.rss'
		gh.hatebuMe robot.name, "テクノロジー", url, (ret) ->
			for val in ret
				robot.send { room: "general" }, { text: val, unfurl_links: true }

	cron.set "0 0 18 * * *", ->
		d = new Date().getHours()
		robot.send { room: "general" }, "ヤッホー #{d} 時だよ"
		url = 'http://b.hatena.ne.jp/hotentry/it.rss'
		gh.hatebuMe robot.name, "テクノロジー", url, (ret) ->
			for val in ret
				robot.send { room: "general" }, { text: val, unfurl_links: true }

	cron.set "0 0 21 * * *", ->
		d = new Date().getHours()
		robot.send { room: "general" }, "ヤッホー #{d} 時だよ"
		url = 'http://b.hatena.ne.jp/hotentry/it.rss'
		gh.hatebuMe robot.name, "テクノロジー", url, (ret) ->
			for val in ret
				robot.send { room: "general" }, { text: val, unfurl_links: true }

