# MB-010 / CH-084 staging
All replace the existing file (built on current on-disk versions, sorted by id):
- assets/data/knobs/goals.json  (+goal.warning_ms, goal.intro_card_ms)
- assets/data/knobs/view.json   (+view.ghost_alpha; yaw_offset_deg/settle_ms kept)
- assets/data/knobs/controls.json (+rotate_repeat, invert_spin, touch_scheme, left_hand_mirror, fog_ghost_preview; kick_off_axis kept)
- assets/data/knobs/rules.json  (+skill.charge_rate, item_slots; layer_order stays removed -> assets/data/rule_layers.json)
Copy over assets/data/knobs/. No code: loader reads the folder. Check: open any knob table / load via KnobDefs; ids unique.
Note: skill.charge_rate and item_slots live in rules.json (no file-prefix rule found); move to a skills file if preferred.
