# AGENTS.md

## What this repo is

A DIY Wi-Fi sauna temperature monitor: ESP32 + MAX31855 + K-type thermocouple,
running [ESPHome](https://esphome.io) and reporting to
[Home Assistant](https://www.home-assistant.io), which notifies a phone when the
sauna reaches temperature. Monitor-only by design: it reads temperature and does
not switch the heater.

The repo holds the firmware config, the Home Assistant automation package, a
3D-printable enclosure, the bill of materials, and CI that validates all of it.

## Project Structure

```
.
├── README.md                         # build guide
├── AGENTS.md                         # this file
├── esphome/
│   ├── sauna-monitor.yaml            # ESPHome device config (ESP32 + max31855 over SPI)
│   └── secrets.yaml.example          # template; copy to secrets.yaml (git-ignored)
├── homeassistant/
│   ├── configuration.yaml            # minimal config, used only for CI validation
│   ├── packages/
│   │   └── sauna_monitor.yaml         # helper + 3 automations (ready-notification flow)
│   └── README.md                     # HA install / usage notes
├── enclosure/                        # parametric OpenSCAD case + print-ready STLs
├── docs/
│   └── BOM.md                        # bill of materials with links
└── .github/workflows/ci.yml          # yamllint + esphome config + HA check_config
```

## Working in this repo

- ESPHome firmware is `esphome/sauna-monitor.yaml`. Pins are exposed as
  `substitutions`. MAX31855 is read-only SPI: CLK + MISO only, no MOSI. Real
  credentials go in `esphome/secrets.yaml` (git-ignored); the committed file is
  `secrets.yaml.example`.
- Home Assistant logic is `homeassistant/packages/sauna_monitor.yaml`, a
  self-contained package (an `input_boolean` arming helper plus three automations).
  `homeassistant/configuration.yaml` exists only so CI can run
  `hass --script check_config`; do not copy it over a real install.
- The enclosure is 3D printed from `enclosure/` (parametric OpenSCAD). Prefer
  adjusting the printable model over specifying a bought box. Use PETG or ASA for
  the outdoor mount, not PLA.
- Keep prose and code consistent: if a pin, threshold, entity name, or automation
  behavior changes in the YAML, update `README.md` and `docs/BOM.md` to match. CI
  lints YAML and validates the ESPHome and Home Assistant configs.

## Documentation style

Write docs and commit messages in a plain, direct tone. State facts; do not sell a
choice. No italics for emphasis. Use bold only for structural labels (table
headers, defined terms), not for emphasis. Cut filler and hedging.

## Safety

Monitor-only, and the electronics live outside the hot room (the ESP32 tops out
around 85 °C). Do not add heater-control instructions or code, and do not place the
electronics inside the sauna, without flagging the safety implications per the
"Safety notes" section of `README.md`.
