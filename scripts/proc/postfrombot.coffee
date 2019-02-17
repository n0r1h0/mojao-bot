# Description:
#   メッセージをbotから送信する用
#

request = require 'request'

config = baseUrl: 'http://localhost:8080'

_room = ''
constructor: (room) ->
	_room = room

send_message = (msg) ->
	request.post
		url: config.baseUrl + '/hubot/say'
		form:
			room: _room
			message: msg
	, (err, response, body) ->
		throw err if err

