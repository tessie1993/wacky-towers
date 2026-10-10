"""Wave-2 audio: party minigames MG22-MG36, wave-3 mechanics, party loop, stingers.

Original procedural synthesis only (no samples, recordings or licensed inputs),
same toy palette as generate_audio.py: wood clacks, felt thumps, glockenspiel
bells, plucks, rubber bonks, soft filtered noise. Mono PCM16 / 22.05 kHz.
Deterministic: every noise source is seeded from the cue name (crc32).

Run from the repository root:  python3 tools/asset-pipeline/generate_audio_wave2.py
"""
from pathlib import Path
import math
import random
import sys
import zlib

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generate_audio import RATE, add_note, write  # noqa: E402  (shared writer + pluck voice)

TAU = 2 * math.pi


def hz(midi):
    return 440 * 2 ** ((midi - 69) / 12)


def buf(length):
    return [0.0] * round(length * RATE)


def tone(s, start, dur, freq, gain=0.25, decay=8.0, partials=((1, 1, 1),), attack=0.003,
         sweep_to=None, vibrato=0.0, vib_rate=6.0):
    """Sine voice with optional exponential pitch sweep and decaying partials.

    partials: (frequency ratio, amplitude, decay multiplier).
    """
    begin = round(start * RATE)
    count = min(round(dur * RATE), len(s) - begin)
    if count <= 0:
        return
    phases = [0.0] * len(partials)
    for i in range(count):
        t = i / RATE
        f = freq if sweep_to is None else freq * (sweep_to / freq) ** (t / dur)
        if vibrato:
            f *= 1 + vibrato * math.sin(TAU * vib_rate * t)
        env = min(1.0, t / attack) * math.exp(-t * decay) * min(1.0, (dur - t) * 60)
        v = 0.0
        for k, (ratio, amp, dmul) in enumerate(partials):
            phases[k] += TAU * f * ratio / RATE
            v += amp * math.sin(phases[k]) * math.exp(-t * decay * (dmul - 1))
        s[begin + i] += v * env * gain


def noise(s, start, dur, gain=0.2, decay=20.0, lp=0.3, hp=False, seed=1, attack=0.001, swell=False):
    """One-pole filtered noise burst. lp: 0..1 smoothing (lower = darker)."""
    rng = random.Random(seed)
    begin = round(start * RATE)
    count = min(round(dur * RATE), len(s) - begin)
    last = prev = 0.0
    for i in range(count):
        t = i / RATE
        last += (rng.uniform(-1, 1) - last) * lp
        v = last - prev if hp else last
        prev = last
        if swell:
            env = math.sin(math.pi * t / dur) ** 2
        else:
            env = min(1.0, t / attack) * math.exp(-t * decay)
        s[begin + i] += v * env * gain * min(1.0, (dur - t) * 60)


def clack(s, start, freq=900, gain=0.3, seed=1, dark=0.5):
    """Wooden toy-block clack: noise transient plus inharmonic wood partials."""
    noise(s, start, .05, gain * .8, 90, dark, seed=seed)
    tone(s, start, .12, freq, gain, 38, ((1, 1, 1), (2.71, .45, 1.6), (4.1, .2, 2.2)))


def bell(s, start, midi, gain=0.2, dur=0.6, decay=5.0):
    """Glockenspiel bar: bright partials that fall away fast, a sine core that rings."""
    tone(s, start, dur, hz(midi), gain, decay, ((1, 1, 1), (2.76, .35, 2.2), (5.4, .15, 3.5)))


def thump(s, start, gain=0.35, f0=150, f1=55, dur=0.18):
    """Felt kick / soft landing: sine pitch drop."""
    tone(s, start, dur, f0, gain, 18, sweep_to=f1)


def boing(s, start, f0, f1, gain=0.25, dur=0.3):
    """Rubber bonk: sweeping sine with a rubbery second partial."""
    tone(s, start, dur, f0, gain, 10, ((1, 1, 1), (1.5, .3, 1.5)), sweep_to=f1)


def seed(name):
    return zlib.crc32(name.encode())


def out(name, length, *layers, music=False):
    s = buf(length)
    for layer in layers:
        layer(s)
    write(name, s, music)
    return name


# --------------------------------------------------------------------------- minigame cues
def minigame_cues():
    made = []
    m = made.append
    # MG Bowling: long felt roll, pin knock, strike
    m(out("mg_bowl_roll", .9,
          lambda s: noise(s, 0, .9, .32, 0, .06, seed=seed("roll"), swell=True),
          lambda s: tone(s, 0, .9, 70, .12, 1.2, vibrato=.08, vib_rate=11)))
    m(out("mg_pin_knock", .45, *[
        (lambda k: lambda s: clack(s, k * .045, 1100 - k * 140, .26 - k * .05, seed("pin") + k))(k)
        for k in range(3)]))
    m(out("mg_strike", 1.1, *[
        (lambda k: lambda s: clack(s, k * .035, 1300 - (k % 4) * 170, .24, seed("strike") + k))(k)
        for k in range(7)],
        lambda s: [bell(s, .28 + i * .09, p, .2, .7) for i, p in enumerate([72, 76, 79, 84])]))
    # MG Simon: four pads, C major arpeggio (C5 E5 G5 C6), soft-mallet marimba
    for i, p in enumerate([72, 76, 79, 84]):
        m(out(f"mg_simon_{i}", .38, (lambda p: lambda s: tone(
            s, 0, .38, hz(p), .3, 9, ((1, 1, 1), (4.0, .25, 3), (10.0, .06, 6))))(p)))
    # MG Quick Drop: go chime, false-start honk
    m(out("mg_go", .32, lambda s: bell(s, 0, 84, .22, .32, 7), lambda s: bell(s, .05, 91, .14, .27, 8)))
    m(out("mg_false_start", .45,
          lambda s: tone(s, 0, .2, hz(50), .26, 3, ((1, 1, 1), (2, .5, 1), (3, .3, 1))),
          lambda s: tone(s, .2, .25, hz(46), .26, 5, ((1, 1, 1), (2, .5, 1), (3, .3, 1)))))
    # MG Count: reveal flourish, correct / wrong
    m(out("mg_count_reveal", .55, *[
        (lambda k, p: lambda s: bell(s, k * .06, p, .14 + k * .015, .3, 9))(k, p)
        for k, p in enumerate([79, 81, 83, 84, 88])]))
    m(out("mg_correct", .4, lambda s: add_note(s, 0, .16, 79, .25), lambda s: add_note(s, .1, .3, 84, .25)))
    m(out("mg_wrong", .42, lambda s: boing(s, 0, 330, 200, .2, .42)))
    # MG Odd One Out pick, MG Pairs flip / match
    m(out("mg_odd_pick", .2, lambda s: boing(s, 0, 520, 900, .22, .14),
          lambda s: clack(s, 0, 1400, .12, seed("odd"))))
    m(out("mg_card_flip", .16, lambda s: noise(s, 0, .16, .3, 30, .7, hp=True, seed=seed("card"))))
    m(out("mg_card_match", .5, lambda s: bell(s, 0, 81, .2, .45), lambda s: bell(s, .09, 88, .2, .41)))
    # MG Dodge: hit bonk, heart lost
    m(out("mg_dodge_hit", .36, lambda s: boing(s, 0, 420, 150, .3, .3), lambda s: thump(s, 0, .2)))
    m(out("mg_heart_lost", .55, lambda s: bell(s, 0, 76, .18, .3), lambda s: bell(s, .14, 71, .16, .4)))
    # MG Slide puzzle tile, MG Mirror paint dab, MG Parade tick
    m(out("mg_slide_tile", .2, lambda s: noise(s, 0, .14, .22, 18, .25, seed=seed("slide")),
          lambda s: clack(s, .12, 700, .16, seed("slide2"))))
    m(out("mg_paint_dab", .16, lambda s: tone(s, 0, .16, 260, .25, 20, sweep_to=520),
          lambda s: noise(s, 0, .06, .1, 60, .2, seed=seed("dab"))))
    m(out("mg_parade_tick", .1, lambda s: clack(s, 0, 1500, .2, seed("tick"), .8)))
    # MG Whack: bonk (squeaky hammer), bomb (felt puff), golden (bells)
    m(out("mg_whack_bonk", .26, lambda s: clack(s, 0, 950, .25, seed("whack")),
          lambda s: tone(s, .01, .2, 1200, .1, 14, sweep_to=1700)))
    m(out("mg_whack_bomb", .6, lambda s: thump(s, 0, .4, 120, 40, .4),
          lambda s: noise(s, 0, .6, .3, 7, .12, seed=seed("bomb"))))
    m(out("mg_whack_golden", .65, lambda s: clack(s, 0, 950, .2, seed("gold")),
          *[(lambda k, p: lambda s: bell(s, .04 + k * .05, p, .16, .5))(k, p)
            for k, p in enumerate([84, 88, 91, 96])]))
    # MG Tower pull (jenga) and topple
    m(out("mg_jenga_pull", .32, lambda s: noise(s, 0, .3, .2, 4, .35, seed=seed("pull"), swell=True),
          lambda s: clack(s, .26, 620, .14, seed("pull2"))))
    rng = random.Random(seed("topple"))
    hits = [(i * .09 + rng.uniform(0, .04), rng.choice([500, 620, 760, 880, 1020])) for i in range(10)]
    m(out("mg_topple", 1.15, *[(lambda t, f, k: lambda s: clack(s, t, f, .26 - k * .015, seed("tp") + k))(t, f, k)
                               for k, (t, f) in enumerate(hits)],
          lambda s: thump(s, .9, .3, 110, 45, .25)))
    # MG Spin match: ratchet click and solved chime
    m(out("mg_spin_click", .08, lambda s: clack(s, 0, 1800, .16, seed("ratchet"), .9)))
    m(out("mg_spin_match", .5, lambda s: [bell(s, i * .07, p, .18, .4) for i, p in enumerate([76, 79, 83])]))
    # MG Plinko: peg tink, bucket thunk, jackpot
    m(out("mg_plinko_peg", .12, lambda s: tone(s, 0, .12, hz(96), .16, 35, ((1, 1, 1), (2.4, .3, 1.5)))))
    m(out("mg_plinko_bucket", .36, lambda s: thump(s, 0, .3, 180, 70, .2), lambda s: add_note(s, .02, .3, 67, .18)))
    m(out("mg_jackpot", 1.2, *[(lambda k: lambda s: bell(s, k * .05, [72, 76, 79, 84][k % 4] + 12 * (k // 4), .13, .45))(k)
                               for k in range(10)],
          lambda s: bell(s, .55, 96, .2, .65, 3), lambda s: bell(s, .55, 91, .14, .65, 3)))
    # MG Dig: shovel crunch, treasure fanfare
    m(out("mg_dig_shovel", .26, lambda s: noise(s, 0, .26, .35, 14, .45, seed=seed("dig")),
          lambda s: thump(s, .02, .18, 160, 90, .1)))
    m(out("mg_treasure", .95, lambda s: noise(s, 0, .3, .07, 8, .9, hp=True, seed=seed("sparkle")),
          *[(lambda k, p: lambda s: add_note(s, k * .1, .5, p, .2))(k, p) for k, p in enumerate([67, 72, 76])],
          lambda s: bell(s, .32, 84, .22, .6, 4)))
    # Generic party send / attack incoming
    m(out("mg_send", .36, lambda s: noise(s, 0, .36, .22, 0, .5, hp=True, seed=seed("send"), swell=True),
          lambda s: tone(s, 0, .3, 400, .12, 5, sweep_to=1400)))
    m(out("mg_attack_warning", .46, lambda s: tone(s, 0, .14, hz(83), .28, 6, ((1, 1, 1), (3, .2, 1))),
          lambda s: tone(s, .16, .14, hz(83), .28, 6, ((1, 1, 1), (3, .2, 1))),
          lambda s: tone(s, .32, .14, hz(78), .28, 6, ((1, 1, 1), (3, .2, 1)))))
    return made


# --------------------------------------------------------------------------- wave-3 mechanic cues
def wave3_cues():
    made = []
    m = made.append
    m(out("w3_magnet_hum", .8, lambda s: tone(s, 0, .8, 110, .22, .5, ((1, 1, 1), (2, .5, 1), (3, .3, 1)),
                                               attack=.15, vibrato=.03, vib_rate=7)))
    m(out("w3_magnet_pull", .42, lambda s: tone(s, 0, .4, 300, .22, 4, ((1, 1, 1), (2, .3, 1)), sweep_to=900),
          lambda s: clack(s, .36, 1200, .12, seed("mag"))))
    m(out("w3_tile_crack", .3, lambda s: [noise(s, k * .045, .05, .25, 80, .8, hp=True, seed=seed("crk") + k)
                                          for k in range(4)]))
    m(out("w3_tile_crumble", .75, lambda s: noise(s, 0, .7, .3, 5, .25, seed=seed("crumble")),
          lambda s: [clack(s, .05 + k * .1, 500 + 90 * (k % 3), .12, seed("cr") + k, .3) for k in range(6)]))
    m(out("w3_chameleon", .6, lambda s: tone(s, 0, .6, hz(76), .14, 3, ((1, 1, 1), (2.01, .4, 1)),
                                              attack=.05, sweep_to=hz(88), vibrato=.01, vib_rate=9),
          lambda s: noise(s, 0, .6, .05, 0, .9, hp=True, seed=seed("cham"), swell=True)))
    m(out("w3_anvil_whistle", .5, lambda s: tone(s, 0, .5, 1600, .2, 1.5, sweep_to=700, attack=.03)))
    m(out("w3_anvil_clang", 1.0, lambda s: tone(s, 0, 1.0, 330, .22, 4, ((1, 1, 1), (2.32, .5, 1.2), (3.87, .3, 1.6), (5.1, .15, 2))),
          lambda s: thump(s, 0, .3, 120, 45, .25)))
    m(out("w3_jumble_warn", .36, lambda s: [clack(s, k * .09, 1200 - k * 80, .12, seed("jw") + k, .8) for k in range(3)]))
    m(out("w3_queue_jumble", .5, lambda s: [clack(s, k * .055, [900, 1300, 1100, 1500, 1000, 1400, 1200][k], .14,
                                                   seed("jq") + k, .8) for k in range(7)]))
    m(out("w3_mystery_reveal", .55, lambda s: noise(s, 0, .2, .12, 0, .6, hp=True, seed=seed("myst"), swell=True),
          lambda s: add_note(s, .16, .18, 72, .2), lambda s: add_note(s, .26, .29, 79, .24)))
    m(out("w3_pressure_hiss", .4, lambda s: noise(s, 0, .4, .16, 0, .95, hp=True, seed=seed("hiss"), swell=True)))
    m(out("w3_pressure_release", .95, lambda s: tone(s, 0, .5, hz(86), .1, 1, ((1, 1, 1), (1.5, .4, 1)), attack=.04),
          lambda s: noise(s, .05, .9, .32, 3, .9, hp=True, seed=seed("steam")),
          lambda s: thump(s, .05, .2, 140, 60, .2)))
    m(out("w3_coin", .32, lambda s: tone(s, 0, .09, hz(83), .18, 4, ((1, 1, 1), (2, .2, 1))),
          lambda s: tone(s, .08, .24, hz(88), .18, 7, ((1, 1, 1), (2, .2, 1)))))
    m(out("w3_echo", .8, lambda s: [add_note(s, k * .17, .2, 74, .22 * (.55 ** k)) for k in range(4)]))
    m(out("w3_hinge_stuck", .6, lambda s: tone(s, 0, .42, 520, .12, 1, ((1, 1, 1), (1.98, .5, 1), (3.1, .3, 1)),
                                               attack=.04, sweep_to=420, vibrato=.05, vib_rate=23),
          lambda s: clack(s, .42, 480, .26, seed("hinge"), .3)))
    m(out("w3_bolt_warning", .6, lambda s: noise(s, 0, .6, .14, 0, .9, hp=True, seed=seed("crackle"), swell=True),
          lambda s: tone(s, 0, .6, hz(88), .06, 1, attack=.2, vibrato=.02, vib_rate=14)))
    m(out("w3_bolt_strike", .7, lambda s: noise(s, 0, .25, .35, 18, .95, hp=True, seed=seed("zap")),
          lambda s: tone(s, 0, .2, 1800, .12, 15, sweep_to=300), lambda s: thump(s, .03, .36, 140, 40, .45)))
    m(out("w3_bolt_fizzle", .4, lambda s: noise(s, 0, .4, .14, 8, .8, hp=True, seed=seed("fizz")),
          lambda s: tone(s, 0, .35, 900, .06, 6, sweep_to=400)))
    m(out("w3_confetti", .6, lambda s: boing(s, 0, 300, 700, .25, .12),
          lambda s: noise(s, 0, .05, .2, 90, .6, seed=seed("pop")),
          *[(lambda k, p: lambda s: bell(s, .08 + k * .06, p, .1, .3, 9))(k, p) for k, p in enumerate([88, 91, 86, 93, 89])]))
    m(out("w3_quicksand_warn", .5, lambda s: [boing(s, k * .15, 160, 230, .21, .14) for k in range(3)]))
    m(out("w3_quicksand_sink", .75, lambda s: tone(s, 0, .7, 380, .2, 3, ((1, 1, 1), (2, .2, 1)), sweep_to=90),
          lambda s: noise(s, 0, .7, .14, 3, .08, seed=seed("sand"))))
    m(out("w3_fever_start", .9, *[(lambda k, p: lambda s: add_note(s, k * .07, .3, p, .2))(k, p)
                                  for k, p in enumerate([67, 71, 74, 79, 83, 86])],
          lambda s: bell(s, .45, 91, .2, .45, 4)))
    m(out("w3_fever_end", .6, *[(lambda k, p: lambda s: add_note(s, k * .09, .3, p, .18))(k, p)
                                for k, p in enumerate([79, 74, 71, 67])]))
    m(out("w3_gold_row", .6, lambda s: bell(s, 0, 86, .18, .6, 4), lambda s: bell(s, .07, 93, .12, .53, 4)))
    m(out("w3_gold_clear", 1.0, *[(lambda k, p: lambda s: bell(s, k * .06, p, .18, .7, 3.5))(k, p)
                                  for k, p in enumerate([79, 84, 88, 91, 96])],
          lambda s: noise(s, 0, .8, .06, 3, .9, hp=True, seed=seed("goldspark"))))
    return made


# --------------------------------------------------------------------------- music
def party_loop():
    """Upbeat toy-band loop: 132 bpm, 8 bars of 4/4 (about 14.5 s), seamless.

    Glockenspiel melody, plucked bass, woodblock offbeats, shaker 8ths, felt kick.
    """
    beat = 60 / 132
    bars = 8
    s = buf(bars * 4 * beat)
    chords = [(48, [60, 64, 67]), (45, [57, 60, 64]), (41, [57, 60, 65]), (43, [55, 59, 62])] * 2
    # 8th-note melody per bar (None = rest); the authored hook, then an answer phrase.
    melody = [
        [72, None, 76, 79, 76, None, 74, 72], [69, None, 72, 76, 74, 72, 71, None],
        [72, None, 69, 72, 77, 76, 74, None], [71, 74, 79, None, 77, 74, 71, None],
        [72, None, 76, 79, 84, None, 79, 76], [81, 79, 76, None, 72, None, 76, 77],
        [77, None, 76, 74, 72, None, 69, 72], [74, None, 71, 74, 79, None, None, None],
    ]
    rng_seed = seed("party")
    for b in range(bars):
        t0 = b * 4 * beat
        root, triad = chords[b]
        for q in range(4):
            tq = t0 + q * beat
            if q in (0, 2):
                thump(s, tq, .28, 130, 48, .22)
                add_note(s, tq, beat * .9, root if q == 0 else root + 7, .2, 0)
            else:
                clack(s, tq, 1250, .12, rng_seed + b * 8 + q, .8)
                for k, p in enumerate(triad):  # off-beat ukulele-ish strum
                    add_note(s, tq + beat / 2 + k * .012, beat * .45, p, .06, 1)
            for e in range(2):
                noise(s, tq + e * beat / 2, .06, .05 if e else .035, 60, .95, hp=True, seed=rng_seed + b * 31 + q * 2 + e)
        for e, p in enumerate(melody[b]):
            if p is not None:
                bell(s, t0 + e * beat / 2, p, .15, beat * .95, 5)
    write("party", s, True)
    return "party"


def pack_fanfare():
    """Level-pack unlock fanfare, about 2.4 s: drum roll, rising triplet, held chord."""
    s = buf(2.4)
    noise(s, 0, .55, .12, 0, .3, seed=seed("roll2"), swell=True)
    for k in range(10):
        clack(s, k * .05, 700, .06 + k * .01, seed("fr") + k, .5)
    for k, p in enumerate([67, 72, 76]):
        add_note(s, .55 + k * .12, .25, p, .24, 1)
    thump(s, .92, .35, 140, 50, .3)
    for p in [72, 76, 79, 84]:
        add_note(s, .92, 1.4, p, .14, 1)
    for k, p in enumerate([84, 88, 91, 96, 91, 96]):
        bell(s, .92 + k * .11, p, .12, .9, 3)
    write("pack_fanfare", s, True)
    return "pack_fanfare"


def stage_clear():
    """Stage-clear stinger, about 1.6 s: bouncing arpeggio to a ringing top note."""
    s = buf(1.6)
    for k, p in enumerate([60, 64, 67, 72, 76]):
        add_note(s, k * .08, .3, p, .2)
        if k % 2 == 0:
            clack(s, k * .08, 1300, .08, seed("sc") + k, .8)
    thump(s, .42, .3, 140, 50, .25)
    bell(s, .42, 84, .22, 1.15, 2.8)
    bell(s, .42, 79, .14, 1.15, 2.8)
    noise(s, .42, .8, .05, 3, .9, hp=True, seed=seed("scspark"))
    write("stage_clear", s, True)
    return "stage_clear"


# --------------------------------------------------------------------------- opening-menu UI
def celesta(s, start, midi, gain=0.18, dur=0.9, decay=3.2):
    """Celesta / music-box tine: pure fundamental, faint 4th and 9th-ish overtones."""
    tone(s, start, dur, hz(midi), gain, decay, ((1, 1, 1), (4.0, .18, 3.0), (8.9, .05, 5.0)), attack=.002)


def ui_cues():
    made = []
    m = made.append
    m(out("ui_tap", .12, lambda s: clack(s, 0, 1700, .14, seed("tap"), .9),
          lambda s: celesta(s, 0, 91, .07, .12, 25)))
    m(out("ui_back", .22, lambda s: celesta(s, 0, 84, .14, .12, 18), lambda s: celesta(s, .07, 79, .14, .15, 14)))
    m(out("ui_confirm", .4, lambda s: celesta(s, 0, 79, .16, .2, 10), lambda s: celesta(s, .08, 86, .18, .32, 7)))
    m(out("ui_toggle", .12, lambda s: clack(s, 0, 1250, .15, seed("toggle"), .8),
          lambda s: clack(s, .045, 1550, .12, seed("toggle2"), .8)))
    m(out("ui_star", .55, lambda s: thump(s, 0, .18, 200, 90, .1),
          lambda s: celesta(s, .02, 88, .18, .5, 5), lambda s: celesta(s, .1, 95, .12, .45, 6)))
    m(out("ui_unlock", .9, lambda s: clack(s, 0, 900, .16, seed("latch")),
          lambda s: clack(s, .06, 1300, .12, seed("latch2")),
          *[(lambda k, p: lambda s: celesta(s, .14 + k * .08, p, .16, .7, 3.5))(k, p) for k, p in enumerate([72, 76, 79, 84])]))
    m(out("ui_whoosh", .45, lambda s: noise(s, 0, .45, .26, 0, .35, hp=True, seed=seed("whoosh"), swell=True),
          lambda s: tone(s, 0, .4, 250, .05, 2, sweep_to=600, attack=.1)))
    rng = random.Random(seed("wizard"))
    sparkle = [(k * .045 + rng.uniform(0, .02), rng.choice([88, 91, 93, 95, 96, 98, 100])) for k in range(14)]
    m(out("wizard_sparkle", 1.1, lambda s: noise(s, 0, 1.0, .05, 0, .95, hp=True, seed=seed("wizdust"), swell=True),
          *[(lambda k, t, p: lambda s: celesta(s, t, p, .11 - k * .005, .4, 7))(k, t, p) for k, (t, p) in enumerate(sparkle)]))
    return made


def title_waltz():
    """Opening-menu loop: warm music-box waltz, 3/4 at 96 bpm, 8 bars (15 s), seamless.

    Celesta melody, soft plucked bass on beat 1, music-box dyads on beats 2 and 3.
    """
    beat = 60 / 96
    bars = 8
    s = buf(bars * 3 * beat)
    harmony = [(48, [64, 67]), (45, [64, 69]), (41, [65, 69]), (43, [62, 67]),
               (48, [64, 67]), (40, [64, 67]), (41, [65, 69]), (43, [62, 65])]
    # quarter-note melody, three per bar; 0 = held/rest
    melody = [[76, 79, 84], [83, 81, 76], [77, 81, 84], [83, 79, 0],
              [76, 79, 84], [86, 84, 79], [81, 77, 74], [72, 74, 0]]
    for b in range(bars):
        t0 = b * 3 * beat
        root, dyad = harmony[b]
        add_note(s, t0, beat * 2.6, root, .16, 1)
        for q in (1, 2):
            for p in dyad:
                celesta(s, t0 + q * beat, p, .06, beat * .9, 4)
        for q, p in enumerate(melody[b]):
            if p:
                celesta(s, t0 + q * beat, p, .16, beat * (2.2 if melody[b][min(q + 1, 2)] == 0 else 1.2), 2.6)
        if b % 2 == 1:  # a twinkle answering each phrase
            celesta(s, t0 + 2.5 * beat, melody[b][1] + 12, .05, beat, 5)
    write("title", s, True)
    return "title"


def main():
    sfx = minigame_cues() + wave3_cues() + ui_cues()
    music = [party_loop(), pack_fanfare(), stage_clear(), title_waltz()]
    print(f"Generated {len(sfx)} wave-2 cues and {len(music)} music files: " + ", ".join(sfx + music))


if __name__ == "__main__":
    main()
