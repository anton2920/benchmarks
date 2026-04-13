package main

import "core:bufio"
import "core:flags"
import "core:fmt"
import "core:io"
import "core:os"
import "core:strings"
import "core:unicode"
import "core:unicode/utf8"

tnwords, tnchars, tnrunes, tnbadrs, tnlines: int
nwords, nchars, nrunes, nbadrs, nlines: int

options: struct {
	Pwords: bool `args:"name=w"`,
	Pchars: bool `args:"name=c"`,
	Prunes: bool `args:"name=r"`,
	Pbadrs: bool `args:"name=b"`,
	Plines: bool `args:"name=l"`,

	overflow: [dynamic]string `usage:"Any extra arguments go here."`,
}

wc :: proc(reader: ^bufio.Reader) -> (err: os.Error) {
	twoMB :: 2*1024*1024

	nwords = 0; nchars = 0; nlines = 0
	buf := make([]u8, twoMB)
	inWord: bool

	for {
		r, size, err := bufio.reader_read_rune(reader)
		if err == io.Error.EOF {
			break
		} else if err != nil {
			return err
		}

		nrunes += 1
		if r == utf8.RUNE_ERROR {
			nbadrs += 1
			continue
		}
		if r == '\n' {
			nlines += 1
		}

		if (inWord) && (unicode.is_space(r)) {
			inWord = false
		} else if (!inWord) && (!unicode.is_space(r)) {
			inWord = true
			nwords += 1
		}

		nchars += size
	}

	tnwords += nwords
	tnchars += nchars
	tnlines += nlines

	return nil
}

report :: proc(nwords: int, nchars: int, nrunes: int, nbadrs: int, nlines: int, filename: string) {
	output: strings.Builder

	if options.Plines {
		fmt.sbprintf(&output, " % 7d", nlines)
	}
	if options.Pwords {
		fmt.sbprintf(&output, " % 7d", nwords)
	}
	if options.Prunes {
		fmt.sbprintf(&output, " % 7d", nrunes)
	}
	if options.Pbadrs {
		fmt.sbprintf(&output, " % 7d", nbadrs)
	}
	if options.Pchars {
		fmt.sbprintf(&output, " % 7d", nchars)
	}
	if len(filename) > 0 {
		strings.write_rune(&output, ' ')
		strings.write_string(&output, filename)
	}

	fmt.println(strings.to_string(output)[1:])
}

main :: proc() {
	reader: bufio.Reader

	flags.parse_or_exit(&options, os.args)
	if !((options.Pwords) || (options.Pchars) || (options.Plines)) {
		options.Pwords = true; options.Pchars = true; options.Plines = true
	}

	if len(options.overflow) == 0 {
		bufio.reader_init(&reader, os.to_stream(os.stdin))
		if err := wc(&reader); err != nil {
			fmt.eprintf("failed to process file: %v\n", err)
			os.exit(1)
		}
		report(nwords, nchars, nrunes, nbadrs, nlines, "")
	} else {
		for filename in options.overflow {
			f, err := os.open(filename)
			if err != nil {
				fmt.eprintf("failed to open file: %v\n", err)
				os.exit(1)
			}

			bufio.reader_init(&reader, os.to_stream(f))
			if err := wc(&reader); err != nil {
				fmt.eprintf("failed to process file: %v\n", err)
				os.exit(1)
			}

			report(nwords, nchars, nrunes, nbadrs, nlines, filename)
		}

		if len(options.overflow) > 1 {
			report(tnwords, tnchars, tnrunes, tnbadrs, tnlines, "total")
		}
	}
}
