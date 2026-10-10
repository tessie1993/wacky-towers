#!/usr/bin/env python3
"""Rebuild trusted RuleDef schemas from official rule parameter examples."""
import pathlib,json,collections,os
os.chdir(pathlib.Path(__file__).resolve().parents[1])
supported=['gust','mushroom_popup','wobble','sprouts','fog','topsy_tumble','mill_belt','mascot_catch','dandelion_puff','fog_ghost','hatching_eggs','sticky_landing','build_race','fill_shape','conveyor','ice_slide','thin_ice','turntable','piston_punch','stopwatch','mirror','bubble','ember','colour_pop','mono_layer','flip','side_travel','bounce_pad','rising_silt','snowball','pest','goo_spread','woodpecker_knock','mascot_hint','angle_gem','rainbow_piece']
supported += ['syrup_band','jelly_piece','tier_frosting','mascot_mood','mascot_paw','gumdrop_hail','licorice_lock','frosting','bake_stage','climber_boss','speed_bump','earned_specials','countdown_bomb','moody_cube','balloon','event_card','lava_lid','lava_rock_spawn','lava_rise','quake','locked_cube','squirrel_heist','vines','crab_claw','rock_obstacle','anchored_shelf','key_stamp','undo_reset']
params=collections.defaultdict(dict)
for p in pathlib.Path('src/levels').glob('*/*/*.json'):
 d=json.loads(p.read_text())
 for r in d.get('rules',[]):
  for key,val in r.get('params',{}).items():params[r['id']][key]={'type':'flag' if isinstance(val,bool) else 'number' if isinstance(val,(int,float)) else 'string' if isinstance(val,str) else 'structure'}
params['gust'].update({'wind_dir':{'type':'string'},'wind_interval_ms':{'type':'number'},'wind_strength':{'type':'number'}})
params['crab_claw'].update({'claw_grab':{'type':'number','min':0,'max':1},'counter':{'type':'string','choices':['clear']}})
params['earned_specials'].update({'rocket_at':{'type':'number','min':0,'max':0},'colour_bomb_at':{'type':'number','min':0,'max':0}})
folder=pathlib.Path('assets/data/rules');folder.mkdir(exist_ok=True)
for id in supported:
 layer='mascot' if id in ['mascot_catch','mascot_hint','angle_gem','mascot_mood','mascot_paw'] else 'content' if id in ['dandelion_puff','fog_ghost','sprouts','hatching_eggs','bubble','ember','snowball','pest','bounce_pad','rainbow_piece','jelly_piece','tier_frosting','licorice_lock','frosting','climber_boss','earned_specials','countdown_bomb','moody_cube','locked_cube','vines','rock_obstacle','anchored_shelf','key_stamp','undo_reset'] else 'mechanic' if id in ['build_race','fill_shape','mill_belt','conveyor','mono_layer','colour_pop','bake_stage','event_card'] else 'twist'
 (folder/f'{id}.json').write_text(json.dumps({'schema':1,'id':id,'name_key':'RULE_'+id.upper(),'layer':layer,'icon':id,'behaviour':id,'params':params[id],'incompatible_with':[]},indent=2)+'\n')
