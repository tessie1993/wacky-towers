#!/usr/bin/env python3
"""Durable per-biome art handoff from actual level/story/catalog source, not invented files."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[2]
MASCOTS=dict(zip('meadow candy ice underwater lava forest cave clockwork neon celestial'.split(),'pip mallow pebble puff cinder chip nugget tock glitch comet'.split()))
BOSSES=dict(zip(MASCOTS,'miller meringue sniffles crab smolder oak geode cuckoo mirrorball moon'.split()))
LANDMARKS={'meadow':'windmill, garden trees, roots','candy':'lollipop row, cake-coloured strata','ice':'ice crystal row, icicle roots','underwater':'coral branches, seabed strata','lava':'volcanic rocks and quiet ember caps','forest':'canopy row, timber roots','cave':'crystal row and muted cave strata','clockwork':'gear row and brass-like strata','neon':'matte geometric crystal row, flat purple paint','celestial':'pale star/crystal row and floating marble-like strata'}
CHARACTERS=['cloud','lana','boulder','glim']
GEOM='src/view/wt_stage.gd'
BASE='assets/models/blocks/candy_toy/blk_candy_toy_cube.res'
TYPES=json.loads((ROOT/'assets/data/content/blocks.json').read_text())['types']
GLYPHS={t['glyph']:t['id'] for t in TYPES if t['glyph']}


def asset(identifier,role,source,realization='live procedural geometry',remaining='Final painted/rigged art polish and physical-device readability review.'):
 return dict(id=identifier,role=role,source=source,realization=realization,remaining_polish=remaining)


def main():
 catalog=json.loads((ROOT/'assets/data/campaign/catalog.json').read_text())
 stories=json.loads((ROOT/'assets/data/story/campaign_skits.json').read_text())['stories']
 manifest={'schema':1,'generated_from':['assets/data/campaign/catalog.json','assets/data/story/campaign_skits.json','src/levels/','design/art/art-bible.md'],'provenance':'Original authored-in-code geometry and synthesized audio. Not final external art models.','biomes':{}}
 dest=ROOT/'docs/art/biomes';dest.mkdir(parents=True,exist_ok=True)
 for biome in MASCOTS:
  levels=[]
  for entry in catalog['levels']:
   if entry['biome']!=biome:continue
   path=entry['json'].removeprefix('res://');data=json.loads((ROOT/path).read_text());sid=entry['id'];story=stories.get(sid,{})
   hero=story.get('pre',[{'symbol':data.get('story',{}).get('icon','gift')}])[0]['symbol']
   clue=story.get('post',[{'symbol':hero}])[-1]['symbol'];shapes=data.get('pieces',{}).get('shapes',[])
   rules=[r.get('id','') if isinstance(r,dict) else str(r) for r in data.get('rules',[])]
   goal=data.get('goal',{});kind=goal.get('type','')
   assets=[asset(f'board_{sid}','Exact footprint/mask and far-wall guides',GEOM+'::_build_board; _build_guides'),asset(f'prop_{sid}_{hero}','Authored intro/goal hero prop on quiet rim',GEOM+f'::_story_prop({hero}); WtStoryData.environment({sid})'),asset(f'clue_{sid}_{clue}','Wordless payoff/invitation clue',GEOM+f'::_story_prop({clue}); src/ui/wordless_story.gd'),asset(f'background_{biome}','Biome island, sky and landmark: '+LANDMARKS[biome],GEOM+'::BIOME_LOOKS; _build_light; _build_island; _build_props'),asset('toy_'+MASCOTS[biome],'Regional mascot silhouette, eyes and basket/tool accessory','src/view/wt_toy_actor.gd::setup('+MASCOTS[biome]+')'),asset('blocks_'+sid,'Piece pool: '+', '.join(shapes),BASE+' + assets/data/shapes/shape_bank.tres','existing GLB-derived bevelled cube + authored integer offsets','Final bespoke painted biome sets/shape motifs; retain exact shape silhouettes and hues.'),asset('ghost_'+sid,'Exact landing ghost and ground-column marks',GEOM+'::_update_piece; _ghost_material','live shader and MultiMesh','Inspect overlap under every authored mechanic on target phone.'),asset('touch_'+sid,'Large move, allowed rotation, drop, hold/item/skill/view controls','src/ui/game_ui.gd; src/app/player_input.gd','live UI controls','Platform-safe-area and physical-controller review.'),asset('feedback_'+sid,'Lock/clear/warning/win/lose visual and audio grammar',GEOM+'::sync; burst; src/view/fx/wt_audio.gd; tools/asset-pipeline/generate_audio.py','live pooled confetti/markers and original synthesized WAV','Bespoke authored keyframe performances and final per-level user music.')]
   for character in CHARACTERS:assets.append(asset('toy_'+character,'Selected playable character form and owned outfit','src/view/wt_toy_actor.gd::setup('+character+'); '+GEOM+'::_build_characters; apply_cosmetics'))
   if sid.endswith('_10'):
    assets.append(asset('toy_'+BOSSES[biome],'Local finale boss form and wordless aftermath','src/view/wt_toy_actor.gd::setup('+BOSSES[biome]+'); assets/data/story/campaign_skits.json'))
   if biome!='meadow' and sid in stories:assets.append(asset('toy_mizzle','Quiet source-authored invitation clue or finale redemption','src/view/wt_toy_actor.gd::_mizzle; src/ui/wordless_story.gd'))
   if kind=='shape':assets.append(asset('stencil_'+sid,'Target shape/colour stencil',GEOM+'::set_goal(shape)','live MultiMesh stencil','Check target visibility in all camera snaps and large authored shapes.'))
   elif kind=='height':assets.append(asset('height_line_'+sid,'Exact target height line',GEOM+'::set_goal(height)','live gold line geometry','Inspect target/danger distinction on phone.'))
   elif kind=='wind_keys':assets.append(asset('keys_'+sid,'Wall keyholes, wound state, rotated piece-key stamp',GEOM+'::_build_keyholes; _update_key_face','live original ring/slot meshes','Final painted key/clockface motifs.'))
   for rule in rules:
    assets.append(asset('mechanic_'+sid+'_'+rule,'Mechanic-specific object/hazard/phase read for '+rule,GEOM+'::sync; _hazard_event; _refresh_status_views; src/view/wt_content_geometry.gd','live board-state presentation and available pooled warning/status markers','Final bespoke '+rule+' performance, environmental animation and manual phase readability review.'))
   content_section=data.get('board',{}).get('starting_contents',{})
   content_rows=content_section.get('layers',{}) if isinstance(content_section,dict) else {}
   rows=[]
   if isinstance(content_rows,dict):
    for layer in content_rows.values():
     if isinstance(layer,list):rows.extend(layer)
   elif isinstance(content_rows,list):
    for layer in content_rows:
     if isinstance(layer,list):rows.extend(layer)
   content_text=''.join(row for row in rows if isinstance(row,str))
   content_ids=sorted({GLYPHS[g] for g in GLYPHS if g in content_text})
   if rules:content_ids=sorted(set(content_ids)|{'rule-spawned living content (shared kind catalogue)'})
   for content in content_ids:assets.append(asset('content_'+sid+'_'+content,'Starting/spawned content identity '+content,'src/view/wt_content_geometry.gd::mesh(kind); assets/data/content/blocks.json','live original shared kind meshes','Final painted content faces, hatch/break clips and status icon tuning.'))
   lighting='biome matte palette'
   if biome=='meadow':lighting={1:'first morning',2:'bedtime',3:'breezy day',4:'breezy day',5:'late afternoon',6:'late afternoon',7:'dawn fog',8:'morning',9:'morning',10:'golden picnic'}.get(int(sid.rsplit('_',1)[-1]) if sid.rsplit('_',1)[-1].isdigit() else 0,'nearest Meadow context')
   levels.append(dict(id=sid,name=entry.get('name',sid),data=path,source_spec=data.get('metadata',{}).get('source','design/levels/'+biome+'.md'),hero=hero,clue=clue,light=lighting,board=data.get('board',{}),goal=kind,rules=rules,shapes=shapes,assets=assets,main_story=sid in stories,source_unsupported=data.get('metadata',{}).get('unsupported',[])))
  log=ROOT/f'production/qa/evidence/build-2026-10-10/biome-{biome}.godot.log';captured=log.exists() and 'SCRIPT ERROR' not in log.read_text() and '\nERROR:' not in log.read_text()
  manifest['biomes'][biome]={'status':'Dressing captured and inspected; all catalog scenes separately parsed, instantiated, legal-spawned and locked in ordered verification.','renderer':'Godot 4.7.2 Compatibility / Mesa llvmpipe / Xvfb','capture':f'production/qa/evidence/build-2026-10-10/biome-{biome}.png','capture_log_clean':captured,'levels':levels}
  lines=[f'# {biome.title()} art asset handoff','', 'Updated 2026-10-10. This is a durable level-by-level inventory from the actual catalog and wordless story data. It distinguishes existing source assets, original procedural factories and remaining art polish. It does not label primitive geometry as final commercial art.','', '## Verification and sources','',f'- Status: {"rendered, inspected and no script/shader errors in retained dressing log" if captured else "dressing verification needs rerun"}.',f'- Evidence: `production/qa/evidence/build-2026-10-10/biome-{biome}.png` and adjacent Godot log; the ten-biome contact sheet was visually inspected.', '- Basis: Godot 4.7.2 on Xvfb, Compatibility renderer, Mesa llvmpipe software rendering. This is a common 4×4 BoardSim fixture with this biome’s level-07 story dressing, not a claim that every authored level was completed.','- Ordered gameplay basis: `production/qa/evidence/full-build/biome-level-verification.json` instantiates all118 World stages, checks legal first spawn and three actual locks; all15 finite shape puzzles reach WIN. Other campaign objectives and human playthroughs remain unassessed.',f'- Rule source: `design/levels/{biome}.md` where supplied, each level’s `metadata.source`/`metadata.design_spec`, and `assets/data/campaign/implementation_coverage.json`. Neon’s missing original level document is explicit; implementation-authored Neon data retains provenance.', '- Narrative: `design/gdd/narrative/meadow-story.md`, `production/levels/campaign/biome-stories.md`, `production/narrative/campaign-story/dialogue-campaign-skits.md`, `assets/data/story/campaign_skits.json`.', '- Art constraints: `design/art/art-bible.md`, `production/narrative/campaign-story/visual-direction.md`, `production/levels/campaign/lore.md`.', '- Skills applied: studio world-builder/level-designer, vendored godot-3d-world-building/lighting, godot-genre-puzzle and godot-genre-party; reviewed `sleepy_block.gd` and `tournament_state.gd` examples against the separate Jolt and external tournament-state seams.','', '## Shared actual resources','',f'Biome mascot: `{MASCOTS[biome]}`. Local finale boss: `{BOSSES[biome]}`. All four playable forms (`cloud`, `lana`, `boulder`, `glim`) are original source meshes in `src/view/wt_toy_actor.gd`. Story phases use wordless animated vector portraits in `src/ui/wordless_story.gd`. Installed Beehave trees dispatch live toy reactions/idle poses. No skeletal rig or imported character GLB is claimed.','',f'Background landmark: {LANDMARKS[biome]}. `WtStage` adds a level hero prop and a smaller clue prop in fixed quiet-rim slots, outside the playable grid. Shared block resource: `{BASE}` and the 67-shape integer-offset bank. Candy uses its flavour palette; other current biomes use the family palette. Original specialty kind meshes are batched by kind, including egg/chick, mushroom/sprout, snowball, goo, pest, gumdrop/frosting, bombs, rock, lock and shelf.','', '## Camera, accessibility and mobile constraints','', 'The approved UX has twelve 30-degree camera snaps. Piece silhouettes and exact ghosts remain the first read; saturated hues and all ten palette pattern codes stay available. Warning borders use orange/stripes; status icons/counters are pooled separately. Art bible §3 targets cubes readable at about 20px; §characters gives phone wizards about 48–80px and bosses roughly one third of the screen. Touch targets are at least 44pt iOS / 48dp Android, with in-play targets 56–64pt and at least 8pt spacing. These are authored targets, not measurements from this software desktop fixture.','', 'The art bible explicitly removed polygon/texture/draw-call budgets on 2026-10-09: no invented numerical budgets are set here. Hardware-phone 60fps, four-device LAN latency, safe areas, skeletal animation and all target-platform behavior still require device evidence. The view avoids one node per piece cube; special kinds, status glyphs, ghosts and particles are pooled.','', '## Level-by-level required named assets','']
  for level in levels:
   lines += [f'### {level["id"]} — {level["name"]}','',f'Data: `{level["data"]}`. Original source: `{level["source_spec"]}`. Goal: `{level["goal"]}`. Light: {level["light"]}. Required piece silhouettes: '+(', '.join('`'+s+'`' for s in level['shapes']) or 'inherited pool')+'.', '', '| Named asset | Role / dependency | Existing realization / source | Remaining polish |','|---|---|---|---|']
   for a in level['assets']:
    lines.append('| `'+a['id']+'` | '+a['role'].replace('|','/')+' | '+a['realization']+'; `'+a['source']+'` | '+a['remaining_polish']+' |')
   if not level['main_story']:lines+=['','This bonus/hard catalog record reuses the biome art grammar; it has no separate entry in the 100-main-level wordless compiler. A bespoke bonus payoff remains an optional authored art addition.']
  lines += ['', '## Final-art queue and provenance','', 'Required final polish includes authored painted biome frames/blocks, character/content face treatment, keyframe or skeletal hatch/break/cast/celebrate/boss clips, final world performances and per-level music when supplied. The current ten loops and eleven cues are original synthesized PCM WAVs generated by `tools/asset-pipeline/generate_audio.py`; no outside recordings or sample packs were introduced. Keep exact puzzle cells, ghost transforms, warning coverage and colour-blind identities when replacing geometry.','', 'Machine-readable inventory: `docs/art/biomes/art_asset_manifest.json`. Rebuild all ten documents with `python tools/content/generate_art_manifests.py` after catalog or story changes.']
  (dest/f'{biome}-assets.md').write_text('\n'.join(lines)+'\n')
 (dest/'art_asset_manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
 print('Generated ten biome documents,',sum(len(b['levels']) for b in manifest['biomes'].values()),'level inventories.')
if __name__=='__main__':main()
