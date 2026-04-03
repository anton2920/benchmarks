import java.io.File
import java.io.BufferedInputStream


var tnwords = 0; var tnchars = 0; var tnlines = 0
var nwords = 0; var nchars = 0; var nlines = 0
var pwords = 0; var pchars = 0; var plines = 0


fun wc(stream: BufferedInputStream) {
	val twoMB = 2 * 1024 * 1024
	var buf = ByteArray(twoMB)

	var inWord = false

	nwords = 0
	nchars = 0
	nlines = 0

	stream.use { input ->
		while (true) {
			var n = input.read(buf)
			if (n <= 0) {
				break
			}

			var i = 0
			while (i < n) {
				var c: Char = buf[i].toInt().toChar()

				if ((inWord) && (c.isWhitespace())) {
					inWord = false
				} else if ((!inWord) && (!c.isWhitespace())) {
					inWord = true
					nwords++
				}

				if (c == '\n') {
					nlines++
				}

				i++
			}

			nchars += n
		}
	}

	tnwords += nwords
	tnchars += nchars
	tnlines += nlines
}

fun report(nwords: Int, nchars: Int, nlines: Int, filename: String) {
	var output = ""

	if (plines > 0) {
		output += " ${String.format("%7d", nlines)}"
	}
	if (pwords > 0) {
		output += " ${String.format("%7d", nwords)}"
	}
	if (pchars > 0) {
		output += " ${String.format("%7d", nchars)}"
	}
	if (filename.length > 0) {
		output += " ${filename}"
	}

	println(output)
}

fun main(args: Array<String>) {
	var i = 0
	while (i < args.size) {
		var arg = args[i]
		if (arg[0] == '-') {
			when (arg[1]) {
				'w' -> pwords++
				'c' -> pchars++
				'l' -> plines++
			}
			i++
			continue
		}
		break
	}
	if (pwords+pchars+plines == 0) {
		pwords = 1
		pchars = 1
		plines = 1
	}

	var nfiles = 0
	if (i == args.size) {
		wc(System.`in`.buffered())
		report(nwords, nchars, nlines, "")
	} else {
		while (i + nfiles < args.size) {
			var filename = args[i]

			var stream = File(filename).inputStream().buffered()
			wc(stream)
			report(nwords, nchars, nlines, filename)
			stream.close()

			nfiles++
		}

		if (nfiles > 1) {
			report(tnwords, tnchars, tnlines, "total")
		}
	}
}
