#!/usr/bin/env python3
"""Merge per-biome bot playtest JSONs and write production/qa/bot-playtest-<date>.{json,md}. Observations only, no verdicts."""
import json, glob, sys, os
date = sys.argv[1] if len(sys.argv) > 1 else "2026-10-13"
runtime_s = int(sys.argv[2]) if len(sys.argv) > 2 else -1
ORDER = ["meadow","candy","ice","underwater","lava","forest","cave","clockwork","neon","celestial","carnival"]
parts = [json.load(open(p)) for p in sorted(glob.glob("production/qa/bot_tmp/*.json"))]
levels = [l for p in parts for l in p["levels"]]
import re
done = {l["id"] for l in levels}
ATT = re.compile(r"(won|lost|timeout)@(\d+)s/L(\d+)(\((?:[^()]|\([^()]*\))*\))?")
for log in sorted(glob.glob(sys.argv[3] + "/run_*.log")) if len(sys.argv) > 3 else []:
    for line in open(log):
        m = re.match(r"LEVEL (\S+) (\S+) wins=(\d+)/(\d+) wall=\d+ms (.*)", line)
        if not m or m.group(1) in done: continue
        lid = m.group(1); atts = [{"seed": None, "outcome": a, "level_ms": int(t)*1000, "locks": int(k), "stars": None, "reason": (r or "")[1:-1]} for a, t, k, r in ATT.findall(m.group(5))]
        levels.append({"id": lid, "biome": lid.split("_")[0], "tier": 0, "attempts": atts, "wins": int(m.group(3)), "status": m.group(2),
            "recovered_from_log": True, "not_assessed_reason": "recovered from killed-run log (no goal/stars detail)" if m.group(2)=="NOT_ASSESSED" else "", "t3_ms": -1})
for l in levels:
    for x in l.get("attempts", []):
        if x["reason"].startswith("wall_budget"): x["outcome"] = "budget"
    if l["status"] in ("LOST", "TIMEOUT") and all(x["outcome"] == "budget" for x in l["attempts"]):
        l["status"] = "NOT_ASSESSED"; l["not_assessed_reason"] = "every attempt hit the 20 s wall-clock budget (sim too slow); no completability signal"
    elif l["status"] == "TIMEOUT" and any(x["outcome"] == "budget" for x in l["attempts"]):
        l["status"] = "TIMEOUT"; l["not_assessed_reason"] = "some attempts cut by wall-clock budget"
levels.sort(key=lambda l: (ORDER.index(l["biome"]) if l["biome"] in ORDER else 99, l["tier"], l["id"]))
missing = [b for b in ORDER if not any(l["biome"] == b for l in levels)]
def flags(l):
    out = []; a = l.get("attempts", []); t3 = l.get("t3_ms", -1)
    if l["status"] in ("LOST", "TIMEOUT") and not any(x["outcome"] == "budget" for x in a):
        out.append(("NEVER_FINISHED", 3, "bot-capable level, 0/%d wins (%s)" % (len(a), ", ".join(sorted({x["outcome"] for x in a})))))
    if any(x["reason"].startswith("stall") for x in a):
        out.append(("STALL", 4, "level clock froze: " + next(x["reason"] for x in a if x["reason"].startswith("stall"))))
    if any(x["reason"].startswith("wall_budget") for x in a):
        out.append(("SLOW_SIM", 1, next(x["reason"] for x in a if x["reason"].startswith("wall_budget"))))
    wins = [x for x in a if x["outcome"] == "won"]
    if wins and t3 > 0 and min(x["level_ms"] for x in wins) < 0.2 * t3:
        f = min(x["level_ms"] for x in wins)
        out.append(("TOO_EASY", 2, "won in %.1fs = %d%% of 3-star time %ds" % (f/1000, 100*f//t3, t3//1000)))
    losses = [x for x in a if x["outcome"] == "lost"]
    if len(losses) >= 2 and len(losses) == len(a) and len({x["reason"] for x in losses}) == 1 and \
            (len({x["locks"] for x in losses}) == 1 or max(x["level_ms"] for x in losses) - min(x["level_ms"] for x in losses) <= 1000):
        out.append(("SAME_INSTANT_LOSS", 3, "all %d losses: %s at locks %s / %ss" % (len(losses), losses[0]["reason"], sorted({x["locks"] for x in losses}), sorted({x["level_ms"]//1000 for x in losses}))))
    if any(x["outcome"] == "lost" and x["locks"] <= 2 for x in a):
        out.append(("INSTANT_LOSS", 4, "lost with <=2 locks"))
    return out
for l in levels: l["flags"] = [{"flag": f, "weight": w, "detail": d} for f, w, d in flags(l)]
count = lambda st: sum(1 for l in levels if l["status"] == st)
totals = {s: count(s) for s in ["WON","LOST","TIMEOUT","NOT_ASSESSED","LOAD_FAIL"]}
att = [x for l in levels for x in l.get("attempts", [])]
report = {"schema": 1, "date": date, "runtime_s_wall_parallel": runtime_s, "level_count": len(levels), "missing_biomes": missing,
  "totals_by_level": totals, "attempt_totals": {o: sum(1 for x in att if x["outcome"] == o) for o in ["won","lost","timeout","budget"]},
  "caveat": parts[0]["caveat"] + " The tournament bot cannot reliably clear layers on 8x8 boards, so results are completability-only, not difficulty.",
  "method": {k: parts[0][k] for k in ["engine","seeds","hard_cap_ms","assessed_goals","assessed_verbs"]}, "levels": levels}
json.dump(report, open(f"production/qa/bot-playtest-{date}.json", "w"), indent=1)
L = []; w = L.append
w(f"# Bot Playtest — {date}\n\n**Story type**: Integration (completability) | **Gate**: ADVISORY (review input, not a verdict)\n")
w(f"**Tool**: `tools/qa/bot_playtest.gd` (per-biome, run in parallel) + `tools/qa/bot_playtest_report.py`. Engine {parts[0]['engine']}. Seeds {parts[0]['seeds']}. Wall runtime {runtime_s}s.\n")
w("> **Caveat.** WtBotPlayer is a deterministic tournament practice opponent: it waits 45 ticks to think and 6 ticks per input, uses only Y-spin, X/Z moves and hard drop, and does not reliably clear layers on 8x8 boards. "
  "Read these results as **completability signals only, not difficulty**. 'Never finished' means *review*, not proof of impossibility. A WIN is real (the sim granted it).\n")
w("## Method\n- 3 attempts per level (seeds above); the bot calls `update(sim)` and then `sim.step()`, with no rendering.\n- Cap: 2 × the 3-star time (t3), at most 10 simulated minutes; `survive` and score-star levels use 10 min. Each attempt also has a 20 s wall-clock budget (`SLOW_SIM`).\n"
  "- Kit (SELECTING) levels: the harness picks a seeded random shape, because the bot cannot pick.\n- Assessed = goal in {clear_n, height, survive} and control verb `piece`. Other levels run anyway: a win counts, any other result is **NOT ASSESSED**.\n"
  "- Loss reason: `time_limit` / `out_of_pieces` / `top_out_or_goal_fail`, reconstructed from sim state (the sim's `_finish` reason lives only in its event).\n")
w(f"## Totals ({len(levels)} levels)\n\n| WON | LOST | TIMEOUT | NOT ASSESSED | LOAD FAIL |\n|---|---|---|---|---|\n| {totals['WON']} | {totals['LOST']} | {totals['TIMEOUT']} | {totals['NOT_ASSESSED']} | {totals['LOAD_FAIL']} |\n")
w(f"Attempts: {report['attempt_totals']}\n" + (f"\n**Missing biomes (run did not finish)**: {missing}\n" if missing else ""))
w("## Per biome\n\n| Biome | Levels | Won | Lost | Timeout | Not assessed | Flagged |\n|---|---|---|---|---|---|---|")
for b in ORDER:
    bl = [l for l in levels if l["biome"] == b]
    if bl: w(f"| {b} | {len(bl)} | " + " | ".join(str(sum(1 for l in bl if l['status']==s)) for s in ["WON","LOST","TIMEOUT","NOT_ASSESSED"]) + f" | {sum(1 for l in bl if l['flags'])} |")
fl = sorted([l for l in levels if l["flags"]], key=lambda l: -sum(f["weight"] for f in l["flags"]))
w("\n## Flag list (review queue, highest weight first)\n\n| Level | Status | Flags |\n|---|---|---|")
for l in fl: w(f"| {l['id']} | {l['status']} | " + "; ".join(f"**{f['flag']}** {f['detail']}" for f in l["flags"]) + " |")
w("\n## Per level\n\n| Level | Goal | Verb | t3 s | Status | Attempts (outcome@s/locks/stars, reason) | Note |\n|---|---|---|---|---|---|---|")
for l in levels:
    at = "; ".join(f"{x['outcome']}@{x['level_ms']//1000}s/L{x['locks']}/{x['stars'] if x['stars'] is not None else '?'}★" + (f" ({x['reason']})" if x['reason'] else "") for x in l.get("attempts", []))
    w(f"| {l['id']}{' (log)' if l.get('recovered_from_log') else ''} | {l.get('goal',{}).get('type','?')} | {l.get('verb','?')} | {l.get('t3_ms',-1)//1000 if l.get('t3_ms',-1)>0 else '-'} | {l['status']} | {at} | {l.get('not_assessed_reason','')}{' fixed level seed' if l.get('fixed_level_seed') is not None else ''} |")
open(f"production/qa/bot-playtest-{date}.md", "w").write("\n".join(L) + "\n")
print("totals", totals, "attempts", report["attempt_totals"], "missing", missing)
for l in fl[:15]: print(l["id"], l["status"], " | ".join(f["flag"] + ": " + f["detail"] for f in l["flags"]))
