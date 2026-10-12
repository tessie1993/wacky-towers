# Evidence: party wave-2 landmark toys (MG22-MG36)

Design: `design/gdd/party-minigames-wave2.md` (acceptance criterion 7).
Captured 2026-10-10 by `tools/art/capture_party_wave2.gd`.

These images were really rendered, not mocked. Godot 4.7.2 ran under Xvfb with
`--rendering-driver opengl3 --rendering-method gl_compatibility`; the renderer
reported `gl_compatibility` on `llvmpipe (LLVM 20.1.2)`, which is Mesa's software
OpenGL 4.5. The script checks that no image is a flat fill below the label strip,
and it reported `flat_images=0`.

```sh
xvfb-run -a godot --path . --rendering-driver opengl3 \
  --rendering-method gl_compatibility -s res://tools/art/capture_party_wave2.gd
```

| File | What it shows |
| --- | --- |
| `party_wave2_contact_sheet.png` | MG22-MG36, 5x3, 480x400 per cell, labelled id, name and verb |
| `party_mgNN_<prop>.png` (15) | each new toy on its own |
| `party_wave1_regression_sheet.png` | MG01-MG21 rendered after the change, to check nothing broke |
| `party_art_gallery_all36.png` | `src/view/wt_party_art_gallery.tscn` with all 36 toys |

## Limits

- Every cell uses the same orthographic camera, key light and ambient light as
  `MinigameUI.make_art_preview`, so it shows the in-game landmark framing. The
  project ships on the **Mobile** renderer, and these images come from the
  Compatibility renderer on a software rasteriser. Shading and colour will be a
  little different on a device, and the toys should get a manual look on a phone.
- The background is opaque here so the sheet is readable. In game the preview is
  transparent.
- No lead sign-off yet. The Visual/Feel gate needs one.
