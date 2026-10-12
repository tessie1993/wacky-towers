#!/usr/bin/env python3
"""Reproducible structural variety and authored pacing audit; never invents playtest medians."""
from pathlib import Path
import json,hashlib,collections,re
ROOT=Path(__file__).resolve().parents[2]
def clean(v):
 if isinstance(v,dict):return {k:clean(x) for k,x in sorted(v.items()) if k not in ['skin','theme','name','music','seed','story','metadata']}
 if isinstance(v,list):return [clean(x) for x in v]
 return v
catalog=json.loads((ROOT/'assets/data/campaign/catalog.json').read_text())
rows=[];strict=collections.defaultdict(list);families=collections.defaultdict(list)
for e in catalog['levels']:
 d=json.loads((ROOT/e['json'].removeprefix('res://')).read_text());b=d['board'];k=d.get('knobs',{})
 signature=clean({key:d[key] for key in ['board','pieces','goal','knobs','rules']})
 fingerprint=hashlib.sha256(json.dumps(signature,sort_keys=True,separators=(',',':')).encode()).hexdigest()
 strict[fingerprint].append(d['id'])
 family=clean({'dimensions':[b['width'],b['depth'],b['h_play']],'mask':b.get('mask'),'starting':b.get('starting_contents'),'pieces':d['pieces'],'goal':d['goal'],'rules':d['rules'],'controls':{key:v for key,v in k.items() if key.startswith('control.') or key in ['spawn.arrival','clear.detector','clear.collapse']}})
 families[json.dumps(family,sort_keys=True)].append(d['id'])
 area=sum(c=='#' for row in b['mask'] for c in row) if b.get('mask') else b['width']*b['depth']
 bi=catalog['biomes'].index(e['biome'])+1;t=e['tier'];g=float(k.get('fall.g0',.6+.045*(t-1)+.06*(bi-1)))
 row={'id':e['id'],'biome':e['biome'],'tier':t,'area':area,'height':b['h_play'],'goal':d['goal']['type'],'target':d['goal'].get('n',d['goal'].get('h_target',d['goal'].get('t_ms',d['goal'].get('win_correct',0)))),'g0':g,'default_g0':round(.6+.045*(t-1)+.06*(bi-1),3),'rule_ids':[r['id'] for r in d['rules']],'fingerprint':fingerprint,'stars':d.get('stars',{}),'board_geometry':bool(b.get('mask') or b.get('starting_contents'))}
 rows.append(row)
summary=[]
for biome in catalog['biomes']:
 rs=[r for r in rows if r['biome']==biome and r['tier']<=10]
 summary.append({'biome':biome,'mains':len(rs),'goals':dict(collections.Counter(r['goal'] for r in rs)),'board_footprints':len({(r['area'],r['height']) for r in rs}),'distinct_rules':len({x for r in rs for x in r['rule_ids']}),'g0_min':min(r['g0'] for r in rs),'g0_max':max(r['g0'] for r in rs),'geometry_levels':sum(r['board_geometry'] for r in rs)})
out={'schema':1,'levels':rows,'biomes':summary,'strict_unique':len(strict),'structural_families':len(families),'exact_duplicates':[ids for ids in strict.values() if len(ids)>1],'callback_families':[ids for ids in families.values() if len(ids)>1],'survive_time_star_errors':[r['id'] for r in rows if r['goal']=='survive' and ('t2' in r['stars'] or 't3' in r['stars'])],'scope':'Data and design targets only. First-attempt stars, completion medians, camera readability and perceived fairness require human playtest and are NOT ASSESSED.'}
(ROOT/'assets/data/campaign/balance_audit.json').write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps({k:out[k] for k in ['strict_unique','structural_families','exact_duplicates','survive_time_star_errors']}))
