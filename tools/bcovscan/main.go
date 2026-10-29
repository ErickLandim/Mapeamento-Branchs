// bcovscan - branch coverage for Delphi without the Delphi compiler.
//
//	bcovscan instrument --root R --src DIR... --out OUT   instrumented copy + bcov.map.json
//	bcovscan scan --root R --src DIR... --tests DIR... --out OUT   static coverage (no compiler)
//	bcovscan report --map M --hits H [--hits H2] --out DIR         report from runtime hits
//	bcovscan compare --a coverage.json --b coverage.json           compare two reports
package main

import (
	"fmt"
	"os"
)

func main() {
	if len(os.Args) < 2 {
		usage()
	}
	var err error
	switch os.Args[1] {
	case "instrument":
		err = cmdInstrument(os.Args[2:])
	case "scan":
		err = cmdScan(os.Args[2:])
	case "report":
		err = cmdReport(os.Args[2:])
	case "compare":
		err = cmdCompare(os.Args[2:])
	case "check":
		err = cmdCheck(os.Args[2:])
	default:
		usage()
	}
	if err != nil {
		fmt.Fprintln(os.Stderr, "bcovscan:", err)
		os.Exit(1)
	}
}

func usage() {
	fmt.Fprintln(os.Stderr, `usage:
  bcovscan instrument --root R --src DIR [--src DIR] --out OUT
  bcovscan scan       --root R --src DIR --tests DIR --out OUT [--detail] [--min-branch N]
  bcovscan report     --map M --hits H [--hits H2] --out DIR [--detail] [--min-branch N]
  bcovscan compare    --a A.json --b B.json
  bcovscan check      --report coverage.json --expected expected.json`)
	os.Exit(2)
}
