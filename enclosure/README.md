# 3D-printed enclosure

Parametric OpenSCAD enclosure for the electronics (ESP32 devkit + MAX31855
breakout). Print-ready STLs are checked in; the `.scad` is the source for
adjusting the fit.

Exterior mount only. This box bolts to a cool, shaded outside wall of the sauna
building. It must not go inside the hot room; the ESP32 tops out around 85 °C.
Only the thermocouple probe and its high-temp lead enter the sauna.

## Files

| File | Print orientation |
|------|-------------------|
| `sauna-monitor-enclosure-base.stl` | as-is, floor on the bed; no supports |
| `sauna-monitor-enclosure-lid.stl` | mating face up (flat outer face on the bed) |
| `sauna-monitor-enclosure-gasket.stl` | flat on the bed; print in TPU (optional, see below) |
| `enclosure.scad` | parametric source |

## Waterproofing features (IP65-ish intent)

Gasket-and-screws design, not a hermetic seal:

- Gasket groove in the lid mating face (`gasket_groove_w = 2.4`,
  `gasket_groove_d = 1.6`). Seat either ~2 mm silicone O-ring cord or the printed
  TPU gasket (see below).
- Screw-down lid, 4× M3 corner screws into captive bosses.
- Two IP68 cable-gland holes on the front wall: PG7 (~12.5 mm) for the thermocouple
  lead, PG9 (~15.2 mm) for the USB power cable.
- Gore-style vent plug: a ~12 mm (M12) hole in the rear wall (`enable_vent = true`)
  to equalize pressure and vent humidity instead of relying on a loose desiccant
  pack. Set `enable_vent = false` to omit it and use desiccant instead.
- External mounting ears with 5 mm wall-screw holes.

## Print settings

Outdoor, humid, sun-exposed location. Do not use PLA; it creeps and warps in
heat and UV.

- Material: PETG (default) or ASA (better UV/heat resistance).
- Nozzle / bed: per filament — PETG ~240 °C / 80 °C, ASA ~250 °C / 100 °C (enclosed printer for ASA).
- Layer height: 0.2 mm.
- Walls / perimeters: 4 (≥1.6 mm) for water resistance and screw-boss strength.
- Top/bottom layers: 5+ for a watertight floor and lid.
- Infill: 20–30 %.
- Supports: none. The base prints floor-down; the lid prints mating-face-up.

## Gasket

Two options for the seal in the lid groove:

- Silicone O-ring cord (~2 mm), cut to length. Simplest.
- Printed TPU gasket (`sauna-monitor-enclosure-gasket.stl`), if you'd rather not
  source cord. It follows the groove centreline, sits 0.2 mm under-width so it
  seats, and stands `gasket_proud` (1.0 mm) above the groove to compress under the
  lid.

TPU gasket print settings:

- Material: TPU (95A is fine).
- Layer height: 0.2 mm; walls only (it's thin), ~3 perimeters, 0–15 % infill.
- Slow it down (20–30 mm/s) and disable retraction if your slicer allows; thin TPU
  rings print cleaner slow.
- No supports.

Tune fit with `gasket_fit_clear` (per-side clearance) and `gasket_proud`
(compression height) in `enclosure.scad`.

## Adjusting the fit

Edit the variables at the top of `enclosure.scad`, then re-export:

```bash
# base (with vent plug), lid, and TPU gasket, high facet quality
openscad -o sauna-monitor-enclosure-base.stl   -D 'part="base"'   -D '$fn=96' --export-format binstl enclosure.scad
openscad -o sauna-monitor-enclosure-lid.stl    -D 'part="lid"'    -D '$fn=96' --export-format binstl enclosure.scad
openscad -o sauna-monitor-enclosure-gasket.stl -D 'part="gasket"' -D '$fn=96' --export-format binstl enclosure.scad
```

Measure your actual boards first and set the mounting-hole spacings before a final
print:

- ESP32: `esp_hole_sx`, `esp_hole_sy`, and position `esp_center_x/y`
- MAX31855: `max_hole_sx`, `max_hole_sy`, and position `max_center_x/y`

Other variables: `inner_l/w/h` (cavity size), `wall`, `gland_tc_d` / `gland_pwr_d`
(gland hole sizes), `vent_hole_d`, `enable_vent`.
