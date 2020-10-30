# Description:
#   Dark Skyの呼び出し、戻り値返却
#

request = require 'request'
moment = require 'moment'
yolp = require './yolp'

DARK_SKY_API_URL = "https://dark-sky.p.rapidapi.com"
DARK_SKY_IMAGE_URL = "https://darksky.net/images/weather-icons"

module.exports = {
	fetchWeather: (keywords, cb) ->
		yolp.fetchGeoCode keywords, (ret) ->
			cood = ret.YDF.Feature[0].Geometry.Coordinates.split(',')
			options = {
				method: 'GET',
				url: "#{DARK_SKY_API_URL}/#{cood[1]},#{cood[0]}",
				qs: { lang: 'ja', units: 'auto', exclude: { 'alerts', 'flags' } },
				headers: {
					'x-rapidapi-host': 'dark-sky.p.rapidapi.com',
					'x-rapidapi-key': process.env.HUBOT_DARK_SKY_APP_ID,
					useQueryString: true
				} }

			request options, (error, response, body) ->
				json = JSON.parse(body)
				c = json.currently
				# 現在
				currently = [{
					timezone: json.timezone,
					summary: c.summary,
					temperature: Math.round(c.temperature * 10) / 10,
					humidity: Math.round(c.humidity * 100),
					precipIntensity: Math.round(c.precipIntensity * 100) / 100,
					precipProbability: Math.round(c.precipProbability * 100),
					imageUrl: "#{DARK_SKY_IMAGE_URL}/#{c.icon}.png"
				}]

				# 時間毎
				hourly = []
				for h in json.hourly.data
					hourly.push {
						timezone: json.timezone,
						time: moment.unix(h.time).format("M/D H時"),
						summary: h.summary,
						temperature: Math.round(h.temperature * 10) / 10,
						humidity: Math.round(h.humidity * 100),
						precipIntensity: Math.round(h.precipIntensity * 100) / 100,
						precipProbability: Math.round(h.precipProbability * 100),
						imageUrl: "#{DARK_SKY_IMAGE_URL}/#{h.icon}.png"
					}

				# 日毎
				daily = []
				for d in json.daily.data
					daily.push {
						timezone: json.timezone,
						time: moment.unix(d.time).format("M/D"),
						summary: d.summary,
						temperatureHigh: Math.round(d.temperatureHigh * 10) / 10,
						temperatureLow: Math.round(d.temperatureLow * 10) / 10,
						precipIntensity: Math.round(d.precipIntensity * 100) / 100,
						precipProbability: Math.round(d.precipProbability * 100),
						humidity: Math.round(d.humidity * 100),
						imageUrl: "#{DARK_SKY_IMAGE_URL}/#{d.icon}.png"
					}

				cb currently, hourly, daily
}