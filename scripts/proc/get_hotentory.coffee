# Description:
#   はてブホッテントリ取得屋さん
#

request = require 'request'
parser = require 'xml2json'

module.exports =
	hatebuMe: (robot, keywords, url, cnt=3) ->
	
		text = "#{robot.name}が今日の#{keywords}系に関するニュースをお知らせするー\n\n"
		msg = [text]

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
				msg.push(text)
				return msg if i == 0
