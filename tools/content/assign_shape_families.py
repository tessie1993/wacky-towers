#!/usr/bin/env python3
"""Apply the approved 67-shape Piece Set family table to hand fields and the Resource bank."""
from pathlib import Path
import json,re,collections
ROOT=Path(__file__).resolve().parents[2]
families={
 'standard':['i','o','t','l','s','tripod','screw_left','screw_right'],
 'special':['chair','big_tripod','staircase','twist_left','twist_right','big_cube','tall_corner'],
 'helper':['mono','duo','tri_straight','tri_corner'],
 'pento_flat':['pento_'+s for s in 'f i l n p t u v w x y z'.split()],
 'pento_3d':['nook','antenna','signpost','crank']+[p+'_'+s for p in ['hook','kink','wiggle','periscope','claw'] for s in ['left','right']],
 'chunky':['slab','plank','step_block','stool','dented_cube','big_zigzag','jack'],
 'hollow':['ring','arch','loop'],
 'party':['heart','mushroom','rocket','dog_bone','crown','snake_left','snake_right'],
 'long_bar':['pole'],
 'giant':['giant_slab','giant_fridge','giant_ring','giant_mega_cube']}
hues={'standard':1,'special':2,'helper':3,'pento_flat':4,'pento_3d':5,'chunky':6,'party':7,'hollow':8,'long_bar':9,'giant':10}
mapping={shape:family for family,shapes in families.items() for shape in shapes}
hand_path=ROOT/'assets/data/shapes/shape_hand_fields.json';hand=json.loads(hand_path.read_text())
assert set(hand)==set(mapping),(set(hand)-set(mapping),set(mapping)-set(hand))
for shape,fields in hand.items():fields.update(family=mapping[shape],hue=hues[mapping[shape]])
hand_path.write_text(json.dumps(hand,indent=2)+'\n')
bank_path=ROOT/'assets/data/shapes/shape_bank.tres';parts=bank_path.read_text().split('[sub_resource')
for i,b in enumerate(parts):
 match=re.search(r'shape_id = &"([^"]+)"',b)
 if not match:continue
 shape=match.group(1);family=mapping[shape]
 b=re.sub(r'^family = .*\n','',b,flags=re.M)
 b=b.replace(match.group(0),match.group(0)+'\nfamily = &"'+family+'"')
 b=re.sub(r'^hue_id = .*$',f'hue_id = {hues[family]}',b,flags=re.M)
 parts[i]=b
bank_path.write_text('[sub_resource'.join(parts))
(ROOT/'assets/data/shapes/families.json').write_text(json.dumps({'schema':1,'source':'design/gdd/piece-set.md#families','families':families,'hue_ids':hues},indent=2)+'\n')
print(dict(collections.Counter(mapping.values())))
