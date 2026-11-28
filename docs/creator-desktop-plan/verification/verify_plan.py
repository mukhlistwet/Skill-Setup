"""Validate planning artifacts only. This does not build or exercise the app."""
if not __debug__:
    raise SystemExit('verify_plan.py requires assertions; rerun without -O, -OO, or PYTHONOPTIMIZE.')

from pathlib import Path
from html.parser import HTMLParser
from html import unescape
import ast
import csv
import json
import re
import sqlite3
import struct
import subprocess
import sys
import xml.etree.ElementTree as ET

ROOT=Path(__file__).resolve().parent.parent
DOCS=['00-README.txt','01-PRD.txt','02-FLOWS-AND-USE-CASES.txt','03-ARCHITECTURE.txt','04-DATABASE.txt','05-INTEGRATION-CONTRACTS.txt','06-DELIVERY-AND-QA.txt','07-SOURCE-NOTES.txt','08-PRODUCTION-LANES.txt']
REQUIRED=DOCS+['index.html','diagrams.html','requirements.csv','schema/001-initial.sql','schema/verify_schema.py','schema/data-dictionary.csv','diagrams/architecture.mmd','diagrams/user-flow.mmd','diagrams/job-state.mmd','diagrams/database-full.mmd','diagrams/use-cases.puml','verification/test_verify_plan.py']

class LocalHTML(HTMLParser):
    def __init__(self):super().__init__();self.ids=[];self.hrefs=[];self.scripts=0;self.remote=[]
    def handle_starttag(self,tag,attrs):
        a=dict(attrs)
        if 'id' in a:self.ids.append(a['id'])
        if 'href' in a:self.hrefs.append(a['href'])
        if tag=='script':self.scripts+=1
        for key in ('src','href'):
            if a.get(key,'').startswith(('http:','https:','//')):self.remote.append(a[key])

def verify():
    for name in REQUIRED:assert (ROOT/name).is_file(),name
    with (ROOT/'requirements.csv').open(encoding='utf-8',newline='') as handle:req=list(csv.DictReader(handle))
    ids=[r['requirement_id'] for r in req]
    expected={f'FR-{n:02d}' for n in range(1,28)}|{f'NFR-{n:02d}' for n in range(1,10)}
    assert len(ids)==len(set(ids)) and set(ids)==expected
    uml=(ROOT/'diagrams/use-cases.puml').read_text(encoding='utf-8')
    cases={f'UC-{n:02d}' for n in range(1,11)}
    assert set(re.findall(r'UC-\d{2}',uml))==cases
    for r in req:
        assert (ROOT/r['design_ref']).is_file(),r
        assert r['implementation_status']=='NOT_IMPLEMENTED' and r['verification_status']=='DESIGN_ONLY'
        assert r['acceptance_criterion'] and r['planned_test_id']
        if r['use_case']!='CROSS_CUTTING':assert set(r['use_case'].split(';'))<=cases
    conn=sqlite3.connect(':memory:');conn.executescript((ROOT/'schema/001-initial.sql').read_text(encoding='utf-8'))
    tables=[r[0] for r in conn.execute("SELECT name FROM sqlite_schema WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name")]
    actual_columns={(table,r[1]) for table in tables for r in conn.execute(f'PRAGMA table_info({table})')}
    with (ROOT/'schema/data-dictionary.csv').open(encoding='utf-8',newline='') as handle:dictionary=list(csv.DictReader(handle))
    assert actual_columns=={(r['table'],r['column']) for r in dictionary}
    foreign_keys=sum(len(list(conn.execute(f'PRAGMA foreign_key_list({table})'))) for table in tables)
    erd=(ROOT/'diagrams/database-full.mmd').read_text(encoding='utf-8')
    assert len([line for line in erd.splitlines() if ' : "' in line])==foreign_keys
    assert all(re.search(r'^  '+re.escape(table)+r' \{',erd,re.M) for table in tables)
    assert conn.execute('PRAGMA integrity_check').fetchone()[0]=='ok'
    assert conn.execute('PRAGMA foreign_key_check').fetchall()==[]
    conn.close()
    process=subprocess.run([sys.executable,str(ROOT/'schema/verify_schema.py')],capture_output=True,text=True)
    assert process.returncode==0,(process.stdout,process.stderr)
    schema=json.loads((ROOT/'verification/schema-tests.json').read_text(encoding='utf-8'))
    test_ast=ast.parse((ROOT/'schema/verify_schema.py').read_text(encoding='utf-8'))
    test_count=sum(isinstance(n,(ast.FunctionDef,ast.AsyncFunctionDef)) and n.name.startswith('test_') for n in ast.walk(test_ast))
    assert schema['passed'] and schema['tests_run']==test_count and schema['errors']==0 and schema['failures']==0
    html_checks=[]
    for name in ('index.html','diagrams.html'):
        page=(ROOT/name).read_text(encoding='utf-8');parser=LocalHTML();parser.feed(page)
        assert not parser.scripts and not parser.remote,(name,parser.remote)
        assert len(parser.ids)==len(set(parser.ids)),name
        for href in parser.hrefs:
            if href.startswith('#'):assert href[1:] in parser.ids,(name,href)
            else:assert (ROOT/href).is_file(),(name,href)
        html_checks.append(name)
    viewer=(ROOT/'index.html').read_text(encoding='utf-8')
    embedded=[unescape(s) for s in re.findall(r'<pre>(.*?)</pre>',viewer,re.S)]
    assert embedded==[(ROOT/name).read_text(encoding='utf-8') for name in DOCS], 'Viewer out of date'
    svgs=re.findall(r'<svg\b.*?</svg>',(ROOT/'diagrams.html').read_text(encoding='utf-8'),re.S)
    assert len(svgs)==4
    for svg in svgs:ET.fromstring(svg)
    usecase_svg=next(s for s in svgs if 'Use case diagram with operator' in s)
    assert cases<=set(re.findall(r'UC-\d{2}',usecase_svg))
    image_checks=[]
    for key in ('architecture','use-cases','user-flow','database'):
        shot=ROOT/'verification'/f'preview-{key}.png'
        data=shot.read_bytes();assert data[:8]==b'\x89PNG\r\n\x1a\n'
        width,height=struct.unpack('>II',data[16:24]);assert width==1480 and height==1600
        image_checks.append({'diagram':key,'width':width,'height':height})
    master=json.loads((ROOT/'research/sources-ledger.json').read_text(encoding='utf-8'))
    source_map={s['id']:s['url'] for s in master['sources']};cited=set()
    for name in DOCS:
        text=(ROOT/name).read_text(encoding='utf-8');body=text.split('\nSources:')[0]
        used={int(n) for n in re.findall(r'\[(\d+)\]',body)};cited|=used
        for ident in used:
            assert ident in source_map,(name,ident)
            assert source_map[ident] in text.split('\nSources:')[-1],(name,ident)
    return {'scope':'PLANNING_ARTIFACTS_ONLY','passed':True,'documents':len(DOCS),'functional_requirements':sum(i.startswith('FR-') for i in ids),'nonfunctional_requirements':sum(i.startswith('NFR-') for i in ids),'use_cases':len(cases),'schema_tables':len(tables),'schema_columns':len(actual_columns),'schema_foreign_keys':foreign_keys,'schema_tests_passed':schema['tests_run'],'sqlite_fixture_runtime':schema['sqlite_version'],'offline_html_files_checked':html_checks,'svg_diagrams_xml_checked':len(svgs),'browser_pngs_checked':image_checks,'cited_primary_source_ids':sorted(cited),'not_run':['Rust/Tauri implementation/build','Desktop UI E2E','Live Chrome/Flow connection','Live MCP handshake','Provider generation/upload','Production video render and audiovisual QA','Multi-process concurrency','Full media workspace migration/restore','PlantUML or Mermaid runtime rendering','Commission/revenue validation']}

if __name__=='__main__':
    summary=verify()
    output=ROOT/'verification/plan-validation.json'
    output.write_text(json.dumps(summary,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(summary,ensure_ascii=False,indent=2))
