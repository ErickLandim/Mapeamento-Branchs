unit BCov.Report;

{ Coverage report: map (bcov.map.json) + hits (*.bcovhits.json) -> items.
  Port of tools/bcovscan/cov/report.go. coverage.json has the same schema
  on both sides so "bcovscan compare" can diff them. }

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections, System.Generics.Defaults,
  System.IOUtils, System.Math;

type
  TRatio = record
    Covered, Total: Integer;
    function Percent: Double;
    procedure Add(C: Boolean);
    function ToString: string;
    function Json: string;
  end;

  TSummary = record
    Branch, Cond, Combo, All: TRatio;
    procedure Add(const ACategory: string; C: Boolean);
    function Json: string;
  end;

  TItem = record
    Category: string;
    Method, Decision: Integer;
    FileName: string;
    Line, Col: Integer;
    Kind, LabelText: string;
    Count: Int64;
    Covered: Boolean;
  end;

  TPathRow = record
    Method: Integer;
    Sig: string;
    Count: Int64;
  end;

  TMethodReport = class
  public
    ID: Integer;
    Name, FileName: string;
    Line: Integer;
    Calls: Int64;
    Summary: TSummary;
    Paths: TList<TPathRow>;
    Items: TList<TItem>;
    constructor Create;
    destructor Destroy; override;
  end;

  TCoverageReport = class
  public
    Sources: TStringList;
    Total: TSummary;
    Methods: TObjectList<TMethodReport>;
    Files: TDictionary<string, TSummary>;
    constructor Create;
    destructor Destroy; override;
    /// Builds the report from a map file and one or more hits files.
    procedure Compute(const AMapFile: string; const AHitsFiles: array of string);
    function ToJson: string;
    function ToText(Detail: Boolean): string;
    function ToHtml: string;
  end;

const
  CatBranch = 'branch';
  CatCond = 'condition';
  CatCombo = 'combination';

implementation

uses
  BCov.Analysis;

{ TRatio }

function TRatio.Percent: Double;
begin
  if Total = 0 then
    Result := 100
  else
    Result := Covered * 100 / Total;
end;

procedure TRatio.Add(C: Boolean);
begin
  Inc(Total);
  if C then
    Inc(Covered);
end;

function FmtPct(V: Double): string;
var
  FS: TFormatSettings;
begin
  FS := TFormatSettings.Invariant;
  Result := FormatFloat('0.0', V, FS) + '%';
end;

function TRatio.ToString: string;
begin
  Result := Format('%d/%d (%s)', [Covered, Total, FmtPct(Percent)]);
end;

function JsonNum(V: Double): string;
var
  FS: TFormatSettings;
begin
  FS := TFormatSettings.Invariant;
  Result := FloatToStr(V, FS);
end;

function TRatio.Json: string;
begin
  Result := Format('{"covered": %d, "total": %d, "percent": %s}', [Covered, Total, JsonNum(Percent)]);
end;

{ TSummary }

procedure TSummary.Add(const ACategory: string; C: Boolean);
begin
  if ACategory = CatBranch then
    Branch.Add(C)
  else if ACategory = CatCond then
    Cond.Add(C)
  else if ACategory = CatCombo then
    Combo.Add(C);
  All.Add(C);
end;

function TSummary.Json: string;
begin
  Result := '{"branch": ' + Branch.Json + ', "condition": ' + Cond.Json + ', "combination": ' + Combo.Json +
    ', "all": ' + All.Json + '}';
end;

{ TMethodReport }

constructor TMethodReport.Create;
begin
  inherited Create;
  Paths := TList<TPathRow>.Create;
  Items := TList<TItem>.Create;
end;

destructor TMethodReport.Destroy;
begin
  Paths.Free;
  Items.Free;
  inherited;
end;

{ TCoverageReport }

constructor TCoverageReport.Create;
begin
  inherited Create;
  Sources := TStringList.Create;
  Methods := TObjectList<TMethodReport>.Create(True);
  Files := TDictionary<string, TSummary>.Create;
end;

destructor TCoverageReport.Destroy;
begin
  Sources.Free;
  Methods.Free;
  Files.Free;
  inherited;
end;

function LoadJson(const AFile: string): TJSONValue;
var
  Text: string;
begin
  Text := TFile.ReadAllText(AFile, TEncoding.UTF8);
  if (Text <> '') and (Text[1] = #$FEFF) then
    Delete(Text, 1, 1);
  Result := TJSONObject.ParseJSONValue(Text);
  if Result = nil then
    raise Exception.Create('invalid JSON: ' + AFile);
end;

function Arr(Obj: TJSONValue; const Name: string): TJSONArray;
var
  V: TJSONValue;
begin
  V := TJSONObject(Obj).GetValue(Name);
  if (V = nil) or not (V is TJSONArray) then
    Result := nil
  else
    Result := TJSONArray(V);
end;

function Int(V: TJSONValue): Int64;
begin
  Result := TJSONNumber(V).AsInt64;
end;

type
  TPair2 = record
    A, B: Int64;
  end;

  TCounters = class
  public
    Dec, Cond, ForE, Meth: TDictionary<Integer, TPair2>;
    Hit: TDictionary<Integer, Int64>;
    Combo: TDictionary<string, Int64>;
    Paths: TDictionary<string, TPathRow>;
    constructor Create;
    destructor Destroy; override;
    procedure AddPairs(D: TDictionary<Integer, TPair2>; A: TJSONArray);
    function Get(D: TDictionary<Integer, TPair2>; Id: Integer): TPair2;
  end;

constructor TCounters.Create;
begin
  inherited Create;
  Dec := TDictionary<Integer, TPair2>.Create;
  Cond := TDictionary<Integer, TPair2>.Create;
  ForE := TDictionary<Integer, TPair2>.Create;
  Meth := TDictionary<Integer, TPair2>.Create;
  Hit := TDictionary<Integer, Int64>.Create;
  Combo := TDictionary<string, Int64>.Create;
  Paths := TDictionary<string, TPathRow>.Create;
end;

destructor TCounters.Destroy;
begin
  Dec.Free;
  Cond.Free;
  ForE.Free;
  Meth.Free;
  Hit.Free;
  Combo.Free;
  Paths.Free;
  inherited;
end;

procedure TCounters.AddPairs(D: TDictionary<Integer, TPair2>; A: TJSONArray);
var
  I: Integer;
  Row: TJSONArray;
  P: TPair2;
  Id: Integer;
begin
  if A = nil then
    Exit;
  for I := 0 to A.Count - 1 do
  begin
    Row := TJSONArray(A.Items[I]);
    Id := Int(Row.Items[0]);
    P := Get(D, Id);
    P.A := P.A + Int(Row.Items[1]);
    P.B := P.B + Int(Row.Items[2]);
    D.AddOrSetValue(Id, P);
  end;
end;

function TCounters.Get(D: TDictionary<Integer, TPair2>; Id: Integer): TPair2;
begin
  if not D.TryGetValue(Id, Result) then
  begin
    Result.A := 0;
    Result.B := 0;
  end;
end;

function ComboKey(D, Mask, Vals: Int64): string;
begin
  Result := Format('%d:%d:%d', [D, Mask, Vals]);
end;

function ComboLabel(Mask, Vals: Cardinal; N: Integer; Outcome: Boolean): string;
var
  I: Integer;
begin
  Result := '(';
  for I := 0 to N - 1 do
  begin
    if I > 0 then
      Result := Result + ',';
    if Mask and (Cardinal(1) shl I) = 0 then
      Result := Result + '-'
    else if Vals and (Cardinal(1) shl I) <> 0 then
      Result := Result + 'T'
    else
      Result := Result + 'F';
  end;
  Result := Result + ') => ';
  if Outcome then
    Result := Result + 'T'
  else
    Result := Result + 'F';
end;

procedure TCoverageReport.Compute(const AMapFile: string; const AHitsFiles: array of string);
var
  Map, Hits: TJSONValue;
  Cn: TCounters;
  HF, FileName, Kind, Lbl: string;
  A, Row, Conds, Combos, Arms, FilesArr: TJSONArray;
  I, J, DId, MId, DFile, DLine, DCol, Probe: Integer;
  Obj, D: TJSONObject;
  PR: TPathRow;
  N: Int64;
  ById: TDictionary<Integer, TMethodReport>;
  MR: TMethodReport;
  P2: TPair2;
  It: TItem;
  FileSum: TSummary;
  FileList: TStringList;

  procedure AddItem(const ACat, ALabel: string; ALine, ACol: Integer; ACount: Int64);
  begin
    It.Category := ACat;
    It.Method := MId;
    It.Decision := DId;
    It.FileName := FileName;
    It.Line := ALine;
    It.Col := ACol;
    It.Kind := Kind;
    It.LabelText := ALabel;
    It.Count := ACount;
    It.Covered := ACount > 0;
    MR.Items.Add(It);
  end;

begin
  Cn := TCounters.Create;
  ById := TDictionary<Integer, TMethodReport>.Create;
  FileList := TStringList.Create;
  Map := LoadJson(AMapFile);
  try
    for HF in AHitsFiles do
    begin
      Hits := LoadJson(HF);
      try
        if TJSONObject(Hits).GetValue('source') <> nil then
          Sources.Add(TJSONObject(Hits).GetValue('source').Value);
        Cn.AddPairs(Cn.Dec, Arr(Hits, 'dec'));
        Cn.AddPairs(Cn.Cond, Arr(Hits, 'cond'));
        Cn.AddPairs(Cn.ForE, Arr(Hits, 'for'));
        Cn.AddPairs(Cn.Meth, Arr(Hits, 'meth'));
        A := Arr(Hits, 'hit');
        if A <> nil then
          for I := 0 to A.Count - 1 do
          begin
            Row := TJSONArray(A.Items[I]);
            if not Cn.Hit.TryGetValue(Int(Row.Items[0]), N) then
              N := 0;
            Cn.Hit.AddOrSetValue(Int(Row.Items[0]), N + Int(Row.Items[1]));
          end;
        A := Arr(Hits, 'combo');
        if A <> nil then
          for I := 0 to A.Count - 1 do
          begin
            Row := TJSONArray(A.Items[I]);
            if not Cn.Combo.TryGetValue(ComboKey(Int(Row.Items[0]), Int(Row.Items[1]), Int(Row.Items[2])), N) then
              N := 0;
            Cn.Combo.AddOrSetValue(ComboKey(Int(Row.Items[0]), Int(Row.Items[1]), Int(Row.Items[2])), N + Int(Row.Items[3]));
          end;
        A := Arr(Hits, 'path');
        if A <> nil then
          for I := 0 to A.Count - 1 do
          begin
            Obj := TJSONObject(A.Items[I]);
            PR.Method := Int(Obj.GetValue('m'));
            PR.Sig := Obj.GetValue('sig').Value;
            PR.Count := Int(Obj.GetValue('n'));
            Lbl := IntToStr(PR.Method) + '|' + PR.Sig;
            if Cn.Paths.ContainsKey(Lbl) then
              PR.Count := PR.Count + Cn.Paths[Lbl].Count;
            Cn.Paths.AddOrSetValue(Lbl, PR);
          end;
      finally
        Hits.Free;
      end;
    end;

    FilesArr := Arr(Map, 'files');
    for I := 0 to FilesArr.Count - 1 do
      FileList.Add(FilesArr.Items[I].Value);

    A := Arr(Map, 'methods');
    for I := 0 to A.Count - 1 do
    begin
      Obj := TJSONObject(A.Items[I]);
      MR := TMethodReport.Create;
      MR.ID := Int(Obj.GetValue('id'));
      MR.Name := Obj.GetValue('name').Value;
      MR.FileName := FileList[Int(Obj.GetValue('file'))];
      MR.Line := Int(Obj.GetValue('line'));
      MR.Calls := Cn.Get(Cn.Meth, MR.ID).A;
      Methods.Add(MR);
      ById.Add(MR.ID, MR);
    end;
    for PR in Cn.Paths.Values do
      if ById.TryGetValue(PR.Method, MR) then
        MR.Paths.Add(PR);

    A := Arr(Map, 'decisions');
    for I := 0 to A.Count - 1 do
    begin
      D := TJSONObject(A.Items[I]);
      DId := Int(D.GetValue('id'));
      MId := Int(D.GetValue('method'));
      DFile := Int(D.GetValue('file'));
      DLine := Int(D.GetValue('line'));
      DCol := Int(D.GetValue('col'));
      Kind := D.GetValue('kind').Value;
      FileName := FileList[DFile];
      MR := ById[MId];
      if (Kind = 'if') or (Kind = 'while') then
      begin
        P2 := Cn.Get(Cn.Dec, DId);
        AddItem(CatBranch, 'verdadeiro', DLine, DCol, P2.A);
        AddItem(CatBranch, 'falso', DLine, DCol, P2.B);
      end
      else if Kind = 'repeat' then
      begin
        P2 := Cn.Get(Cn.Dec, DId);
        AddItem(CatBranch, 'until verdadeiro (sai)', DLine, DCol, P2.A);
        AddItem(CatBranch, 'until falso (repete)', DLine, DCol, P2.B);
      end
      else if Kind = 'for' then
      begin
        P2 := Cn.Get(Cn.ForE, DId);
        AddItem(CatBranch, 'entrou no loop', DLine, DCol, P2.A);
        AddItem(CatBranch, 'não entrou no loop', DLine, DCol, P2.B);
      end
      else if Kind = 'case' then
      begin
        Arms := Arr(D, 'arms');
        for J := 0 to Arms.Count - 1 do
        begin
          Obj := TJSONObject(Arms.Items[J]);
          Probe := Int(Obj.GetValue('probe'));
          Lbl := Obj.GetValue('label').Value;
          if Lbl = 'else' then
          begin
            if TJSONBool(Obj.GetValue('implicit')).AsBoolean then
              Lbl := 'else implícito (nenhum rótulo)';
          end
          else
            Lbl := 'rótulo ' + Lbl;
          if not Cn.Hit.TryGetValue(Probe, N) then
            N := 0;
          AddItem(CatBranch, Lbl, Int(Obj.GetValue('line')), DCol, N);
        end;
      end;
      Conds := Arr(D, 'conds');
      for J := 0 to Conds.Count - 1 do
      begin
        Obj := TJSONObject(Conds.Items[J]);
        P2 := Cn.Get(Cn.Cond, Int(Obj.GetValue('id')));
        AddItem(CatCond, Obj.GetValue('text').Value + ' = T', Int(Obj.GetValue('line')), Int(Obj.GetValue('col')), P2.A);
        AddItem(CatCond, Obj.GetValue('text').Value + ' = F', Int(Obj.GetValue('line')), Int(Obj.GetValue('col')), P2.B);
      end;
      Combos := Arr(D, 'combos');
      for J := 0 to Combos.Count - 1 do
      begin
        Obj := TJSONObject(Combos.Items[J]);
        if not Cn.Combo.TryGetValue(ComboKey(DId, Int(Obj.GetValue('mask')), Int(Obj.GetValue('vals'))), N) then
          N := 0;
        AddItem(CatCombo, ComboLabel(Int(Obj.GetValue('mask')), Int(Obj.GetValue('vals')), Conds.Count,
          TJSONBool(Obj.GetValue('out')).AsBoolean), DLine, DCol, N);
      end;
    end;

    A := Arr(Map, 'methods');
    for I := 0 to A.Count - 1 do
    begin
      Obj := TJSONObject(A.Items[I]);
      if not TJSONBool(Obj.GetValue('entering')).AsBoolean then
        Continue;
      MId := Int(Obj.GetValue('id'));
      MR := ById[MId];
      DId := -1;
      Kind := 'method';
      FileName := MR.FileName;
      AddItem(CatBranch, 'nenhum entrou', MR.Line, 1, Cn.Get(Cn.Meth, MId).B);
    end;

    for MR in Methods do
    begin
      MR.Paths.Sort(TComparer<TPathRow>.Construct(
        function(const L, R: TPathRow): Integer
        begin
          Result := CompareStr(L.Sig, R.Sig);
        end));
      if not Files.TryGetValue(MR.FileName, FileSum) then
        FileSum := Default(TSummary);
      for It in MR.Items do
      begin
        MR.Summary.Add(It.Category, It.Covered);
        Total.Add(It.Category, It.Covered);
        FileSum.Add(It.Category, It.Covered);
      end;
      Files.AddOrSetValue(MR.FileName, FileSum);
    end;
  finally
    Map.Free;
    Cn.Free;
    ById.Free;
    FileList.Free;
  end;
end;

function TCoverageReport.ToJson: string;
var
  SB: TStringBuilder;
  I, J: Integer;
  MR: TMethodReport;
  It: TItem;
  Keys: TArray<string>;
  K: string;
begin
  SB := TStringBuilder.Create;
  try
    SB.Append('{').AppendLine;
    SB.Append('  "sources": [');
    for I := 0 to Sources.Count - 1 do
    begin
      if I > 0 then
        SB.Append(', ');
      SB.Append(JsonStr(Sources[I]));
    end;
    SB.Append('],').AppendLine;
    SB.Append('  "total": ').Append(Total.Json).Append(',').AppendLine;
    SB.Append('  "files": {');
    Keys := Files.Keys.ToArray;
    TArray.Sort<string>(Keys);
    for I := 0 to High(Keys) do
    begin
      K := Keys[I];
      if I > 0 then
        SB.Append(', ');
      SB.Append(JsonStr(K)).Append(': ').Append(Files[K].Json);
    end;
    SB.Append('},').AppendLine;
    SB.Append('  "methods": [').AppendLine;
    for I := 0 to Methods.Count - 1 do
    begin
      MR := Methods[I];
      SB.Append('    {"id": ').Append(MR.ID).Append(', "name": ').Append(JsonStr(MR.Name))
        .Append(', "file": ').Append(JsonStr(MR.FileName)).Append(', "line": ').Append(MR.Line)
        .Append(', "calls": ').Append(MR.Calls).Append(', "summary": ').Append(MR.Summary.Json)
        .Append(', "paths": [');
      for J := 0 to MR.Paths.Count - 1 do
      begin
        if J > 0 then
          SB.Append(', ');
        SB.Append('{"m": ').Append(MR.Paths[J].Method).Append(', "sig": ').Append(JsonStr(MR.Paths[J].Sig))
          .Append(', "n": ').Append(MR.Paths[J].Count).Append('}');
      end;
      SB.Append('], "items": [');
      for J := 0 to MR.Items.Count - 1 do
      begin
        It := MR.Items[J];
        if J > 0 then
          SB.Append(',');
        SB.AppendLine;
        SB.Append('      {"category": ').Append(JsonStr(It.Category)).Append(', "method": ').Append(It.Method)
          .Append(', "decision": ').Append(It.Decision).Append(', "file": ').Append(JsonStr(It.FileName))
          .Append(', "line": ').Append(It.Line).Append(', "col": ').Append(It.Col)
          .Append(', "kind": ').Append(JsonStr(It.Kind)).Append(', "label": ').Append(JsonStr(It.LabelText))
          .Append(', "count": ').Append(It.Count).Append(', "covered": ');
        if It.Covered then
          SB.Append('true}')
        else
          SB.Append('false}');
      end;
      SB.Append(']}');
      if I < Methods.Count - 1 then
        SB.Append(',');
      SB.AppendLine;
    end;
    SB.Append('  ]').AppendLine;
    SB.Append('}').AppendLine;
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

function TCoverageReport.ToText(Detail: Boolean): string;
var
  SB: TStringBuilder;
  MR: TMethodReport;
  It: TItem;
  PR: TPathRow;
  Mark: string;
begin
  SB := TStringBuilder.Create;
  try
    SB.Append('Branch coverage : ').Append(Total.Branch.ToString).AppendLine;
    SB.Append('Condition       : ').Append(Total.Cond.ToString).AppendLine;
    SB.Append('Combination     : ').Append(Total.Combo.ToString).AppendLine;
    SB.Append('All items       : ').Append(Total.All.ToString).AppendLine;
    for MR in Methods do
    begin
      if MR.Items.Count = 0 then
        Continue;
      SB.AppendLine;
      SB.AppendFormat('%s:%d %s  branch %s  cond %s  combo %s  calls=%d',
        [MR.FileName, MR.Line, MR.Name, MR.Summary.Branch.ToString, MR.Summary.Cond.ToString,
        MR.Summary.Combo.ToString, MR.Calls]).AppendLine;
      if not Detail then
        Continue;
      for It in MR.Items do
      begin
        if It.Covered then
          Mark := '  [x]'
        else
          Mark := '  [ ]';
        SB.AppendFormat('%s %-11s L%-4d %-6s %s (n=%d)', [Mark, It.Category, It.Line, It.Kind, It.LabelText, It.Count]).AppendLine;
      end;
      for PR in MR.Paths do
        SB.AppendFormat('      caminho %s (n=%d)', [PR.Sig, PR.Count]).AppendLine;
    end;
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

function HtmlEsc(const S: string): string;
begin
  Result := StringReplace(S, '&', '&amp;', [rfReplaceAll]);
  Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
  Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '&quot;', [rfReplaceAll]);
end;

function Cls(const R: TRatio): string;
begin
  if R.Total = 0 then
    Result := 'na'
  else if R.Percent >= 100 then
    Result := 'ok'
  else if R.Percent >= 50 then
    Result := 'mid'
  else
    Result := 'low';
end;

function TCoverageReport.ToHtml: string;
var
  SB: TStringBuilder;
  MR: TMethodReport;
  It: TItem;
  PR: TPathRow;

  procedure Tile(const ATitle: string; const R: TRatio);
  begin
    SB.Append('<div>').Append(ATitle).Append('<b class="').Append(Cls(R)).Append('">').Append(FmtPct(R.Percent))
      .Append('</b>').Append(R.Covered).Append('/').Append(R.Total).Append('</div>');
  end;

begin
  SB := TStringBuilder.Create;
  try
    SB.Append('<!doctype html><html lang="pt-BR"><head><meta charset="utf-8">' +
      '<meta name="viewport" content="width=device-width,initial-scale=1"><title>BCov - cobertura de branches</title><style>' +
      ':root{--bg:#fff;--fg:#1d1d1f;--mut:#666;--line:#ddd;--ok:#1f7a3a;--mid:#9a6700;--low:#b42318;--lowb:#fdecea}' +
      '@media (prefers-color-scheme:dark){:root{--bg:#161618;--fg:#eee;--mut:#9a9a9a;--line:#333;--ok:#4ade80;--mid:#facc15;--low:#f87171;--lowb:#3a1513}}' +
      'body{background:var(--bg);color:var(--fg);font:14px/1.45 system-ui,Segoe UI,sans-serif;margin:0 auto;padding:16px;max-width:1100px}' +
      'h1{font-size:20px;margin:0 0 4px}.mut{color:var(--mut)}.tot{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:8px;margin:16px 0}' +
      '.tot div{border:1px solid var(--line);border-radius:8px;padding:10px}.tot b{display:block;font-size:22px}' +
      '.ok{color:var(--ok)}.mid{color:var(--mid)}.low{color:var(--low)}.na{color:var(--mut)}' +
      'details{border:1px solid var(--line);border-radius:8px;margin:8px 0;padding:6px 10px}summary{cursor:pointer;display:flex;flex-wrap:wrap;gap:12px}' +
      'table{border-collapse:collapse;width:100%;margin:6px 0;font-size:13px}td{border-top:1px solid var(--line);padding:3px 6px}' +
      'tr.u{background:var(--lowb)}.wrap{overflow-x:auto}</style></head><body>');
    SB.Append('<h1>Cobertura de branches (BCov / Delphi)</h1><div class="mut">').Append(HtmlEsc(Sources.CommaText)).Append('</div>');
    SB.Append('<div class="tot">');
    Tile('Branches', Total.Branch);
    Tile('Condições', Total.Cond);
    Tile('Combinações', Total.Combo);
    Tile('Todos os itens', Total.All);
    SB.Append('</div>');
    for MR in Methods do
    begin
      if MR.Items.Count = 0 then
        Continue;
      SB.Append('<details');
      if MR.Summary.All.Percent < 100 then
        SB.Append(' open');
      SB.Append('><summary><code>').Append(HtmlEsc(MR.Name)).Append('</code><span class="mut">')
        .Append(HtmlEsc(MR.FileName)).Append(':').Append(MR.Line).Append('</span>')
        .Append('<span class="').Append(Cls(MR.Summary.Branch)).Append('">branch ').Append(MR.Summary.Branch.Covered).Append('/').Append(MR.Summary.Branch.Total).Append('</span>')
        .Append('<span class="').Append(Cls(MR.Summary.Cond)).Append('">cond ').Append(MR.Summary.Cond.Covered).Append('/').Append(MR.Summary.Cond.Total).Append('</span>')
        .Append('<span class="').Append(Cls(MR.Summary.Combo)).Append('">combo ').Append(MR.Summary.Combo.Covered).Append('/').Append(MR.Summary.Combo.Total).Append('</span>')
        .Append('<span class="mut">chamadas ').Append(MR.Calls).Append('</span></summary><div class="wrap"><table>');
      for It in MR.Items do
      begin
        if It.Covered then
          SB.Append('<tr><td>&#10004;</td>')
        else
          SB.Append('<tr class="u"><td>&#10008;</td>');
        SB.Append('<td>L').Append(It.Line).Append('</td><td>').Append(It.Category).Append('</td><td>').Append(It.Kind)
          .Append('</td><td>').Append(HtmlEsc(It.LabelText)).Append('</td><td>').Append(It.Count).Append('</td></tr>');
      end;
      SB.Append('</table>');
      if MR.Paths.Count > 0 then
      begin
        SB.Append('<div class="mut">Caminhos observados (combinação dos ifs):</div><table>');
        for PR in MR.Paths do
          SB.Append('<tr><td>').Append(HtmlEsc(PR.Sig)).Append('</td><td>').Append(PR.Count).Append('</td></tr>');
        SB.Append('</table>');
      end;
      SB.Append('</div></details>');
    end;
    SB.Append('</body></html>');
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

end.
