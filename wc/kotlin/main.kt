import java.io.File
import java.io.BufferedReader


var tnwords = 0; var tnchars = 0; var tnrunes = 0; var tnbadrs = 0; var tnlines = 0
var nwords = 0; var nchars = 0; var nrunes = 0; var nbadrs = 0; var nlines = 0
var pwords = 0; var pchars = 0; var prunes = 0; var pbadrs = 0; var plines = 0


fun Boolean.toInt() = if (this) 1 else 0


fun wc(stream: BufferedReader) {
	val Runeerror = 0x80
	var inWord = false

	nwords = 0
	nchars = 0
	nlines = 0

	while (true) {
		var r = stream.read()
		if (r == -1) {
			break;
		}

		nrunes++
		if (r == Runeerror) {
			nbadrs++
			continue
		}

		var c = r.toChar()
		if (c == '\n') {
			nlines++
		}

		if ((inWord) && (c.isWhitespace())) {
			inWord = false
		} else if ((!inWord) && (!c.isWhitespace())) {
			inWord = true
			nwords++
		}

		nchars += (r > 0xFF).toInt() + 1
	}

	tnwords += nwords
	tnchars += nchars
	tnrunes += nrunes
	tnbadrs += nbadrs
	tnlines += nlines
}

fun report(nwords: Int, nchars: Int, nrunes: Int, nbadrs: Int, nlines: Int, filename: String) {
	var output = ""

	if (plines > 0) {
		output += " ${String.format("%7d", nlines)}"
	}
	if (pwords > 0) {
		output += " ${String.format("%7d", nwords)}"
	}
	if (prunes > 0) {
		output += " ${String.format("%7d", nrunes)}"
	}
	if (pbadrs > 0) {
		output += " ${String.format("%7d", nbadrs)}"
	}
	if (pchars > 0) {
		output += " ${String.format("%7d", nchars)}"
	}
	if (filename.length > 0) {
		output += " ${filename}"
	}

	println(output.slice(1..output.length-1))
}

fun main(args: Array<String>) {
	var i = 0
	while (i < args.size) {
		var arg = args[i]
		if (arg[0] == '-') {
			when (arg[1]) {
				'w' -> pwords++
				'c' -> pchars++
				'r' -> prunes++
				'b' -> pbadrs++
				'l' -> plines++
			}
			i++
			continue
		}
		break
	}
	if (pwords+pchars+prunes+pbadrs+plines == 0) {
		pwords = 1
		pchars = 1
		plines = 1
	}

	var nfiles = 0
	if (i == args.size) {
		wc(System.`in`.bufferedReader())
		report(nwords, nchars, nrunes, nbadrs, nlines, "")
	} else {
		while (i + nfiles < args.size) {
			var filename = args[i]

			var stream = File(filename).inputStream().bufferedReader()
			wc(stream)
			report(nwords, nchars, nrunes, nbadrs, nlines, filename)
			stream.close()

			nfiles++
		}

		if (nfiles > 1) {
			report(tnwords, tnchars, tnrunes, tnbadrs, tnlines, "total")
		}
	}
}
