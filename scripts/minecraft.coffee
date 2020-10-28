# Description:
#   マインクラフトコマンド群応対用スクリプト
#
# mineproc = require './proc/minecraft_proc'

# module.exports = (robot) ->
# 	# マイクラ起動確認
# 	robot.respond /(minecraft|マイクラ|マインクラフト) *$/i, (res) ->
# 		mineproc.check_exists (ret) ->
# 			if ret == true
# 				res.send("起動してるよ")
# 			else
# 				res.send("起動してないよ")

# 	# マイクラ起動
# 	robot.respond /(minecraft|マイクラ|マインクラフト) *(start|起動|開始|スタート|動かして)$/i, (res) ->
# 		mineproc.check_exists (ret) ->
# 			if ret == true
# 				res.send "もう起動してるよー"
# 				return
# 			res.send "起動するー"
# 			mineproc.start()
# 			res.send """
# 			         多分30秒ぐらいかかるよ
# 			         完了したら教えるね
# 			         """
# 			mineproc.check_standup ->
# 				res.send "起動したよ"

# 	# マイクラ停止
# 	robot.respond /(minecraft|マイクラ|マインクラフト) *(stop|終了|停止|ストップ|止めて)$/i, (res) ->
# 		mineproc.check_exists (ret) ->
# 			if ret != true
# 				res.send "起動してないよー"
# 				return
# 			mineproc.stop ->
# 				res.send "止めたよ"

