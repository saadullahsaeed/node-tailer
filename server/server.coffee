filename = process.argv[2]
unless filename
	console.log "Filename not specified."
	process.exit 1

fs = require 'fs'
io = require('socket.io').listen(3000)

Tailer =
	backlog_size: 2000

	createStream: (filename, socket, start, end)->
		stream = fs.createReadStream filename, {start: start, end: end}
		stream.addListener 'data', (lines)=>
			socket.emit 'output', lines.toString('utf-8').split "\n"


io.sockets.on 'connection', (socket)=>
	fs.stat filename, (err, stats)=>
		start = 0
		start = stats.size - Tailer.backlog_size if stats.size > Tailer.backlog_size
		Tailer.createStream filename, socket, start, stats.size

	fs.watchFile filename, (curr, prev)=>
		return if prev.size > curr.size
		Tailer.createStream filename, socket, prev.size, curr.size
