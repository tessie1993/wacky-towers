#!/usr/bin/env python3
"""Find deterministic constructive packings for authored finite shape puzzles.
Checks exact oriented cells, flavour targets, fixed order/kit inventory, collision-free
vertical ingress, gravity support, and actual mirror overwrite-skip semantics.
Does not prove a human can execute the input sequence under the star timer.
"""
from pathlib import Path
import json,re,time,collections
ROOT=Path(__file__).resolve().parents[2]
SHAPES={}
for b in (ROOT/'assets/data/shapes/shape_bank.tres').read_text().split('[sub_resource'):
 m=re.search(r'shape_id = &"([^"]+)"',b)
 if not m:continue
 line=re.search(r'^offsets_by_orient = (.*)$',b,re.M).group(1)
 orientations=[];seen=set()
 for oi,raw in enumerate(re.findall(r'Array\[Vector3i\]\(\[(.*?)\]\)',line)):
  offsets=[tuple(map(int,m)) for m in re.findall(r'Vector3i\((-?\d+), (-?\d+), (-?\d+)\)',raw)]
  low=tuple(min(c[a] for c in offsets) for a in range(3))
  normalized=tuple(sorted(tuple(c[a]-low[a] for a in range(3)) for c in offsets))
  if normalized not in seen:orientations.append((oi,offsets,low,normalized));seen.add(normalized)
 SHAPES[m.group(1)]=orientations

def solve(d,deadline=15):
 start=time.monotonic();b=d['board'];target={}
 for y,rows in d['goal']['target_shape']['layers'].items():
  for z,row in enumerate(rows):
   for x,g in enumerate(row):
    if g!='.':target[(x,int(y),z)]={'P':1,'V':2,'M':3}.get(g,0)
 cells=sorted(target,key=lambda c:(c[1],c[2],c[0]));ids={c:i for i,c in enumerate(cells)};allmask=(1<<len(cells))-1
 p=d['pieces'];kit=bool(p.get('kit'));seq=p.get('kit') or p.get('fixed_list');hues=p.get('fixed_hues',[]);mirror=next((0 if r.get('params',{}).get('mirror_axis','x')=='x' else 2 for r in d.get('rules',[]) if r['id']=='mirror'),None)
 turntable=next((r.get('params',{}) for r in d.get('rules',[]) if r['id']=='turntable'),None)
 placements={};maxy=max(c[1] for c in cells);nodes=0;memo=set()
 for shape in dict.fromkeys(seq):
  candidates=[]
  for oi,offsets,low,normalized in SHAPES[shape]:
   bounds=[1+max(c[a] for c in normalized) for a in range(3)]
   for y in range(maxy+2-bounds[1]):
    for z in range(b['depth']+1-bounds[2]):
     for x in range(b['width']+1-bounds[0]):
      origin=(x,y,z);own=tuple(tuple(c[a]+origin[a] for a in range(3)) for c in normalized)
      if not all(c in ids for c in own):continue
      twins=tuple(tuple(b['width' if a==0 else 'depth']-1-c[a] if a==mirror else c[a] for a in range(3)) for c in own) if mirror is not None else ()
      if not all(c in ids for c in twins):continue
      om=sum(1<<ids[c] for c in own);tm=sum(1<<ids[c] for c in set(twins)-set(own))
      candidates.append({'shape':shape,'orient':oi,'pivot':[origin[a]-low[a] for a in range(3)],'cells':own,'mirror_cells':twins,'own_mask':om,'twins_mask':tm})
  placements[shape]=candidates
 def recurse(mask,remaining,depth):
  nonlocal nodes
  nodes+=1
  if mask==allmask:return []
  if not remaining or depth>=depth_limit:return None
  if nodes>800000 or time.monotonic()-start>deadline:raise TimeoutError
  state=(mask,tuple(sorted(remaining)) if kit else depth,depth_limit-depth)
  if state in memo:return None
  memo.add(state)
  options=list(dict.fromkeys(remaining)) if kit else [remaining[0]]
  occupied={cells[i] for i in range(len(cells)) if mask>>i&1}
  for shape in options:
   hue=0 if kit or not hues else hues[depth]
   for pl in placements[shape]:
    if pl['own_mask']&mask:continue
    new=pl['own_mask']|(pl['twins_mask']&~mask)
    covered=pl['cells']+tuple(c for c in pl['mirror_cells'] if c not in occupied)
    if hue and any(target[c] and target[c]!=hue for c in covered):continue
    own=pl['cells']
    if not any(c[1]==0 or (c[0],c[1]-1,c[2]) in occupied for c in own):continue
    if any((c[0],c[1]+dy,c[2]) in occupied for c in own for dy in range(1,maxy+5)):continue
    nxt=list(remaining);nxt.remove(shape) if kit else nxt.pop(0)
    nextmask=mask|new
    if turntable and (depth+1)%int(turntable.get('turn_locks',3))==0:
     clockwise=turntable.get('clockwise',True);rotated=[]
     for cell,i in ids.items():
      if nextmask>>i&1:
       rotated.append((b['width']-1-cell[2],cell[1],cell[0]) if clockwise else (cell[2],cell[1],b['depth']-1-cell[0]))
     if not all(cell in ids for cell in rotated):continue
     nextmask=sum(1<<ids[cell] for cell in rotated)
    out=recurse(nextmask,nxt,depth+1)
    if out is not None:
     witness={k:v for k,v in pl.items() if k not in ['own_mask','twins_mask']};witness['hue']=hue;witness['kit_index']=seq.index(shape) if kit else -1
     return [witness]+out
  return None
 try:
  volumes=sorted([len(SHAPES[shape][0][1])*(2 if mirror is not None else 1) for shape in seq],reverse=True)
  minimum=next((i+1 for i in range(len(volumes)) if sum(volumes[:i+1])>=len(cells)),len(seq)+1)
  witness=None
  for depth_limit in range(minimum,len(seq)+1):
   memo.clear();witness=recurse(0,list(seq),0)
   if witness is not None:break
  if witness:
   available=list(enumerate(seq))
   for placement in witness:
    pair=next(pair for pair in available if pair[1]==placement['shape']);available.remove(pair);placement['kit_index']=pair[0] if kit else -1
  status='SOLVED' if witness is not None else 'NO_PACKING_FOUND'
 except TimeoutError:witness=None;status='SEARCH_LIMIT'
 return {'id':d['id'],'status':status,'target_cells':len(cells),'source_inventory':seq,'source_budget':d['goal'].get('piece_budget',len(seq)),'mirror_axis':mirror,'turntable':turntable,'minimum_volume_bound':minimum,'placements':witness or [],'pieces_used':len(witness or []),'search_nodes':nodes,'elapsed_s':round(time.monotonic()-start,4),'checks':['target cells','exact shape orientations','flavour targets','fixed order or kit counts','no occupied overlap','vertical ingress','gravity support','mirror semantics','authored turntable between locks']}

def main():
 results=[]
 for e in json.loads((ROOT/'assets/data/campaign/catalog.json').read_text())['levels']:
  d=json.loads((ROOT/e['json'].removeprefix('res://')).read_text())
  if d['goal']['type']=='shape' and (d['pieces'].get('fixed_list') or d['pieces'].get('kit')):
   result=solve(d);results.append(result);print(result['id'],result['status'],result['pieces_used'],result['search_nodes'],flush=True)
 out=ROOT/'assets/data/campaign/puzzle_proofs.json';out.write_text(json.dumps({'schema':1,'scope':'Constructive packing with supported vertical ingress; does not certify input timing or all reachable states.','proofs':results},indent=2)+'\n')
 return 0 if all(r['status']=='SOLVED' for r in results) else 1
if __name__=='__main__':raise SystemExit(main())
