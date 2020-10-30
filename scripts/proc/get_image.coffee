
module.exports = {
	getImage: (msg, query, cb) ->
		imgUrl = query2google(msg)
		ensureImageExtension imgUrl

	getAnimation: (msg, query, cb) ->
		imgUrl = query2google(msg, { fileType: 'gif', hq: 'animated', tbs: 'itp:animated' })
		ensureImageExtension imgUrl.replace(
			/(giphy\.com\/.*)\/.+_s.gif$/,
			'$1/giphy.gif')
}
query2google = (msg, q) ->
	cx = process.env.HUBOT_GOOGLE_CSE_ID
	key = process.env.HUBOT_GOOGLE_CSE_KEY
	if !cx || !key
		msg.send "HUBOT_GOOGLE_CSE_ID か HUBOT_GOOGLE_CSE_KEY が未設定だよ"
		return
	Object.assign(q, { q: query, searchType: 'image', safe: 'off',
	fields: 'items(link)', cx, key })
	url = 'https://www.googleapis.com/customsearch/v1'
	msg.http(url)
		.query(q)
		.get() (err, res, body) ->
			if err
				if res.statusCode is 403
					msg.send "もう今日は取れないみたい。また明日ねー"
					deprecatedImage(msg, query, animated, faces, cb)
				else
					msg.send "（get的に）なんか変！ #{err}"
				return
			if res.statusCode isnt 200
				msg.send "（HTTPステータス的に）なんか変！ #{res.statusCode}"
				return
			response = JSON.parse(body)
			if response?.items
				image = msg.random response.items
				image.link
			else
				msg.send "'#{query}'だけど、うまく見つかんなかった。googleさん調子変かも？"

deprecatedImage = (msg, query, animated, faces) ->
	imgUrl = 'http://i.imgur.com/CzFTOkI.png'
	imgUrl = imgUrl.replace(/\{q\}/, encodeURIComponent(query))
	ensureImageExtension imgUrl

ensureImageExtension = (url) ->
	if /(png|jpe?g|gif)$/i.test(url)
		url
	else
		"#{url}#.png"

