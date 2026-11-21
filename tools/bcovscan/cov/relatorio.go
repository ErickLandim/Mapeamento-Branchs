package cov

import (
	"encoding/json"
	"html"
	"strings"
	"time"
)

// Info é o que o cabeçalho do relatório único mostra além das abas.
type Info struct {
	Modo   string   // descrição do escopo, ex.: "Diff do MR: só métodos novos"
	Status string   // "", "ok", "aviso" ou "bloqueio" (resultado do mínimo de cobertura)
	Aviso  string   // frase do resultado do mínimo
	Notas  []string // linhas extras (base do diff, filtros, etc.)
}

// RenderRelatorio junta as três visões numa página só, uma por aba. Cada aba é
// uma página completa isolada (iframe), montada só quando é aberta.
func RenderRelatorio(info Info, resumo, cobertura, rastreio []byte) []byte {
	docs, _ := json.Marshal([]string{string(resumo), string(rastreio), string(cobertura)})
	var notas strings.Builder
	for _, n := range info.Notas {
		notas.WriteString("<div>" + html.EscapeString(n) + "</div>")
	}
	status := ""
	if info.Aviso != "" {
		cls := info.Status
		if cls == "" {
			cls = "ok"
		}
		status = `<div class="st ` + cls + `">` + html.EscapeString(info.Aviso) + `</div>`
	}
	page := relatorioTpl
	page = strings.Replace(page, "__MODO__", html.EscapeString(info.Modo), 1)
	page = strings.Replace(page, "__QUANDO__", time.Now().Format("02/01/2006 15:04"), 1)
	page = strings.Replace(page, "__NOTAS__", notas.String(), 1)
	page = strings.Replace(page, "__STATUS__", status, 1)
	page = strings.Replace(page, "__DOCS__", string(docs), 1)
	return []byte(page)
}

const relatorioTpl = `<!doctype html>
<html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>BCov - Relatório de cobertura</title>
<style>
:root{--bg:#fff;--fg:#1d1d1f;--mut:#666;--line:#ddd;--ac:#2563eb;--ok:#1f7a3a;--mid:#9a6700;--low:#b42318;--okb:#e8f5ec;--midb:#fff4d6;--lowb:#fdecea}
@media (prefers-color-scheme:dark){:root{--bg:#161618;--fg:#eee;--mut:#9a9a9a;--line:#333;--ac:#60a5fa;--ok:#4ade80;--mid:#facc15;--low:#f87171;--okb:#12301d;--midb:#3a3112;--lowb:#3a1513}}
*{box-sizing:border-box}
html,body{height:100%;margin:0}
body{background:var(--bg);color:var(--fg);font:14px/1.45 system-ui,Segoe UI,sans-serif;display:flex;flex-direction:column}
header{padding:10px 16px 0;border-bottom:1px solid var(--line)}
h1{font-size:18px;margin:0}
.mut{color:var(--mut);font-size:12px}
.st{margin:8px 0 0;padding:6px 10px;border-radius:6px;font-weight:600}
.st.ok{background:var(--okb);color:var(--ok)}
.st.aviso{background:var(--midb);color:var(--mid)}
.st.bloqueio{background:var(--lowb);color:var(--low)}
nav{display:flex;gap:2px;margin-top:8px}
nav button{font:inherit;background:none;border:0;border-bottom:3px solid transparent;color:var(--mut);padding:8px 16px;cursor:pointer}
nav button:hover{color:var(--fg)}
nav button.on{color:var(--ac);border-bottom-color:var(--ac);font-weight:600}
main{flex:1;min-height:0;position:relative}
iframe{position:absolute;inset:0;width:100%;height:100%;border:0;display:none;background:var(--bg)}
iframe.on{display:block}
</style></head><body>
<header>
<h1>Relatório de cobertura</h1>
<div class="mut">Gerado em __QUANDO__ · __MODO__</div>
<div class="mut">__NOTAS__</div>
__STATUS__
<nav id="abas"></nav>
</header>
<main id="m"></main>
<script type="application/json" id="docs">__DOCS__</script>
<script>
(function(){
  var docs=JSON.parse(document.getElementById('docs').textContent);
  var abas=[['resumo','Resumo'],['rastreio','Rastreio'],['cobertura','Cobertura']];
  var nav=document.getElementById('abas'),main=document.getElementById('m'),frames={},btns={};
  function abrir(i){
    abas.forEach(function(a,k){
      btns[k].classList.toggle('on',k===i);
      if(frames[k])frames[k].classList.toggle('on',k===i);
    });
    if(!frames[i]){
      var f=document.createElement('iframe');
      f.title=abas[i][1];f.srcdoc=docs[i];main.appendChild(f);frames[i]=f;f.classList.add('on');
    }
    try{history.replaceState(null,'','#'+abas[i][0])}catch(e){}
  }
  abas.forEach(function(a,k){
    var b=document.createElement('button');b.textContent=a[1];
    b.addEventListener('click',function(){abrir(k)});
    nav.appendChild(b);btns[k]=b;
  });
  var h=(location.hash||'').slice(1),ini=0;
  abas.forEach(function(a,k){if(a[0]===h)ini=k});
  abrir(ini);
})();
</script>
</body></html>`
