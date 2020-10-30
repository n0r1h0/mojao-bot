# Description:
#   Yahoo!Japan　気象情報API
#   fetchRainfal, fetchGeoCodeを展開
#

request = require 'request'
parser = require 'xml2json'

YAHOO_WEATHER_API_URL = "https://map.yahooapis.jp/weather/V1/place"
YAHOO_GEO_API_URL = "https://map.yahooapis.jp/geocode/V1/geoCoder"

module.exports = {
    fetchRainfal: (keywords, cb) ->
        fetchGeoCode keywords, (ret) ->
            url = "#{YAHOO_WEATHER_API_URL}" +
            "?coordinates=#{ret.YDF.Feature[0].Geometry.Coordinates}" +
            "&appid=#{process.env.HUBOT_YAHOO_APP_ID}"
            options = { url: url, timeout: 2000, headers: { 'user-agent': 'node title fetcher' } }

            request(options, (error, response, body) ->
                json = parser.toJson(body, { object: true })
                cb predictRainfall(ret.YDF.Feature[0].Property.Address, json))

    fetchGeoCode: (keywords, cb) ->
        url = "#{YAHOO_GEO_API_URL}" +
        "?appid=#{process.env.HUBOT_YAHOO_APP_ID}" +
        "&query=#{encodeURI(keywords)}"
        options = { url: url, timeout: 2000, headers: { 'user-agent': 'node title fetcher' } }

        request(options, (error, response, body) ->
            json = parser.toJson(body, { object: true })
            cb json)
}

predictRainfall = (address, json) ->
    text = "#{address} は・・・\n"
    wl = json.YDF.Feature.Property.WeatherList

    # 現在
    w0 = Number(wl.Weather[0].Rainfall)
    text = text + predictCurret w0

    # 10分毎の予報
    w1 = Number(wl.Weather[1].Rainfall)
    w2 = Number(wl.Weather[2].Rainfall)
    w3 = Number(wl.Weather[3].Rainfall)
    w4 = Number(wl.Weather[4].Rainfall)
    w5 = Number(wl.Weather[5].Rainfall)
    w6 = Number(wl.Weather[6].Rainfall)
    wall = w1 + w2 + w3 + w4 + w5 + w6

    # 晴れてたケース
    text = text + predictFutureFromSunny(w1, wall) if w0 == 0
    # 降ってたケース
    text = text + predictFutureFromRainny(w1, w6, wall) if w0 > 0

predictCurret = (w0) ->
    "降ってない" if w0 == 0
    "ちょっと降ってる" if 0 < w0 <= 1.00
    "降ってる" if 1.00 < w0 <= 10.00
    "ザーザー降ってる" if 10.00 < w0

predictFutureFromSunny = (w1, wall) ->
    "けど、すぐ降りそう。\n" if 0 < w1
    "し、しばらくは降らないみたい。\n" if wall == 0
    "けど、少ししたら降るかも。\n" if 0 < wall <= 5
    "のに、これからかなり降るかも。\n" if 5 < wall <= 10
    "。でもこの後ヤバそう。\n" if 10 < wall <= 30
    "。でもザーザーくるかも。\n" if 30 < wall

predictFutureFromRainny = (w1, w6, wall) ->
    if w1 == 0
        "けど、すぐ止みそう。\n" if wall == 0
        "。すぐに止むけど、また降りそう。\n" if wall > 0
    else
        if w6 > 0
            "けど、少し弱まってくるかな。\n" if Math.round(w0 * 10) > Math.round(w6 * 10)
            "し、しばらく降ってると思う。\n" if Math.round(w0) == Math.round(w6)
            "。だんだん強くなりそう。\n" if Math.round(w0 * 10) < Math.round(w6 * 10)
        else
            "ね。待てば止むっぽい。\n"
