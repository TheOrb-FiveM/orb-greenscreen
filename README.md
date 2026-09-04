# orb-greenscreen

A clothing & prop image generator for FiveM — the companion tool for [**orb-clothing**](https://github.com/TheOrb-FiveM/orb-clothing). It cycles a freemode ped through every clothing component, prop, object or vehicle, captures each one against a green screen, and post-processes the result into a clean, transparent PNG ready to use as a store/preview thumbnail.

> **This is a fork of [Bentix-cs/fivem-greenscreener](https://github.com/Bentix-cs/fivem-greenscreener)** (GPL-3.0), rewritten to run on modern FiveM artifacts and hardened for real servers. See [Improvements over upstream](#improvements-over-upstream) and [`CHANGES.md`](CHANGES.md).

---

## Features

- **Full catalogue capture** — every drawable of every clothing component and prop, for both freemode models (`mp_m_freemode_01` / `mp_f_freemode_01`).
- **Selective capture** — hair only, female only, a single component/drawable, objects, or vehicles.
- **Automatic post-processing** — RGB→RGBA promotion, chroma-key (green removal), largest-blob isolation and auto-crop to a tight transparent PNG.
- **Per-component framed cameras** — FOV, rotation and height tuned per component in `config.json`.
- **Transparent output**, saved straight to `images/` grouped by type.

## Requirements

- [`screencapture`](https://github.com/itschip/screencapture) (or `screenshot-basic`)
- [`ox_lib`](https://github.com/overextended/ox_lib)
- [`yarn`](https://github.com/citizenfx/fivem/tree/master/ext/native-decls) — the built-in FiveM yarn resource (installs the Node dependencies on first start)

## Installation

1. Drop `orb-greenscreen` into your `resources` folder.
2. Ensure the dependencies **before** it in your `server.cfg`:
   ```cfg
   ensure ox_lib
   ensure screencapture
   ensure yarn
   ensure orb-greenscreen
   ```
3. Start the server once — `yarn` installs the Node dependencies automatically (first boot only).

> **Tip:** orb-greenscreen is a build-time tool, not a runtime dependency. Once your images are generated and moved into orb-clothing, you can stop/remove it. Start it again only when you add new clothing and need fresh previews.

## Usage

Run these commands in-game (as an admin) once the resource is started:

| Command | What it does |
|---|---|
| `/screenshot` | Capture **all** clothing components + props, male + female |
| `/screenshothair` | Capture **hair only** (male + female) |
| `/screenshotfemale` | Capture female only (everything except hair) |
| `/customscreenshot <component> <drawable\|all> <PROPS\|CLOTHING> <male\|female\|both> [cameraSettings]` | Capture a specific component/drawable |
| `/screenshotobject <objectHash>` | Capture a single object/weapon model |
| `/screenshotvehicle <model\|all> [primaryColor] [secondaryColor]` | Capture a vehicle (or all vehicles) |

Captured PNGs are written to `images/<type>/` (e.g. `images/clothing/male_11_5.png`). Move them into orb-clothing's `html/assets/clothing_images/` (or your CDN) when you're done.

### Config highlights (`config.json`)

- `includeTextures` *(default `false`)* — also capture every texture variation of each drawable. **Warning:** dramatically more images and much heavier on RAM/streaming.
- `overwriteExistingImages` — overwrite vs. skip files that already exist.
- `cameraSettings` — per-component FOV / rotation / height.
- `greenScreenPosition` / `greenScreenRotation` — where the ped is posed for capture.

## Improvements over upstream

This fork changes the following versus [Bentix-cs/fivem-greenscreener](https://github.com/Bentix-cs/fivem-greenscreener):

- **Modern screenshot pipeline** — replaced `screenshot-basic` with `screencapture`, driven from a client-side Lua bridge (V8→V8 cross-resource callbacks don't survive current FXServer builds).
- **Reliable transport** — results are sent via `TriggerLatentServerEvent` (5 MB/s, base64) instead of the HTTP/`koa-body` path that crashes on Node 18+.
- **Better post-processing** — server-side chroma-key, connected-component analysis to keep only the largest opaque blob, and auto-crop to a tight transparent PNG.
- **Hair capture support** — component `2` added, plus `/screenshothair` and `/screenshotfemale`.
- **Removed placeholder head LODs** that replaced every freemode ped's reduced-LOD head server-wide (a source of visual breakage on distant players).
- Fixes and cleanups — see [`CHANGES.md`](CHANGES.md) for the full, GPL-required list.

## Credits

- Original author: **Bentix** — [Bentix-cs/fivem-greenscreener](https://github.com/Bentix-cs/fivem-greenscreener)
- Fork maintained by: **[TheOrb Scripts](https://github.com/TheOrb-FiveM)**

## License

Licensed under **GPL-3.0**, inherited from the upstream project. See [`LICENSE`](LICENSE) and [`CHANGES.md`](CHANGES.md) (GPL-3.0 §5 requires documenting modifications — that file does).
