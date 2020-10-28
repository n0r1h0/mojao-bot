# Description:
#   はてブホッテントリ取得屋さん
#

request = require 'request'
parser = require 'xml2json'

module.exports =
	hatebuMe: (name, keywords, url, cb) ->
    options =
      url : url
      timeout : 2000
      headers : {'user-agent': 'node title fetcher'}

		request options, (error, response, body) =>
			# console.log(body)
			json = parser.toJson(body, { object : true })

			i = 10
			for val in json["rdf:RDF"]["item"]
				text = "#{val.title}\n"
				text = text + "#{val.link}\n"

				i -= 1
				msg.push(text)
				if i == 0
					cb msg
