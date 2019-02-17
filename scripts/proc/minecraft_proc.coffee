# Description:
#   マインクラフトサーバの起動、停止をコマンドに送信してみる群
#

proc = require 'child_process'
util = require './myutil'

module.exports =
	# 起動済みをチェック
	check_exists: (cb) ->
		command = "ps aux | grep -s '[m]inecraft'"
		proc.exec command, (error, stdout, stderr) ->
			cb(!error?)

	# 開始コマンドを送信
	start: () ->
		@check_exists (ret) ->
			if ret == true
				return
			proc.exec "/home/$USER/startmc.sh", (error, stdout, stderr) ->

	# 停止コマンドを送信
	stop: (cb) ->
		command = "screen -S minecraft -X stuff 'stop\n\r'"
		proc.exec command, (error, stdout, stderr) ->
			cb(!error?)

	# 起動完了を監視
	check_standup: (cb) ->
	# 起動済みをチェック
	check_exists: (cb) ->
		command = "ps aux | grep -s '[m]inecraft'"
		proc.exec command, (error, stdout, stderr) ->
			cb(!error?)

	# 開始コマンドを送信
	start: () ->
		@check_exists (ret) ->
			if ret == true
				return
			proc.exec "/home/$USER/startmc.sh", (error, stdout, stderr) ->

	# 停止コマンドを送信
	stop: (cb) ->
		command = "screen -S minecraft -X stuff 'stop\n\r'"
		proc.exec command, (error, stdout, stderr) ->
			cb(!error?)

	# 起動完了を監視
	check_standup: (cb) ->
		d = new Date
		util.sleep 3000
		f = "/home/nori/logs/screen-#{d.getFullYear()}#{d.getMonth()+1}#{d.getDate()}.log"
		tail = proc.spawn "tail", ["-f", f]
		console.log("called")
		tail.stdout.on 'data', (data) ->
			if data.toString().indexOf("Done") > -1
				cb()
				proc.exec "rm #{f}", (error, stdout, stderr) ->
				tail.kill()
