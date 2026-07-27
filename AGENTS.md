# AGENTS.md

## What this repo is

A DIY hardware project: a Wi-Fi sauna temperature monitor built from an
ESP32 + MAX31855 + K-type thermocouple, running [ESPHome](https://esphome.io) and
reporting to [Home Assistant](https://www.home-assistant.io), which notifies your
phone when the sauna is ready. It is **monitor-only** by design — it reads
temperature and does **not** switch the heater.

The repo holds the firmware config, the Home Assistant automation package, a
3D-printable enclosure, the bill of materials, and CI that validates all of it.

## Project Structure

```
.
├── README.md                         # narrative build guide (the how + why)
├── AGENTS.md                         # this file
├── esphome/
│   ├── sauna-monitor.yaml            # ESPHome device config (ESP32 + max31855 over SPI)
│   └── secrets.yaml.example          # template; copy to secrets.yaml (git-ignored)
├── homeassistant/
│   ├── configuration.yaml            # minimal config, used only for CI validation
│   ├── packages/
│   │   └── sauna_monitor.yaml         # helper + 3 automations (the ready-notification flow)
│   └── README.md                     # HA install / usage notes
├── enclosure/                        # 3D-printable case (parametric OpenSCAD) + print notes
├── docs/
│   └── BOM.md                        # bill of materials with links
└── .github/workflows/ci.yml          # yamllint + esphome config + HA check_config
```

## Working in this repo

- **ESPHome firmware** lives in `esphome/sauna-monitor.yaml`. Pins are exposed as
  `substitutions` at the top. `max31855` is read-only SPI: CLK + MISO only, no MOSI.
  Real credentials go in `esphome/secrets.yaml` (git-ignored); the committed file is
  `secrets.yaml.example`.
- **Home Assistant logic** lives in `homeassistant/packages/sauna_monitor.yaml` as a
  self-contained HA package (an `input_boolean` arming helper + three automations).
  `homeassistant/configuration.yaml` exists **only** so CI can run
  `hass --script check_config`; it is not meant to be copied over a real install.
- **Enclosure** is 3D printed from `enclosure/` (parametric OpenSCAD). Per project
  preference, prefer designing/adjusting the printable model over specifying a
  bought box; use outdoor/heat-appropriate filament (PETG/ASA).
- **Validation:** the top-level `README.md` prose and the YAML must stay consistent —
  if you change a pin, threshold, entity name, or automation behavior in the code,
  update the matching prose in `README.md` and `docs/BOM.md`. CI lints YAML and
  validates both the ESPHome and Home Assistant configs.

## Safety

This project is **monitor-only** and lives **outside** the hot room (the ESP32 tops
out ~85 °C). Do not add heater-control instructions/code, and do not suggest placing
the electronics inside the sauna, without explicitly flagging the safety implications
per the "Safety notes" section of `README.md`.
