# Description:
#   はてブホッテントリ取得屋さん
#

request = require 'request'
parser = require 'xml2json'

module.exports = {
	hatebuMe: (name, keywords, url, cb) ->
		options = { url: url, timeout: 2000, headers: { 'user-agent': 'node title fetcher' } }

		request(options, (error, response, body) ->
			json = parser.toJson(body, { object: true })
			text = []
			i = 10
			for val in json["rdf:RDF"]["item"]
				text.push { title: val.title, link: val.link }
				i -= 1
				if i == 0
					cb text
					return)
}