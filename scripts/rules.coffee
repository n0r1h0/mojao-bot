# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

cronJob = require('cron').CronJob
request = require 'request'
parser = require 'xml2json'
proc = require 'child_process'

config = baseUrl: 'http://localhost:8080'

sleep = (ms)->
	date = new Date()
	loop
		break if (new Date())-date > ms

class MsgCenter
	_room = ''
	constructor: (room) ->
		_room = room

	send_message = (msg) ->
		request.post
			url: config.baseUrl + '/hubot/say'
			form:
				room: _room
				message: msg
		, (err, response, body) ->
			throw err if err

class Minecraft
	_mc = ''

	constructor: (room) ->
		_mc = new MsgCenter(room)

	check_exists: (cb) ->
		command = "ps aux | grep -s '[m]inecraft'"
		proc.exec command, (error, stdout, stderr) ->
			cb(!error?)

	start: () ->
		@check_exists (ret) ->
			if ret == true
				return
			proc.exec "/home/$USER/startmc.sh", (error, stdout, stderr) ->

	stop: () ->
		@check_exists (ret) ->
			if ret != true
				_mc.send_message "起動してないよ"
				return false

			command = "screen -S minecraft -X stuff 'stop\n\r'"
			try 
				result = proc.execSync(command)
				_mc.send_message "止めたよ"
			catch e
				console.log(e)
				_mc.send_message "ダメだった" 

	check_standup: (cb) ->
		d = new Date
		sleep 3000
		f = "/home/nori/logs/screen-#{d.getFullYear()}#{d.getMonth()+1}#{d.getDate()}.log"
		tail = proc.spawn "tail", ["-f", f]
		console.log("called")
		tail.stdout.on 'data', (data) ->
			if data.toString().indexOf("Done") > -1
				cb()
				proc.exec "rm #{f}", (error, stdout, stderr) ->
				tail.kill()

hatebuMe = (robot, msg, keywords, url, cnt=3) ->

	text = "#{robot.name}が今日の#{keywords}系に関するニュースをお知らせするー\n\n"

	msg.send text

	# TODO どうにかしてスレッド型の投稿にしたい
	# console.log res

	options =
		url : url
		timeout : 2000
		headers : {'user-agent': 'node title fetcher'}
	request options, (error, response, body) ->
		json = parser.toJson(body, { object : true })

		i = cnt
		for val in json["rdf:RDF"]["item"]
			text = "#{val.title}\n\n"
			text = text + "#{val.link}"

			i -= 1
			msg.send {text:text, unfurl_links:true}
			return i if i == 0

module.exports = (robot) ->
	robot.error (err, res) ->

	robot.router.post "/hubot/say", (req, res) ->
		envelope = {}
		envelope.user = {}
		envelope.user.room = envelope.room = req.body.room if req.body.room?
		envelope.user.type = req.body.type or 'groupchat'

		robot.send envelope, req.body.message

		res.end "Said #{req.body.messege}"

	cronjob = new cronJob(
		cronTime: "0 0 9 * * *" # 実行する時間
		start: true # すぐにcronのjobを実行するかどうか
		timeZone: "Asia/Tokyo" # タイムゾーン
		onTick: -> # 実行処理
			# url = 'http://b.hatena.ne.jp/hotentry/it.rss'
			d = new Date().getHours()
			robot.send {room: "general"}, "ヤッホー #{d} 時だよ"
			# hatebuMe robot, nothing, "テクノロジー", url
	)

	# マイクラ起動確認
	robot.respond /(minecraft|マイクラ|マインクラフト) *$/i, (res) ->
		mc = new Minecraft(res.envelope.room)
		mc.check_exists (ret) ->
			if ret == true
				res.send("起動してるよ")
			else
				res.send("起動してないよ")

	# マイクラ起動
	robot.respond /(minecraft|マイクラ|マインクラフト) *(start|起動|開始|スタート|動かして)$/i, (res) ->
		mc = new Minecraft(res.envelope.room)
		mc.check_exists (ret) ->
			if ret == true
				res.send "もう起動してるよー"
				return
			res.send "起動するー"
			mc.start()
			res.send """
			         多分30秒ぐらいかかるよ
			         完了したら教えるね
			         """
			mc.check_standup ->
				res.send "起動したよ"

	# マイクラ停止
	robot.respond /(minecraft|マイクラ|マインクラフト) *(stop|終了|停止|ストップ|止めて)$/i, (res) ->
		mc = new Minecraft(res.envelope.room)
		mc.stop()

	# Description:
	#   Returns hatena hotentory feed information from http://b.hatena.ne.jp/hotentry/
	#
	# Commands:
	#   hubot はてぶ - http://b.hatena.ne.jp/hotentry/it から今日のはてぶホットエントリー(テクノロジー)を取得します
	#   hubot はてぶ <総合> - 今日のはてぶホットエントリー(総合)を取得します
	#   hubot はてぶ <世の中> - 今日のはてぶホットエントリー(世の中)を取得します
	#   hubot はてぶ <政治と経済> - 今日のはてぶホットエントリー(政治と経済)を取得します
	#   hubot はてぶ <暮らし> - 今日のはてぶホットエントリー(暮らし)を取得します
	#   hubot はてぶ <学び> - 今日のはてぶホットエントリー(学び)を取得します
	#   hubot はてぶ <テクノロジー> - 今日のはてぶホットエントリー(テクノロジー)を取得します
	#   hubot はてぶ <エンタメ> - 今日のはてぶホットエントリー(エンタメ)を取得します
	#   hubot はてぶ <アニメとゲーム> - 今日のはてぶホットエントリー(アニメとゲーム)を取得します
	#   hubot はてぶ <おもしろ> - 今日のはてぶホットエントリー(おもしろ)を取得します
	#   hubot はてぶ <動画> - 今日のはてぶホットエントリー(動画)を取得します
	#

	robot.respond /はて(ぶ|ブ)$/i, (msg) ->
		url = 'http://b.hatena.ne.jp/hotentry/it.rss'
		hatebuMe robot, msg, "テクノロジー", url

	robot.respond /はて(ぶ|ブ)( me)? (総合|世の中|政治と経済|経済|政治|生活|暮らし|学び|学習|テクノロジー|テクノロジ|エンタメ|エンターテイメント|アニメとゲーム|アニメ|ゲーム|おもしろ|動画|画像|動画と画像)/i, (msg) ->
		keywords = msg.match[3]
		text = ""
		if keywords.match(/総合/)
			url = 'http://feeds.feedburner.com/hatena/b/hotentry.rss'
			hatebuMe robot, msg, keywords, url
		if keywords.match(/世の中/)
			url = 'http://b.hatena.ne.jp/hotentry/social.rss'
			hatebuMe robot, msg, keywords, url
		if keywords.match(/(政治と経済|政治|経済)/i)
			url = 'http://b.hatena.ne.jp/hotentry/economics.rss'
			hatebuMe robot, msg, keywords, url
		if keywords.match(/暮らし/)
			url = 'http://b.hatena.ne.jp/hotentry/life.rss'
			hatebuMe robot, msg, keywords, url
		if keywords.match(/(学び|学習)/i)
			url = 'http://b.hatena.ne.jp/hotentry/knowledge.rss'
			hatebuMe robot, msg, keywords, url
		if keywords.match(/(テクノロジー|テクノロジ)/i)
			url = 'http://b.hatena.ne.jp/hotentry/it.rss'
			hatebuMe robot, msg, keywords, url
		if keywords.match(/(エンタメ|エンターテイメント)/i)
			url = 'http://b.hatena.ne.jp/hotentry/entertainment.rss'
			hatebuMe robot, msg, keywords, url
		if keywords.match(/(アニメとゲーム|アニメ|ゲーム)/i)
			url = 'http://b.hatena.ne.jp/hotentry/game.rss'
			hatebuMe robot, msg, keywords, url
		if keywords.match(/(おもしろ)/i)
			url = 'http://b.hatena.ne.jp/hotentry/fun.rss'
			hatebuMe robot, msg, keywords, url
		if keywords.match(/(動画|画像|動画と画像)/i)
			url = 'http://feeds.feedburner.com/hatena/b/video.rss'
			hatebuMe robot, msg, keywords, url
