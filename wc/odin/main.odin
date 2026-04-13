package main

import "core:flags"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode"

tnwords, tnchars, tnlines: int
nwords, nchars, nlines: int

options: struct {
	Pwords: bool `args:"name=w"`,
	Pchars: bool `args:"name=c"`,
	Plines: bool `args:"name=l"`,

	overflow: [dynamic]string `usage:"Any extra arguments go here."`,
}

wc :: proc(f: ^os.File) -> (err: os.Error) {
	twoMB :: 2*1024*1024

	nwords = 0; nchars = 0; nlines = 0
	buf := make([]u8, twoMB)
	inWord: bool

	for {
		n, err := os.read(f, buf)
		if n == 0 {
			break
		} else if err != nil {
			return err
		}

		for i := 0; i < n; i += 1 {
			/* TODO(anton2920): read actual runes. */
			r := rune(buf[i])

			if r == '\n' {
				nlines += 1
			}

			if (inWord) && (unicode.is_space(r)) {
				inWord = false
			} else if (!inWord) && (!unicode.is_space(r)) {
				inWord = true
				nwords += 1
			}
		}

		nchars += n
	}

	tnwords += nwords
	tnchars += nchars
	tnlines += nlines

	return nil
}

report :: proc(nwords: int, nchars: int, nlines: int, filename: string) {
	output: strings.Builder

	if options.Plines {
		fmt.sbprintf(&output, " % 7d", nlines)
	}
	if options.Pwords {
		fmt.sbprintf(&output, " % 7d", nwords)
	}
	if options.Pchars {
		fmt.sbprintf(&output, " % 7d", nchars)
	}
	if len(filename) > 0 {
		strings.write_rune(&output, ' ')
		strings.write_string(&output, filename)
	}

	fmt.println(strings.to_string(output))
}

main :: proc() {
	flags.parse_or_exit(&options, os.args)
	if !((options.Pwords) || (options.Pchars) || (options.Plines)) {
		options.Pwords = true; options.Pchars = true; options.Plines = true
	}

	if len(options.overflow) == 0 {
		if err := wc(os.stdin); err != nil {
			fmt.eprintf("failed to process file: %v\n", err)
		}
		report(nwords, nchars, nlines, "")
	} else {
		for filename in options.overflow {
			f, err := os.open(filename)
			if err != nil {
				fmt.eprintf("failed to open file %v\n", err)
			}

			if err := wc(f); err != nil {
				fmt.eprintf("failed to process file: %v\n", err)
			}

			report(nwords, nchars, nlines, filename)
		}

		if len(options.overflow) > 1 {
			report(tnwords, tnchars, tnlines, "total")
		}
	}
}
