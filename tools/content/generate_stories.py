#!/usr/bin/env python3
"""Compile source-provenanced wordless beat staging; never invent gameplay rules."""
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
MASCOTS = dict(zip('meadow candy ice underwater lava forest cave clockwork neon celestial'.split(),
                   'pip mallow pebble puff cinder chip nugget tock glitch comet'.split()))
BOSSES = dict(zip(MASCOTS, 'miller meringue sniffles crab smolder oak geode cuckoo mirrorball moon'.split()))
KEEPSAKES = dict(zip(MASCOTS, 'mill cake ice pearl ember acorn star gear star moon'.split()))
PROPS = {
    'meadow': 'seed bed wind mushroom tower flower fog dew flip mill'.split(),
    'candy': 'cake cake dew bridge tower flower wind star flip cake'.split(),
    'ice': 'ice bed wind egg tower ice fog clock flip egg'.split(),
    'underwater': 'pearl bed wind mushroom tower pearl fog clock flip pearl'.split(),
    'lava': 'ember bed ember mushroom tower ember fog clock wind ember'.split(),
    'forest': 'acorn bed bridge mushroom tower flower fog clock wind bridge'.split(),
    'cave': 'lantern bed gear star tower star fog clock flip star'.split(),
    'clockwork': 'gear bed gear mushroom tower clock clock clock flip clock'.split(),
    'neon': 'star bed note star tower star fog clock flip note'.split(),
    'celestial': 'star bed wind star tower star moon clock flip hat'.split(),
}


def beat(left, right, symbol, duration, pose_left='idle', pose_right='idle',
         emote_left='', emote_right='', **extra):
    return dict(left=left, right=right, symbol=symbol, duration=duration,
                pose_left=pose_left, pose_right=pose_right,
                emote_left=emote_left, emote_right=emote_right, **extra)


def source_sections(path):
    text = (ROOT / path).read_text()
    out = {}
    for m in re.finditer(r'^## \d+\. ([A-Z]+).*$', text, re.M):
        end = text.find('\n## ', m.end())
        out[m.group(1).lower()] = text[m.end():end if end >= 0 else len(text)]
    return out


def main():
    arcs = source_sections('production/levels/campaign/biome-stories.md')
    scripts = source_sections('production/narrative/campaign-story/dialogue-campaign-skits.md')
    meadow = (ROOT / 'design/gdd/narrative/meadow-story.md').read_text()
    stories = {}
    for biome, mascot in MASCOTS.items():
        arc = arcs.get(biome, '')
        descriptions = {int(m.group(1)): (m.group(2), m.group(3))
                        for m in re.finditer(r'^(\d+)\. \*\*(.*?)\*\*: (.+)$', arc, re.M)}
        clues = {}
        for m in re.finditer(r'^\|\s*(0[3-9])\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\|$', scripts.get(biome, ''), re.M):
            clues[int(m.group(1))] = (m.group(2), m.group(3))
        for number in range(1, 11):
            identifier = f'{biome}_{number:02}'
            title, intention = descriptions.get(number, (identifier, 'See canonical biome story.'))
            prop = PROPS[biome][number - 1]
            first_pose = ['give', 'sleep', 'lean', 'hop', 'approach', 'give', 'peek', 'catch', 'dizzy', 'lean'][number - 1]
            first_emote = ['question', 'question', 'sweat', 'exclaim', 'idea', 'idea', 'question', 'sweat', 'dizzy', 'exclaim'][number - 1]
            pre = [beat(mascot, BOSSES[biome] if number == 10 else 'cloud', prop, 2,
                        first_pose, 'lean' if number == 10 else 'idle', first_emote,
                        'smug' if number == 10 else ''),
                   beat(mascot, 'cloud', prop, 1, 'hand_off', 'give', '', 'sparkle')]
            post = [beat(mascot, 'cloud', prop, 2, 'cheer', 'give', 'heart', 'sparkle', symbol_state='complete'),
                    beat(mascot, 'cloud', prop, 2, 'hop' if number % 2 else 'catch', 'wave', 'note', '')]
            clue_intent = ''
            if biome == 'meadow' and 3 <= number <= 9:
                clue_emotes = {3: 'tear', 4: 'dots', 5: 'question', 6: 'sleep', 7: 'exclaim', 8: 'dots', 9: 'tear'}
                clue_props = {3: 'invite', 4: 'wind', 5: 'chair', 6: 'invite', 7: 'invite', 8: 'chair', 9: 'flip'}
                post.append(beat('miller', mascot, clue_props[number], 1, 'peek' if number != 6 else 'sleep',
                                 'wave', clue_emotes[number], '', clue_strength=1))
                clue_intent = 'Miller loneliness clue from meadow-story.md §2 and §5.'
            elif number in clues:
                clue_intent, emote = clues[number]
                words = clue_intent.lower()
                clue_prop = 'chair' if any(w in words for w in ('chair', 'table', 'cup')) else ('gift' if any(w in words for w in ('parcel', 'cloud', 'cuff')) else ('star' if 'dance' in words else ('cube' if any(w in words for w in ('cube', 'doodle', 'block')) else 'invite')))
                pose = 'catch' if biome == 'cave' and 'tower' in words else ('wave' if 'dance' in words else ('sad' if 'tear' in emote else 'peek'))
                icon = re.sub(r'[`*]', '', emote).strip()
                if icon == 'none': icon = ''
                if biome == 'cave': icon = 'dots' if icon == 'tear' else icon
                post.append(beat('mizzle', mascot, clue_prop, 1, pose, 'wave', icon, '',
                                 clue_strength=1 if biome == 'candy' else (2 if biome in ['ice','underwater','clockwork'] else 3)))
            else:
                post.append(beat(mascot, 'cloud', 'invite' if biome == 'meadow' else prop, 1, 'give', 'wave', 'invite' if biome == 'meadow' else 'heart', ''))
            source_intent = dict(arc=intention, clue=clue_intent)
            if biome == 'meadow':
                section = re.search(r'\*\*' + f'{number:02}' + r' .*?\*\*(.*?)(?=\n\*\*|\Z)', meadow, re.S)
                if section:
                    for key, tag in [('intro','I'), ('payoff','P'), ('clue','M')]:
                        line = re.search(r'^- '+tag+r': (.+)$', section.group(1), re.M)
                        if line: source_intent[key] = line.group(1)
            stories[identifier] = dict(biome=biome, level_name=re.sub(r'\s*\(.*?\)', '', title),
                pre=pre, post=post, source_intent=source_intent,
                provenance='Animated staging interpreted from the authored story; not new gameplay rules.')

    # Canonical finale revisions take precedence over older ten-beat outlines.
    stories['meadow_10']['post'] = [
        beat('miller','pip','mill',1.2,'bonk','catch','dizzy','question'),
        beat('pip','miller','basket',1.2,'lean','sad','question','dots',props=['basket','chair']),
        beat('pip','miller','invite',1.2,'give','catch','invite','blush'),
        beat('miller','pip','basket',1.2,'sleep','cheer','heart','note'),
        beat('miller','cloud','mill',1.2,'give','catch','sparkle','heart',keepsake='mill',redeems='miller')]
    final_pairs = {
        'candy': [('meringue','mallow','cake','bonk','dizzy'),('meringue','mallow','cake','dizzy','angry'),('mallow','cloud','cake','cheer','heart'),('mallow','meringue','cake','give','note'),('mizzle','mallow','gift','give','blush')],
        'ice': [('pebble','sniffles','egg','catch','sweat'),('pebble','cloud','ice','wave','dots'),('pebble','cloud','egg','give','heart'),('sniffles','pebble','wind','hop','sparkle'),('lana','mizzle','chair','give','heart')],
        'underwater': [('crab','puff','pearl','bonk','dizzy'),('puff','cloud','pearl','give','heart'),('crab','puff','wind','hop','smug'),('puff','mizzle','invite','give','question'),('mizzle','puff','invite','duck','sweat')],
        'lava': [('smolder','cinder','dew','bonk','dizzy'),('smolder','cinder','dew','catch','dots'),('cinder','cloud','ember','cheer','heart'),('cloud','cinder','invite','give','idea'),('boulder','cinder','gift','give','sparkle')],
        'forest': [('oak','chip','flower','catch','sleep'),('chip','cloud','bridge','cheer','heart'),('oak','chip','flower','sleep','note'),('mizzle','cloud','acorn','approach','blush'),('mizzle','cloud','cube','give','gift')],
        'cave': [('geode','nugget','star','bonk','dizzy'),('geode','nugget','lantern','hop','sparkle'),('nugget','cloud','star','cheer','heart'),('mizzle','cloud','cube','catch','dots'),('glim','cloud','star','give','idea')],
        'clockwork': [('cuckoo','tock','clock','bonk','dizzy'),('cuckoo','tock','gear','hop','smug'),('tock','cloud','gear','cheer','note'),('mizzle','tock','chair','sleep','dots'),('cloud','mizzle','chair','give','heart')],
        'neon': [('mirrorball','glitch','note','dizzy','dizzy'),('mirrorball','glitch','star','bonk','gloom'),('glitch','cloud','star','cheer','sparkle'),('glitch','cloud','note','wave','note'),('mizzle','cloud','star','catch','blush')],
    }
    for biome, pairs in final_pairs.items():
        rows = [beat(left,right,symbol,1.2,pose,'wave',emote,'') for left,right,symbol,pose,emote in pairs]
        rows[2]['keepsake'] = KEEPSAKES[biome]
        if biome in ['ice','lava','cave']:
            friend = {'ice':'lana','lava':'boulder','cave':'glim'}[biome]
            rows.extend([beat(friend,'cloud','gift',2,'give','catch','heart','sparkle'),
                         beat(friend,'cloud','invite',2,'wave','invite','heart','invite',joins=friend)])
        stories[f'{biome}_10']['post'] = rows

    guests = list(BOSSES.values())[:-1]
    stories['celestial_10']['post'] = [
        beat('mizzle','moon','tower',6/7,'bonk','sleep','tear','sleep'),
        beat('cloud','comet','hat',6/7,'cheer','hop','sparkle','heart',keepsake='moon'),
        beat('miller','cloud','invite',6/7,'give','lean','question','exclaim',guests=guests),
        beat('miller','mizzle','invite',6/7,'wave','catch','heart','blush'),
        beat('cloud','mizzle','chair',6/7,'give','catch','sparkle','blush'),
        beat('mizzle','pip','basket',6/7,'sit','give','heart','heart',guests=list(MASCOTS.values())),
        beat('mizzle','cloud','star',6/7,'wave','cheer','heart','sparkle',redeems='mizzle',guests=guests+list(MASCOTS.values()))]
    for identifier, record in stories.items():
        if identifier.endswith('_10'):
            record['source_intent']['finale_source'] = 'production/narrative/campaign-story/dialogue-campaign-skits.md'
            record['replay_post'] = record['post'][-2:]
        record['pre_duration'] = sum(row['duration'] for row in record['pre'])
        record['post_duration'] = sum(row['duration'] for row in record['post'])
    assert len(stories)==100
    assert all(s['pre_duration']==3 for s in stories.values())
    output = dict(schema=1,source=['design/gdd/narrative/meadow-story.md','production/levels/campaign/biome-stories.md','production/narrative/campaign-story/dialogue-campaign-skits.md'],
                  authoring='Original wordless staging follows source intent; timings and poses remain tunable.',stories=stories)
    destination = ROOT/'assets/data/story/campaign_skits.json'
    destination.write_text(json.dumps(output,indent=2)+'\n')
    print(f'Wrote {len(stories)} main-level intro/payoff pairs with ten finale scenes.')


if __name__=='__main__':
    main()
