// Package cov holds the coverage map/hits file formats and the report
// computation shared by the instrumented (runtime) and static modes.
package cov

import (
	"encoding/json"
	"os"
	"path/filepath"
	"strings"

	"github.com/ErickLandim/Mapeamento-Branchs/tools/bcovscan/pascal"
)

// Map describes every coverage item of the instrumented sources.
type Map struct {
	Version   int           `json:"version"`
	Files     []string      `json:"files"`
	Methods   []MapMethod   `json:"methods"`
	Decisions []MapDecision `json:"decisions"`
}

type MapMethod struct {
	ID       int    `json:"id"`
	File     int    `json:"file"`
	Name     string `json:"name"`
	Line     int    `json:"line"`
	Entering bool   `json:"entering"`
}

type MapCond struct {
	ID   int    `json:"id"`
	Pos  int    `json:"pos"`
	Text string `json:"text"`
	Line int    `json:"line"`
	Col  int    `json:"col"`
}

type MapCombo struct {
	Mask uint32 `json:"mask"`
	Vals uint32 `json:"vals"`
	Out  bool   `json:"out"`
}

type MapArm struct {
	Probe    int    `json:"probe"`
	Label    string `json:"label"`
	Line     int    `json:"line"`
	Implicit bool   `json:"implicit"`
}

type MapDecision struct {
	ID     int        `json:"id"`
	Method int        `json:"method"`
	File   int        `json:"file"`
	Kind   string     `json:"kind"`
	Line   int        `json:"line"`
	Col    int        `json:"col"`
	Text   string     `json:"text"`
	Conds  []MapCond  `json:"conds"`
	Combos []MapCombo `json:"combos"`
	Arms   []MapArm   `json:"arms"`
}

// Hits is what the runtime (BCovRT) or the static evaluator writes.
// Every row is [id, counters...].
type Hits struct {
	Version int        `json:"version"`
	Source  string     `json:"source"`
	Dec     [][3]int64 `json:"dec"`   // decision id, true, false
	Cond    [][3]int64 `json:"cond"`  // condition id, true, false
	Combo   [][4]int64 `json:"combo"` // decision id, mask, vals, count
	Hit     [][2]int64 `json:"hit"`   // case probe id, count
	For     [][3]int64 `json:"for"`   // decision id, entered, not entered
	Meth    [][3]int64 `json:"meth"`  // method id, calls, fallthrough
	Path    []PathRow  `json:"path"`
}

type PathRow struct {
	Method int    `json:"m"`
	Sig    string `json:"sig"`
	Count  int64  `json:"n"`
}

func BuildMap(a *pascal.Analysis, root string) *Map {
	m := &Map{Version: 1}
	fileIdx := map[*pascal.Unit]int{}
	for i, u := range a.Units {
		fileIdx[u] = i
		rel, err := filepath.Rel(root, u.Path)
		if err != nil {
			rel = u.Path
		}
		m.Files = append(m.Files, filepath.ToSlash(rel))
	}
	for _, r := range a.Methods {
		m.Methods = append(m.Methods, MapMethod{ID: r.ID, File: fileIdx[a.Owner[r]], Name: pascal.MethodDisplayName(r), Line: r.Line, Entering: r.HasEntering()})
	}
	for _, d := range a.Decisions {
		md := MapDecision{ID: d.ID, Method: d.Routine.ID, File: fileIdx[a.Owner[d.Routine]], Kind: d.Kind, Line: d.Line, Col: d.Col, Text: d.Text,
			Conds: []MapCond{}, Combos: []MapCombo{}, Arms: []MapArm{}}
		if len(d.Conds) > 1 {
			for _, c := range d.Conds {
				md.Conds = append(md.Conds, MapCond{ID: c.ID, Pos: c.Pos, Text: c.Text, Line: c.Line, Col: c.Col})
			}
			for _, c := range d.Combos {
				md.Combos = append(md.Combos, MapCombo{Mask: c.Mask, Vals: c.Vals, Out: c.Outcome})
			}
		}
		for _, arm := range d.Arms {
			md.Arms = append(md.Arms, MapArm{Probe: arm.Probe, Label: arm.Label, Line: arm.Line, Implicit: arm.Impl})
		}
		m.Decisions = append(m.Decisions, md)
	}
	return m
}

func WriteJSON(path string, v any) error {
	data, err := json.MarshalIndent(v, "", "  ")
	if err != nil {
		return err
	}
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	return os.WriteFile(path, append(data, '\n'), 0o644)
}

func ReadJSON(path string, v any) error {
	data, err := os.ReadFile(path)
	if err != nil {
		return err
	}
	// Delphi may write a UTF-8 BOM
	data = []byte(strings.TrimPrefix(string(data), "\uFEFF"))
	return json.Unmarshal(data, v)
}
