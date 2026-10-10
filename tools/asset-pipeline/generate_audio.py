"""Generate original toy-instrument music and cues. No sampled or licensed inputs.

Run from the repository root with Python 3. WAVs are mono PCM16 / 22.05 kHz.
The synthesis uses decaying harmonics, filtered noise, and an original melody.
"""
from pathlib import Path
import math
import random
import struct
import wave

RATE = 22050
DEST = Path(__file__).resolve().parents[2] / "assets" / "audio"


def write(name, samples, music=False):
    path = DEST / ("music" if music else "sfx") / f"{name}.wav"
    path.parent.mkdir(parents=True, exist_ok=True)
    peak = max(1.0, max(abs(x) for x in samples) / 0.8)
    with wave.open(str(path), "wb") as stream:
        stream.setparams((1, 2, RATE, 0, "NONE", "not compressed"))
        stream.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, x / peak)) * 32767)) for x in samples))


def add_note(samples, start, duration, midi, gain=0.3, style=0):
    freq = 440 * 2 ** ((midi - 69) / 12)
    begin = round(start * RATE)
    count = min(round(duration * RATE), len(samples) - begin)
    for i in range(count):
        t = i / RATE
        envelope = (1 - math.exp(-t * 120)) * math.exp(-t * (4.5 if style == 0 else 2.8))
        envelope *= min(1, (duration - t) * 40)
        tone = math.sin(2 * math.pi * freq * t)
        tone += (0.23 if style == 0 else 0.4) * math.sin(2 * math.pi * freq * 2.003 * t) * math.exp(-t * 8)
        tone += 0.1 * math.sin(2 * math.pi * freq * 3 * t) * math.exp(-t * 13)
        samples[begin + i] += tone * envelope * gain


def cue(name, notes, length=0.6, noise=0):
    samples = [0.0] * round(length * RATE)
    for start, pitch, duration, gain in notes:
        add_note(samples, start, duration, pitch, gain)
    rng = random.Random(773)
    if noise:
        last = 0
        for i in range(len(samples)):
            last = last * 0.8 + rng.uniform(-1, 1) * 0.2
            samples[i] += last * math.exp(-i / RATE * 12) * noise
    write(name, samples)


def main():
    cue("move", [(0, 76, .09, .16)], .11)
    cue("rotate", [(0, 69, .16, .18), (.035, 76, .13, .14)], .2)
    cue("lock", [(0, 48, .23, .35), (0, 60, .18, .2)], .25, .2)
    cue("drop", [(0, 76, .12, .18), (.06, 64, .14, .21), (.13, 48, .2, .3)], .36, .12)
    cue("clear", [(0, 72, .4, .3), (.07, 76, .4, .3), (.14, 79, .4, .3), (.22, 84, .5, .3)], .8)
    cue("warning", [(0, 64, .23, .25), (.23, 60, .23, .25)], .55)
    cue("wind", [(0, 86, .5, .07)], .6, .3)
    cue("flip", [(0, 67, .3, .25), (.12, 74, .3, .24), (.24, 79, .4, .24)], .75)
    cue("win", [(i * .13, pitch, .7, .28) for i, pitch in enumerate([60, 64, 67, 72, 76, 79])], 1.5)
    cue("lose", [(0, 64, .5, .25), (.2, 60, .5, .25), (.4, 55, .7, .25)], 1.2)
    cue("ui", [(0, 79, .15, .19)], .2)
    # Four-bar looping phrase. Notes are deliberately authored here, never sampled.
    melody = [72, 76, 79, 76, 74, 72, 69, 67, 69, 72, 76, 79, 77, 76, 74, 72]
    biomes = {"meadow": (0, 0), "candy": (2, 0), "ice": (5, 1), "underwater": (-5, 1),
              "lava": (-7, 0), "forest": (-2, 0), "cave": (-12, 1), "clockwork": (0, 0),
              "neon": (7, 1), "celestial": (12, 1)}
    beat = 2 / 3
    length = 16 * beat
    for biome, (transpose, style) in biomes.items():
        samples = [0.0] * round(length * RATE)
        for i, note in enumerate(melody):
            add_note(samples, i * beat, beat * .95, note + transpose, .18, style)
            if i % 2 == 0:
                add_note(samples, i * beat, beat * 1.8, [48, 53, 55, 48][i // 4] + transpose, .12, 0)
            if i % 4 == 1:
                add_note(samples, i * beat + beat / 2, beat / 2, note + 12 + transpose, .07, 1)
        write(biome, samples, True)
    print("Generated 11 original cues and 10 original biome loops")


if __name__ == "__main__":
    main()
