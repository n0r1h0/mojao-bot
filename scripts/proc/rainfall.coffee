# Description:
#   Yahoo!Japan　気象情報API
#

request = require 'request'
parser = require 'xml2json'

YAHOO_WEATHER_API_URL = "https://map.yahooapis.jp/weather/V1/place"
YAHOO_GEO_API_URL = "https://map.yahooapis.jp/geocode/V1/geoCoder"
module.exports =
	fetchRainfall: (keywords, cb) ->
		fetchGeoCode keywords, (ret) ->
			url = "#{YAHOO_WEATHER_API_URL}" +
			"?coordinates=#{ret.YDF.Feature[0].Geometry.Coordinates}" +
			"&appid=#{process.env.HUBOT_YAHOO_APP_ID}"
			options = { url: url, timeout: 2000, headers: { 'user-agent': 'node title fetcher' } }

			request(options, (error, response, body) ->
				json = parser.toJson(body, { object: true })
				text = "#{ret.YDF.Feature[0].Property.Address} は・・・\n"
				w0 = json.YDF.Feature.Property.WeatherList.Weather[0]
				if w0.Rainfall == 0.0
					text = text + "降ってない"
				else if w0.Rainfall <= 1.00
					text = text + "ちょっと降ってる"
				else if w0.Rainfall <= 10.00
					text = text + "降ってる"
				else
					text = text + "ザーザー降ってる"

				w1 = json.YDF.Feature.Property.WeatherList.Weather[1]
				w2 = json.YDF.Feature.Property.WeatherList.Weather[2]
				w3 = json.YDF.Feature.Property.WeatherList.Weather[3]
				w4 = json.YDF.Feature.Property.WeatherList.Weather[4]
				w5 = json.YDF.Feature.Property.WeatherList.Weather[5]
				w6 = json.YDF.Feature.Property.WeatherList.Weather[6]
				wall = w1 + w2 + w3 + w4 + w5 + w6

				# 晴れてたケース
				if w0.Rainfall == 0.00
					if w1.Rainfall > 0 && w1.Rainfall <= 2
						text = text + "けど、すぐパラパラ来そう。\n"
					else if w1.Rainfall > 2 && w1.Rainfall <= 5
						text = text + "けど、この後急に降ってくるね。\n"
					else if w1.Rainfall > 5
						text = text + "。でも傘は持った方がいいよ。\n"
					else if wall == 0
						text = text + "し、しばらくは降らないみたい。\n"
					else if wall <= 5
						text = text + "けど、少ししたら降るかも。\n"
					else if wall <= 10
						text = text + "のに、これからかなり降るかも。\n"
					else if wall <= 30
						text = text + "。でもこの後ヤバそう。\n"
					else if wall > 30
						text = text + "。でもザーザーくるかも。\n"
					else
						text = text + "。そのあとはよくわかんない。\n"

				# 降ってたケース
				else
					if w1.Rainfall == 0 && wall == 0
						text = text + "けど、すぐ止みそう。\n"
					else if w1.Rainfall == 0 && wall > 0
						text = text + "。すぐに止むけど、また降りそう。\n"
					else if w1.Rainfall > 0 && w0.Rainfall > w1.Rainfall && w0.Rainfall > w6.Rainfall
						text = text + "けど、少し弱まるかな。\n"
					else if w6.Rainfall > 0 && Math.round(w0.Rainfall) == Math.round(w6.Rainfall)
						text = text + "し、しばらく降ってると思う。\n"
					else if Math.round(w0.Rainfall) < Math.round(w6.Rainfall)
						text = text + "。だんだん強くなりそう。\n"
					else if w6.Rainfall == 0
						text = text + "ね。待てば止むかな。\n"
					else
						text = text + "。そのあとはよくわかんない。\n"

				cb text)

fetchGeoCode = (keywords, cb) ->
	url = "#{YAHOO_GEO_API_URL}?appid=#{process.env.HUBOT_YAHOO_APP_ID}&query=#{encodeURI(keywords)}"
	options = { url: url, timeout: 2000, headers: { 'user-agent': 'node title fetcher' } }

	request(options, (error, response, body) ->
		json = parser.toJson(body, { object: true })
		cb json)
