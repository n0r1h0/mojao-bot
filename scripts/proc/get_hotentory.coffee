# Description:
#   はてブホッテントリ取得屋さん
#

request = require 'request'
parser = require 'xml2json'

module.exports =
	hatebuMe: (name, keywords, url, cb) ->
	
		text = "#{name}が今日の#{keywords}系に関するニュースをお知らせするー\n\n"
		msg = [text]

		options =
			url : url
			timeout : 2000
			headers : {'user-agent': 'node title fetcher'}

		request options, (error, response, body) ->
			json = parser.toJson(body, { object : true })

			i = 3
			for val in json["rdf:RDF"]["item"]
				text = "#{val.title}\n\n"
				text = text + "#{val.link}"

				i -= 1
				msg.push(text)
				if i == 0
					cb(msg)
					return
