fs = require('fs')
filename = '/Work/log.out'

io = require('socket.io').listen(3000)

backlog_size = 2000

io.sockets.on 'connection', (socket)=>
	fs.stat filename, (err, stats)=>
		start = 0
		start = (stats.size - backlog_size) if (stats.size > backlog_size)
		stream = fs.createReadStream(filename, {start: start, end: stats.size})
		stream.addListener("data", (lines)=>socket.emit('output', lines.toString('utf-8').split("\n")))

	fs.watchFile filename, (curr, prev)=>
		return {clear:true} if(prev.size > curr.size)
		stream = fs.createReadStream(filename, { start: prev.size, end: curr.size})
		stream.addListener("data", (lines)=>socket.emit('output', lines.toString('utf-8').split("\n")))




