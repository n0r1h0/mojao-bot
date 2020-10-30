# Description:
#   Returns hatena hotentory feed information from http://b.hatena.ne.jp/hotentry/
#
# Commands:
#   hubot はてぶ - http://b.hatena.ne.jp/hotentry/it から今日のはてぶホットエントリー(テクノロジー)を取得します
#
#
gh = require './proc/get_hotentory'
pm = require('./proc/postMessage')

genre = '(総合|世の中|政治と経済|経済|政治|生活|暮らし|学び|学習|
テクノロジー|テクノロジ|エンタメ|エンターテイメント|アニメとゲーム|アニメ|ゲーム|おもしろ|動画|画像|動画と画像)'

HATEB_URL = "http://b.hatena.ne.jp/hotentry"
HATENA_FEED_URL = "http://feeds.feedburner.com/hatena/b"

module.exports = (robot) ->

	hatebuMe = (keywords, url, msg) ->
		gh.hatebuMe robot.name, keywords, url, (ret) ->
			fields = []
			for val in ret
				fields.push { short: true, value: "・<#{val.link}|#{val.title}>" }
			text = "今日の#{keywords}系に関するニュースはコチラ"
			pm.postMessage robot, msg.envelope.room,　[{ pretext: text, fallback: text }], (ts) ->
				pm.postMessage robot, msg.envelope.room,　[{ fallback: "", fields }], ts, (ts) ->

	robot.respond /(はて(ぶ|ブ)|hatebu)$/i, (msg) ->
		url = 'http://b.hatena.ne.jp/hotentry/it.rss'
		hatebuMe "テクノロジー", url, msg

	robot.respond ///はて(ぶ|ブ)( me)? #{genre}///i, (msg) ->
		keywords = msg.match[3]
		text = ""
		if keywords.match(/総合/)
			url = "#{HATENA_FEED_URL}/hotentry.rss"
		if keywords.match(/世の中/)
			url = "#{HATEB_URL}social.rss"
		if keywords.match(/(政治と経済|政治|経済)/i)
			url = "#{HATEB_URL}economics.rss"
		if keywords.match(/暮らし/)
			url = "#{HATEB_URL}life.rss"
		if keywords.match(/(学び|学習)/i)
			url = "#{HATEB_URL}knowledge.rss"
		if keywords.match(/(テクノロジー|テクノロジ)/i)
			url = "#{HATEB_URL}it.rss"
		if keywords.match(/(エンタメ|エンターテイメント)/i)
			url = "#{HATEB_URL}entertainment.rss"
		if keywords.match(/(アニメとゲーム|アニメ|ゲーム)/i)
			url = "#{HATEB_URL}game.rss"
		if keywords.match(/(おもしろ)/i)
			url = "#{HATEB_URL}fun.rss"
		if keywords.match(/(動画|画像|動画と画像)/i)
			url = "#{HATENA_FEED_URL}/video.rss"

		hatebuMe keywords, url, msg
