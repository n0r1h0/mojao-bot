# Description:
#   Dark Skyの呼び出し、戻り値返却
#

request = require 'request'
moment = require 'moment'
yolp = require './yolp'

API_HOST = 'weatherapi-com.p.rapidapi.com'
API_URL = "https://#{API_HOST}/forecast.json"

module.exports = {
	fetchWeather: (keywords, cb) ->
		yolp.fetchGeoCode keywords, (ret) ->
			moment.locale("ja")
			coord = ret.YDF.Feature[0].Geometry.Coordinates.split(',')
			options = {
				method: 'GET',
				url: API_URL,
				qs: { lang: 'ja', days: '3', q: "#{coord[1]},#{coord[0]}" },
				headers: {
					'x-rapidapi-host': API_HOST,
					'x-rapidapi-key': process.env.RAPIDAPI_KEY,
					useQueryString: true
				}
			}

			request options, (error, response, body) ->
				json = JSON.parse(body)
				city = json.location
				list = json.forecast.forecastday
				# 現在
				currently = [{
					date: moment.unix(list[0].date_epoch).format('M/D(ddd)'),
					cityname: city.name,
					summary: list[0].day.condition.text,
					maxTemperature: list[0].day.maxtemp_c,
					minTemperature: list[0].day.mintemp_c,
					humidity: list[0].day.humidity,
					precipIntensity: list[0].day.totalprecip_mm,
					precipProbability: list[0].day.daily_chance_of_rain,
					imageUrl: "https:#{list[0].day.condition.icon}"
				}]

				current = moment().add(3, 'd')
				getForwardDay = (dt, list, cb) ->
					options.qs.dt = dt.format('YYYY-MM-DD')
					request options, (error, response, body) ->
						json = JSON.parse(body)
						marge = list.concat(json.forecast.forecastday)
						if dt.diff(moment(), 'd') < 6
							dt = dt.add(1, 'd')
							getForwardDay(dt, marge, cb)
						else
							cb(marge)

				getForwardDay(current, list, (marge) ->
					# 日毎
					daily = []
					# 時間毎
					hourly = []
					for d in marge
						daily.push {
							date: moment.unix(d.date_epoch).format('M/D(ddd)'),
							cityname: city.name,
							summary: d.day.condition.text,
							maxTemperature: d.day.maxtemp_c,
							minTemperature: d.day.mintemp_c,
							humidity: d.day.humidity,
							precipIntensity: d.day.totalprecip_mm,
							precipProbability: d.day.daily_chance_of_rain,
							imageUrl: "https:#{d.day.condition.icon}"
						}

						for h in d.hour
							hourly.push {
								date: moment.unix(h.time_epoch).format('M/D(ddd) H時'),
								cityname: city.name,
								summary: h.condition.text,
								temperature: h.temp_c,
								humidity: h.humidity,
								precipIntensity: h.precip_mm,
								precipProbability: h.chance_of_rain,
								imageUrl: "https:#{h.condition.icon}"
							}

					cb currently, hourly, daily
				)
}