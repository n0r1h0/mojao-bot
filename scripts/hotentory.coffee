# Description:
#   Returns hatena hotentory feed information from http://b.hatena.ne.jp/hotentry/
#
# Commands:
#   hubot はてぶ - http://b.hatena.ne.jp/hotentry/it から今日のはてぶホットエントリー(テクノロジー)を取得します
#
#
gh = require './proc/get_hotentory'
genre = '(総合|世の中|政治と経済|経済|政治|生活|暮らし|学び|学習|
テクノロジー|テクノロジ|エンタメ|エンターテイメント|アニメとゲーム|アニメ|ゲーム|おもしろ|動画|画像|動画と画像)'

module.exports = (robot) ->

	hatebuMe = (keywords, url, msg) ->
		gh.hatebuMe robot.name, keywords, url, (ret) ->
			# for val in ret
				# msg.send { text: val, unfurl_links: false }
			text = "今日の#{keywords}系に関するニュースはコチラ"
			msg.send { text: text, as_user: true }
			msg.send { text: ret.join(), unfurl_links: false }

	robot.respond /はて(ぶ|ブ)$/i, (msg) ->
		url = 'http://b.hatena.ne.jp/hotentry/it.rss'
		hatebuMe "テクノロジー", url, msg

	robot.respond ///はて(ぶ|ブ)( me)? #{genre}///i, (msg) ->
		keywords = msg.match[3]
		text = ""
		if keywords.match(/総合/)
			url = 'http://feeds.feedburner.com/hatena/b/hotentry.rss'
		if keywords.match(/世の中/)
			url = 'http://b.hatena.ne.jp/hotentry/social.rss'
		if keywords.match(/(政治と経済|政治|経済)/i)
			url = 'http://b.hatena.ne.jp/hotentry/economics.rss'
		if keywords.match(/暮らし/)
			url = 'http://b.hatena.ne.jp/hotentry/life.rss'
		if keywords.match(/(学び|学習)/i)
			url = 'http://b.hatena.ne.jp/hotentry/knowledge.rss'
		if keywords.match(/(テクノロジー|テクノロジ)/i)
			url = 'http://b.hatena.ne.jp/hotentry/it.rss'
		if keywords.match(/(エンタメ|エンターテイメント)/i)
			url = 'http://b.hatena.ne.jp/hotentry/entertainment.rss'
		if keywords.match(/(アニメとゲーム|アニメ|ゲーム)/i)
			url = 'http://b.hatena.ne.jp/hotentry/game.rss'
		if keywords.match(/(おもしろ)/i)
			url = 'http://b.hatena.ne.jp/hotentry/fun.rss'
		if keywords.match(/(動画|画像|動画と画像)/i)
			url = 'http://feeds.feedburner.com/hatena/b/video.rss'

		hatebuMe keywords, url, msg
