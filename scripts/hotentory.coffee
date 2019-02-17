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
hatebuMe = require 'proc/get_hotentory'

module.exports = (robot) ->

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
