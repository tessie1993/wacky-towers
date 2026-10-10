#!/usr/bin/env python3
"""Rebuild trusted campaign JSON from authored source specs; retain explicit coverage gaps."""
from pathlib import Path
import re,json,copy
root=Path(__file__).resolve().parents[1]
biomes=['meadow','candy','ice','underwater','lava','forest','cave','clockwork','neon','celestial']
supported={'gust','mushroom_popup','wobble','sprouts','fog','topsy_tumble','mill_belt','mascot_catch','dandelion_puff','fog_ghost','hatching_eggs','sticky_landing','build_race','fill_shape','conveyor','ice_slide','thin_ice','turntable','piston_punch','stopwatch','mirror','bubble','ember','colour_pop','mono_layer','flip','side_travel','bounce_pad','rising_silt','snowball','pest','goo_spread','woodpecker_knock','mascot_hint','angle_gem','rainbow_piece'}
supported.update({'syrup_band','jelly_piece','tier_frosting','mascot_mood','mascot_paw','gumdrop_hail','licorice_lock','frosting','bake_stage','climber_boss','speed_bump','earned_specials','countdown_bomb','moody_cube','balloon','event_card','lava_lid','lava_rock_spawn','lava_rise','quake','locked_cube','squirrel_heist','vines','crab_claw','rock_obstacle','anchored_shelf','key_stamp','undo_reset'})
knob_defs={e['id']:e for p in (root/'assets/data/knobs').glob('*.json') for e in json.loads(p.read_text())['knobs']}
knobs=set(knob_defs)
shapeids=set(re.findall(r'shape_id = &"([^"]+)"',(root/'assets/data/shapes/shape_bank.tres').read_text()))
shape_counts={}
for block in (root/'assets/data/shapes/shape_bank.tres').read_text().split('[sub_resource'):
 match=re.search(r'shape_id = &"([^"]+)"',block);count=re.search(r'cube_count = (\d+)',block)
 if match and count:shape_counts[match.group(1)]=int(count.group(1))
alias={'screw_l':'screw_left','screw_r':'screw_right','Tri-Corner':'tri_corner','Tri-Straight':'tri_straight','Duo':'duo','Tripod':'tripod'}
def sid(x):
 x=x.get('shape','i') if isinstance(x,dict) else x
 return alias.get(x,str(x).lower())
def write(p,v):
 p=root/p;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(v,indent=2)+'\n')
amendments=json.loads((root/'assets/data/campaign/design_amendments.json').read_text())['changes']
entries=[];coverage=[]
for biome in biomes:
 docs=root/f'design/levels/{biome}.md'
 text=docs.read_text() if docs.exists() else ''
 authored=[]
 if biome=='meadow':
  authored=[json.loads(p.read_text()) for p in sorted((root/'production/levels/meadow/data').glob('*.json'))]
  authored.append({'schema':1,'id':'meadow_bonus','biome':'meadow','tier':11,'name':'LVL_MEADOW_BONUS_TITLE','board':{'width':4,'depth':4,'h_play':6},'pieces':{'shapes':['i','o','big_cube'],'fixed_list':['i','o','big_cube','i','o','big_cube']},'knobs':{'fall.g0':.5,'goal.top_out':'trim','goal.warnings_max':0},'goal':{'type':'shape','piece_budget':6,'time_limit_ms':60000,'target_shape':{'layers':{'0':['++++']*4,'1':['++++']*4}}},'rules':[{'id':'fill_shape','params':{'topout_rule':'trim','stick_when_filled':False}}],'stars':{'t2':45000,'t3':30000},'story':{'title_key':'LVL_MEADOW_BONUS_TITLE','premise_key':'LVL_MEADOW_BONUS_PREMISE','mascot_role':'watcher','icon':'picnic'}})
 elif biome!='neon':
  authored=[json.loads(b) for b in re.findall(r'```json\s*([\s\S]*?)```',text)]
 else:
  proposals=[('Welcome to Glowtown',4,4,8,'clear_n',3,.95,[],145,105),('Traffic Lights',5,5,10,'clear_n',4,1.0,['stopwatch'],260,185),('Moving Sidewalk',8,4,10,'clear_n',4,1.05,['conveyor'],310,220),('Looking Glass Arcade',6,6,10,'clear_n',4,1.1,['mirror'],340,240),('Cloud Nine Sign',5,5,12,'height',9,1.1,['build_race'],260,185),('Pixel Picture',4,4,6,'shape',0,.9,['fill_shape'],80000,55000),('Neon Shower',6,6,10,'clear_n',5,1.15,['bubble'],360,255),('Rush Hour',5,5,10,'survive',150,1.2,['stopwatch'],240,170),('Power Surge',6,6,12,'clear_n',5,1.25,['turntable','gust'],410,290),('The Lonely Billboard',7,7,14,'clear_n',4,1.3,['conveyor','mirror','gust'],390,275)]
  lines=['# Neon: Glowtown\n\nStatus: Proposed implementation design (2026-10-10). No Neon level design existed in the source repository. These ten levels are new proposals awaiting author review and playtest. They connect Clockwork to Celestial through Mizzle’s lonely billboard. All story plays wordlessly.\n\n| Level | Name | Board | Goal | Rule | 2★ / 3★ |\n|---|---|---|---|---|---|']
  for t,(name,w,d,h,gt,n,speed,rules,t2,t3) in enumerate(proposals,1):
   id=f'neon_{t:02d}';goal={'type':gt}
   if gt=='clear_n':goal['n']=n
   elif gt=='height':goal['h_target']=n
   elif gt=='survive':goal['t_ms']=n*1000
   else:goal.update(piece_budget=8,target_shape={'layers':{'0':['++++']*4,'1':['++++']*4,'2':['....','.++.','.++.','....'],'3':['....','.++.','.++.','....']}})
   authored.append({'schema':1,'id':id,'biome':biome,'tier':t,'name':f'LVL_{id.upper()}_TITLE','board':{'width':w,'depth':d,'h_play':h},'pieces':{'shapes':['i','o','t','l','s','tripod','screw_left','screw_right'] if gt!='shape' else ['i','o','big_cube'],'fixed_list':['big_cube','big_cube','i','i','o','o','o','o'] if gt=='shape' else []},'knobs':{'fall.g0':speed,'goal.top_out':'trim' if gt in ['height','shape'] else 'rescue','goal.warnings_max':1},'goal':goal,'rules':[{'id':r,'params':{}} for r in rules],'stars':{'t2':t2*1000 if t2<1000 else t2,'t3':t3*1000 if t3<1000 else t3},'story':{'title_key':f'LVL_{id.upper()}_TITLE','premise_key':f'LVL_{id.upper()}_PREMISE','mascot_role':'boss' if t==10 else 'watcher','icon':'star'}})
   lines.append(f'| {t:02d} | {name} | {w}×{d}, H{h} | {gt} {n or "40 cells"} | {", ".join(rules) or "classic"} | {t2} / {t3} s |')
  lines.append('\nEach level keeps one legible new idea, then remixes familiar ones. Level 05 offers a trim tower breather; 06 is an eight-piece stepped neon-sign puzzle; 08 is a timed sprint. Level 10 lights an empty second chair beside Mizzle’s billboard and points toward the final island. Art is a bright toy city with violet dusk, painted signposts and cyan/peach accents; no flashing effects. Track ids mus_neon_01–10 are user-supplied placeholders. Stars are initial estimates, not tuned medians. Local physics use existing deterministic grid rules.\n')
  docs.write_text('\n'.join(lines))
 # names map from overview rows or numbered headings
 names={}
 for line in text.splitlines():
  if line.startswith('|'):
   row=[c.strip() for c in line.split('|')[1:-1]]
   if len(row)>2 and re.match(r'^'+biome+r'_(\d\d|bonus|h\d)$',row[1]):names[row[1]]=row[2]
 for spec in authored:
  data=copy.deepcopy(spec);id=data['id'];unsupported=[]
  applied=[]
  for change in amendments:
   if change['id']!=id:continue
   for key in ['board','goal']:
    if key in change:data.setdefault(key,{}).update(copy.deepcopy(change[key]))
   if 'stars' in change:data['stars']=copy.deepcopy(change['stars'])
   applied.append(change)
  if biome!='meadow':
   board_original=copy.deepcopy(data.get('board',{}))
   if 'keyholes' in board_original:data.setdefault('goal',{})['keyholes']=copy.deepcopy(board_original['keyholes'])
   keep={'schema','id','biome','tier','name','board','pieces','knobs','goal','rules','stars','story','seed','music'}
   for k in list(data):
    if k not in keep:unsupported.append('field:'+k);data.pop(k)
   if 'tier' not in data:data['tier']=11 if id.endswith('bonus') else 12+int(id[-1])-1 if '_h' in id else int(id[-2:])
   data['biome']=biome;data.setdefault('name',f'LVL_{id.upper()}_TITLE');data['seed']=data.get('seed',None)
   if not 'board' in data:data['board']={'width':6,'depth':6,'h_play':10};unsupported.append('multi_board_layout')
   b=data['board']
   for k in list(b):
    if k not in {'width','depth','h_play','down_axis','mask','spawn_anchor','starting_contents'}:
     if k not in {'rock','shelf','keyholes'}:unsupported.append('board:'+k)
     b.pop(k)
   if isinstance(b.get('mask'),dict):b['mask']=b['mask'].get('rows',b['mask'].get('layers',{}).get('all',[]))
   if isinstance(b.get('spawn_anchor'),dict):b['spawn_anchor']=[b['spawn_anchor'].get('x',0),b['spawn_anchor'].get('z',0)]
   if 'starting_contents' in b:
    sec=b['starting_contents']
    if isinstance(sec,dict) and 'legend' in sec:sec.pop('legend')
    if isinstance(sec,dict) and 'layers' in sec:
     for y,rows in list(sec['layers'].items()):
      if isinstance(rows,str) and rows.startswith('same as layer '):rows=copy.deepcopy(sec['layers'][rows.split()[-1]])
      if not isinstance(rows,list) or len(rows)!=b['depth'] or any(not isinstance(row,str) or len(row)!=b['width'] for row in rows):
       unsupported.append('content:malformed_source_layer_'+str(y));del sec['layers'][y];continue
      mapping={'L':'#','s':'s' if biome=='candy' else '^','m':'n' if biome=='ice' else 'b' if biome=='underwater' else 'o' if biome=='cave' else 'm','w':'p' if biome=='candy' else 'w','c':'g' if biome=='candy' else 'c','g':'u' if biome=='candy' else 'g'}
      allowed=set('.#me^cbngpuls23yaqBDRokH')
      sec['layers'][y]=[''.join(mapping.get(c,c) if mapping.get(c,c) in allowed else '.' for c in row) for row in rows]
      if any(mapping.get(c,c) not in allowed for row in rows for c in row):unsupported.append('content:unregistered_glyph')
    else:unsupported.append('content:structured');b.pop('starting_contents')
   # Preserve permanent authored board geometry as content with initializer rules.
   def place_geometry(cells,glyph):
    layers=b.setdefault('starting_contents',{}).setdefault('layers',{})
    for x,y,z in cells:
     rows=layers.setdefault(str(y),['.'*b['width'] for _ in range(b['depth'])])
     rows[z]=rows[z][:x]+glyph+rows[z][x+1:]
   if 'rock' in board_original:
    rock=board_original['rock'];cells=[]
    for y,rows in rock.get('layers',{}).items():
     cells += [[x,int(y),z] for z,row in enumerate(rows) for x,c in enumerate(row) if c=='R']
    for col in rock.get('columns',[]):cells += [[col['x'],y,col['z']] for y in range(col['y_from'],col['y_to']+1)]
    place_geometry(cells,'R');data.setdefault('rules',[]).append({'id':'rock_obstacle','params':{'cells':cells}})
   if 'shelf' in board_original:
    shelf=board_original['shelf'];openings=set()
    for o in shelf['openings']:openings.update((x,z) for x in range(o['x'],o['x']+o['w']) for z in range(o['z'],o['z']+o['d']))
    cells=[[x,shelf['y'],z] for z in range(b['depth']) for x in range(b['width']) if (x,z) not in openings]
    place_geometry(cells,'H');data.setdefault('rules',[]).append({'id':'anchored_shelf','params':{'cells':cells}})
   p=data.setdefault('pieces',{})
   if p.get('fixed_list') and any(isinstance(s,dict) and 'tags' in s for s in p['fixed_list']):p['fixed_tags']=[list(s.get('tags',{})) if isinstance(s,dict) else [] for s in p['fixed_list']]
   if p.get('fixed_list') and any(isinstance(s,dict) and 'colour' in s for s in p['fixed_list']):p['fixed_hues']=[{'P':1,'V':2,'M':3}.get(s.get('colour','P'),1) if isinstance(s,dict) else 1 for s in p['fixed_list']]
   for key in ['shapes','fixed_list','opening_set','kit']:
    if key in p:p[key]=[sid(s) for s in p[key]]
   if 'shapes' not in p:p['shapes']=list(dict.fromkeys(p.get('fixed_list',p.get('kit',['i','o','t','l','s','tripod','screw_left','screw_right']))))
   for s in p['shapes']:
    if s not in shapeids:unsupported.append('shape:'+s)
   p['shapes']=[s for s in p['shapes'] if s in shapeids]
   if p.get('weights'):p['weights']={sid(k):v for k,v in p['weights'].items()}
   if 'control.rotation_axes' in data.get('knobs',{}):data['knobs']['control.rotation_axes_enabled']=data['knobs'].pop('control.rotation_axes')
   if 'goal.time_limit_s' in data.get('knobs',{}):data.setdefault('goal',{})['time_limit_ms']=int(data['knobs'].pop('goal.time_limit_s')*1000)
   if data.get('knobs',{}).get('control.verb')=='choose_down*':data['knobs']['control.verb']='choose_down'
   if data.get('knobs',{}).get('skill.redraw')=='off':data['knobs'].pop('skill.redraw');unsupported.append('authoring:redraw_disabled_fixed_or_kit')
   for k in list(data.get('knobs',{})):
    if k not in knobs or ('choices' in knob_defs[k] and data['knobs'][k] not in knob_defs[k]['choices']):unsupported.append('knob:'+k+'='+str(data['knobs'][k]));del data['knobs'][k]
   rs=[]
   canonical=[]
   for r in data.get('rules',[]):
    legacy=r['id'];params=r.get('params',{})
    if legacy.endswith('*') and legacy[:-1] in supported:
     r['id']=legacy[:-1];canonical.append({'source':legacy,'runtime':r['id'],'params':params.copy()})
    if legacy=='mushroom_popup' and params.get('object') in ['gumdrop','icing_dollop']:
     r['id']='gumdrop_hail';canonical.append({'source':legacy,'runtime':r['id'],'params':params.copy()})
    if r['id'] in ['jelly_piece','rainbow_piece','moody_cube']:
     data['pieces'].setdefault('tags',{})[{'jelly_piece':'jelly','rainbow_piece':'rainbow','moody_cube':'moody'}[r['id']]]={'per_bag':int(params.get('per_bag',1))}
    if legacy in ['EV06','EV12','EV04','SP30'] and biome=='lava':
     r['id']={'EV06':'lava_rise','EV12':'quake','EV04':'lava_rock_spawn','SP30':'locked_cube'}[legacy]
     if legacy=='EV04':params['object_kind']='rock' if params.get('object')=='SP19' else params.get('object','rock');params.setdefault('hard_hits',2)
     canonical.append({'source':legacy,'runtime':r['id'],'params':params.copy()})
    if legacy=='split_piece':
     r['id']='dandelion_puff';data['pieces'].setdefault('tags',{})['dandelion_puff']={'per_bag':int(params.get('per_bag',1))};canonical.append({'source':legacy,'runtime':r['id'],'params':params.copy()})
    if biome=='lava' and legacy=='EV04' and params.get('object')=='SP35':
     r['id']='mushroom_popup';params['object_kind']='bounce_pad';params['spawn_every_locks']=params.pop('every_locks',5);params.pop('object',None);canonical.append({'source':legacy,'runtime':r['id'],'params':params.copy()})
    if biome=='lava' and legacy=='SP35':
     r['id']='bounce_pad';params.setdefault('dir_mode','last_move');canonical.append({'source':legacy,'runtime':r['id'],'params':params.copy()})
    if legacy=='wo09_watcher':canonical.append({'source':legacy,'runtime':'story.mascot_role=watcher','presentation_only':True});continue
    if legacy in ['pond_mirror','pistons','rainbow_piece*']:
     r['id']={'pond_mirror':'mirror','pistons':'piston_punch','rainbow_piece*':'rainbow_piece'}[legacy]
     if legacy=='pistons':
      for piston in params.get('pistons',[]):piston['wall']={'-x':'west','+x':'east','-z':'north','+z':'south'}.get(piston.get('wall'),piston.get('wall'))
     canonical.append({'source':legacy,'runtime':r['id'],'params':params.copy()})
    if biome=='candy' and r['id']=='mascot_catch':params['happy_only']=True
    if r['id']=='turntable':
     if 'turn_every_locks' in params:params['turn_locks']=params.pop('turn_every_locks')
     if 'turn_dir' in params:params['clockwise']=params.pop('turn_dir')=='cw'
    if r['id']=='conveyor' and 'dir' in params:params['conveyor_dir']=params.pop('dir')
    if legacy in ['PL02','PL07','EV02','EV05','SP40'] and biome=='lava':
     r['id']={'PL02':'build_race','PL07':'fill_shape','EV02':'fog','EV05':'conveyor','SP40':'ember'}[legacy]
     if legacy=='EV02' and 'alpha' in params:params['invisible_alpha']=params.pop('alpha')
     if legacy=='EV05':
      direction=params.pop('dir',[1,0,0]);params['conveyor_dir']='+x' if direction[0]>0 else '-x' if direction[0]<0 else '+z' if direction[2]>0 else '-z';params['conveyor_every']=params.pop('every_locks',3);params['conveyor_wrap']=params.pop('wrap',True)
     if legacy=='SP40':
      data['pieces'].setdefault('tags',{})['ember']={'per_bag':int(params.pop('ember_per_bag',1))}
     canonical.append({'source':legacy,'runtime':r['id'],'params':params.copy()})
    if r['id'] in supported:rs.append(r)
    else:unsupported.append('rule:'+r['id'])
   data['rules']=rs
   g=data.setdefault('goal',{'type':'clear_n','n':3})
   gt=g.get('type','clear_n');gt={'clear':'clear_n','fill_shape':'shape'}.get(gt,gt);g['type']=gt
   if gt=='clear_n':g['n']=int(g.get('n',g.get('N',3)));g.pop('N',None)
   elif gt=='height':g['h_target']=int(g.get('h_target',g.get('H_target',10)));g.pop('H_target',None)
   elif gt=='survive':g['t_ms']=int(g.get('t_ms',g.get('T',150)*1000))
   elif gt=='shape':
    target=g.get('target_shape',{})
    if target.get('colours'):
     g['target_shape']=target
    else:
     layers=target.get('layers',{})
     for y,rows in layers.items():layers[y]=[''.join('+' if c!='.' else '.' for c in row) for row in rows]
     g['target_shape']={'layers':layers}
   elif gt not in ['rescue_all','bonk_boss','dig_rescue','wind_keys','bake_oven']:unsupported.append('goal:'+gt)
   if id=='candy_10':g['type']='bake_oven'
   if id=='candy_05':data['stars']['metric']='frosted_tiers'
   if id=='candy_07':data['stars']['three_star_zero_metrics']=['worms_escaped']
   if id=='neon_08':data['stars']={'s2':1,'s3':2}
   if id=='candy_bonus':data['stars']['three_star_zero_metrics']=['paw_eaten']
   if data['goal']['type'] in ['height','shape']:
    data.setdefault('knobs',{})['goal.top_out']='trim'
    if not any(r['id'] in ['build_race','fill_shape'] for r in data['rules']):data['rules'].insert(0,{'id':'build_race' if data['goal']['type']=='height' else 'fill_shape','params':{'topout_rule':'trim'}})
   if data['pieces'].get('kit') and 'piece_budget' not in data['goal']:data['goal']['piece_budget']=len(data['pieces']['kit'])
  if data.get('goal',{}).get('type')=='shape':
   goal=data['goal'];pieces=data['pieces'];budget=int(goal.get('piece_budget',0));fixed=pieces.get('fixed_list',pieces.get('kit',[]))
   target=sum(c!='.' for rows in goal.get('target_shape',{}).get('layers',{}).values() for row in rows for c in row)
   required=min(target,int(goal.get('win_correct',target)))
   if budget>0 or fixed:
    available=sum(shape_counts.get(shape,0) for shape in (fixed[:budget] if budget>0 else fixed)) if fixed else budget*max((shape_counts.get(shape,0) for shape in pieces.get('shapes',[])),default=0)
    if any(r['id']=='mirror' for r in data['rules']):available*=2
    available+=sum(c!='.' for rows in data['board'].get('starting_contents',{}).get('layers',{}).values() for row in rows for c in row)
    if available<required:unsupported.append('goal:insufficient_material_%d_for_%d_target_cells'%(available,required))
  nonblocking={'field:recipe','field:solution','field:secrets','content:sugar_visual'}
  if spec.get('layout',{}).get('kind')=='single':nonblocking.add('field:layout')
  blockers=sorted({u for u in unsupported if u not in nonblocking and not u.startswith(('presentation:','authoring:'))})
  data['metadata']={'source':f'production/levels/meadow/data/{id}.json' if biome=='meadow' and data['tier']<=10 else f'design/levels/{biome}.md','status':'Proposed' if biome=='neon' else 'Playable subset' if blockers else 'Authored; awaiting playtest','design_spec':spec,'unsupported':sorted(set(unsupported)),'blocking_gameplay':blockers,'nonblocking_notes':sorted(set(unsupported)-set(blockers)),'tuning':'Initial estimates; no playtest medians','canonical_rule_mapping':canonical if biome!='meadow' else [],'design_amendments':applied}
  path=f'src/levels/{biome}/{id}/{id}.json';scene=f'src/levels/{biome}/{id}/{id}.tscn'
  write(Path(path),data)
  name=names.get(id,id.replace('_',' ').title())
  if biome=='neon':name=proposals[int(id[-2:])-1][0]
  entries.append({'id':id,'biome':biome,'tier':data['tier'],'name':name,'name_key':data['name'],'json':'res://'+path,'scene':'res://'+scene,'bonus':data['tier']>10,'status':data['metadata']['status'],'unsupported':data['metadata']['unsupported'],'blocking_gameplay':data['metadata']['blocking_gameplay']})
  coverage.append({'id':id,'source':data['metadata']['source'],'implemented_rule_ids':[r['id'] for r in data.get('rules',[])],'unsupported':data['metadata']['unsupported'],'blocking_gameplay':data['metadata']['blocking_gameplay']})
 # trusted per-biome explicit catalog
 write(Path(f'assets/data/biomes/{biome}.json'),{'id':biome,'index':biomes.index(biome)+1,'art_set':'candy_toy','palette':'candy_toy' if biome=='candy' else 'meadow','side_island':False,'default_music':f'mus_{biome}_default','levels':[{'id':e['id'],'json':e['json'],'scene':e['scene']} for e in entries if e['biome']==biome]})
entries.sort(key=lambda e:(biomes.index(e['biome']),e['tier']))
write(Path('assets/data/campaign/catalog.json'),{'schema':1,'biomes':biomes,'levels':entries})
write(Path('assets/data/campaign/implementation_coverage.json'),{'schema':1,'warning':'Playable subsets preserve the full authored source spec in metadata.design_spec; unsupported entries are explicit and are not silently aliased. No tuning claims.','levels':coverage})
print('Authored mains',sum(e['tier']<=10 for e in entries),'total levels',len(entries),'partial',sum(bool(e['blocking_gameplay']) for e in entries),'notes',sum(bool(e['unsupported']) for e in entries))
