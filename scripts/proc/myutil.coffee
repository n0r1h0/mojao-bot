# 間隔調整用
sleep = (ms)->
	date = new Date()
	loop
		break if (new Date())-date > ms