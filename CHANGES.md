# Changes from upstream

This is a fork of **Bentix fivem-greenscreener** (https://github.com/Bentix/fivem-greenscreener), licensed under GPL-3.0. The original license is preserved in `LICENSE`.

As required by GPL-3.0 Section 5, this file documents the modifications made to the original work.

## Version history

### 1.0.2
- **Fixed green-tinted hair in captures.** Hair is semi-transparent, so its kept pixels blended with the green screen and came out with a green cast. The server now despills hair shots (clamping the green channel to what red and blue support), so captured hair keeps its true colour.

### 1.0.1
- **Fixed green hair captures.** `ResetPedComponents` tinted the ped with
  `SetPedHairColor(ped, 45, 15)` — index 45 is in the unnatural (green/purple)
  part of the GTA hair palette, so hair rendered green and the server-side
  chroma-key (which suppresses green-dominant pixels) then erased it. Every hair
  screenshot came out green/broken while all other components were fine. The
  tint is now a natural brown (`8, 0`), and it is re-applied right before each
  hair capture (changing the hair drawable resets the tint).

## Summary of changes

- **Screenshot pipeline rewritten** to work on modern FiveM artifacts (Node 18+).
  The original `screenshot-basic` dependency was replaced with the more recent
  `screencapture` resource, and captures are now triggered from a client-side
  Lua bridge (`capture_bridge.lua`) because V8-to-V8 callbacks do not survive
  cross-resource calls on current FXServer builds.

- **Result transport** changed from HTTP POST to `TriggerLatentServerEvent`
  (5 MB/s) with base64-encoded PNGs — avoids the koa-body / formidable
  temp-file pipeline in `screenshot-basic` that crashes on Node 18+
  (`async_hooks` stack corruption).

- **Image post-processing** added on the server side (`server.js`):
  RGB→RGBA promotion, chroma-key (green suppression), connected-component
  analysis to keep only the largest opaque blob and auto-crop to its bounds.

- **Hair capture support** — added component `2` (Hairs) to
  `config.json → cameraSettings.CLOTHING`.

- **New commands**:
  - `/screenshothair` — captures only hair (component 2) for male + female.
  - `/screenshotfemale` — captures female only, excluding hair.

- **Removed placeholder head LODs** (`mp_*_freemode_01^head_000_r.ydd`) from
  `stream/` because they replaced the reduced-LOD head of every freemode ped
  server-wide, causing visual breakage on distant players.

- Miscellaneous: removed orphaned dev files, removed upstream
  `.github/FUNDING.yml`, refreshed `fxmanifest.lua` metadata, reset version
  to `1.0.0` for this fork.

## Credits

Original author: **Bentix** — https://github.com/Bentix/fivem-greenscreener
Fork maintained by: **TheOrb Scripts**
