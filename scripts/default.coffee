# Description:
#   Example scripts for you to examine and try out.
#

cron = require('./proc/cronbot')
gh = require './proc/get_hotentory'

module.exports = (robot) ->
	robot.error (err, res) ->

	cron.set("0 0 9 * * *") ->
		d = new Date().getHours()
		robot.send {room: "general"}, "ヤッホー #{d} 時だよ"
		ret = gh.hatebuMe robot, "テクノロジー", url
		for val in ret
			robot.send {room: "general"}, {text:val, unfurl_links:true}