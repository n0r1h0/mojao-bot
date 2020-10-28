# Description:
#   Yahoo!Japan　気象情報API
#

request = require 'request'
parser = require 'xml2json'
moment = require 'moment'

YAHOO_GEO_API_URL = "https://map.yahooapis.jp/geocode/V1/geoCoder"
DARK_SKY_API_URL = "https://dark-sky.p.rapidapi.com"
DARK_SKY_IMAGE_URL = "https://darksky.net/images/weather-icons"

fetchGeoCode = (keywords, cb) ->
	url = "#{YAHOO_GEO_API_URL}?appid=#{process.env.HUBOT_YAHOO_APP_ID}&query=#{encodeURI(keywords)}"
	options = { url: url, timeout: 2000, headers: { 'user-agent': 'node title fetcher' } }

	request(options, (error, response, body) ->
		json = parser.toJson(body, { object: true })
		cb json)

module.exports =
	fetchWeather: (keywords, cb) ->
		fetchGeoCode keywords, (ret) ->
			cood = ret.YDF.Feature[0].Geometry.Coordinates.split(',')
			options =
				method: 'GET',
				url: "#{DARK_SKY_API_URL}/#{cood[1]},#{cood[0]}",
				qs: { lang: 'ja', units: 'auto' },
				headers: {
					'x-rapidapi-host': 'dark-sky.p.rapidapi.com',
					'x-rapidapi-key': process.env.HUBOT_DARK_SKY_APP_ID,
					useQueryString: true
				}

			request(options, (error, response, body) ->
				json = JSON.parse(body)
				currently = ["#{json.timezone} の現在の天気",
				"#{json.currently.summary}\n" +
				"#{DARK_SKY_IMAGE_URL}/#{json.currently.icon}.png\n" +
				"気温：#{json.currently.temperature}\n" +
				"降水量：#{json.currently.precipIntensity}mm\n" +
				"降水確率：#{Math.round(json.currently.precipProbability * 100)}%\n" +
				"湿度：#{Math.round(json.currently.humidity * 100)}%"]

				i = 0
				hourly = []
				for h in json.hourly.data
					if i % 3 == 0
						hourly.push "#{moment.unix(h.time).format("M/D H:mm")}\n" +
						"#{h.summary}\n" +
						"#{DARK_SKY_IMAGE_URL}/#{h.icon}.png\n" +
						"気温：#{h.temperature}℃\n" +
						"降水量：#{h.precipIntensity}mm\n" +
						"降水確率：#{Math.round(h.precipProbability * 100)}%\n" +
						"湿度：#{Math.round(h.humidity * 100)}%\n"
					i = i + 1

				daily = []
				for d in json.daily.data
					daily.push "#{moment.unix(d.time).format("M/D")}\n" +
					"#{d.summary}\n" +
					"#{DARK_SKY_IMAGE_URL}/#{d.icon}.png\n" +
					"最高気温：#{d.temperatureHigh}℃\n" +
					"最低気温：#{d.temperatureLow}℃\n" +
					"降水量：#{d.precipIntensity}mm\n" +
					"降水確率：#{Math.round(d.precipProbability * 100)}%\n" +
					"湿度：#{Math.round(d.humidity * 100)}%\n"

				cb currently, hourly, daily)
