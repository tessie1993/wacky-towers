# ADR-0020: Painted post-process and sparkle FX are first-party; no new addons

Status: Accepted (2026-10-14). Scope: view layer rendering finish.

## Decision
- `src/view/wt_post_process.gd` + `src/view/shaders/spatial_post_painted.gdshader`: one full-screen
  spatial quad parented to the ortho stage camera. Single pass: depth ink outline, depth contact AO,
  mip-chain bloom, depth haze and mip-blur depth of field, warm grade, vignette. Also tunes
  Environment glow. Values: `assets/data/biome_looks.json` `biomes.<id>.post` (defaults in code).
- `src/view/fx/wt_sparkle_fx.gd` + `spatial_fx_sparkle.gdshader`: pooled billboard stars and dust puffs
  hooked into `WtStage.burst` (lock and line clear). Skipped under reduced motion (burst is already gated).
- `spatial_block_biome.gdshader`: additive `edge_ao` uniform (crease darkening by local position).
- Preference `post` (default on) disables the quad.

## Why no addon
Asset Library (4.4/4.5/4.6) and GitHub were searched: outline (2D outline shader, UI Outline),
toon (Flexible Toon, MToon), post process ([OLD] Post Process 4.2), clouds (Sunshine Clouds, POM Clouds,
Clouds for Little Planets), particles (BurstParticles2D, UniParticles3D, YParticles3D, Sparkle Lite).
All are MIT-ish but are 2D-only, UI-only, Forward+/compute-oriented, or restyle materials we already
own via the biome shader. None give a depth-aware effect on Compatibility and Mobile. Nothing was
installed, so no licence obligations were added.

## Renderer notes
Verified on Compatibility (opengl3, llvmpipe). Vulkan is unavailable in this sandbox (no ICD), so Mobile
was not captured. The shader uses `RENDERER_COMPATIBILITY` to pick the NDC depth convention and
INV_PROJECTION_MATRIX for reversed-Z; Mobile output remains UNVERIFIED.
