# Home Assistant configuration

The sauna-ready notification logic is in [`packages/sauna_monitor.yaml`](packages/sauna_monitor.yaml),
a self-contained Home Assistant [package](https://www.home-assistant.io/docs/configuration/packages/).
It provides:

- `input_boolean.sauna_heating` — the arming helper, flipped on when you start the heater.
- `Sauna Ready (armed)` — one-shot notification when the temperature holds above 80 °C
  while armed; disarms itself after alerting.
- `Sauna Disarm on Cooldown` — clears the armed state if you never went.

## Install

1. Copy `packages/sauna_monitor.yaml` into your Home Assistant config under a `packages/`
   directory (for example `/config/packages/sauna_monitor.yaml`).
2. Enable packages in `configuration.yaml`:

   ```yaml
   homeassistant:
     packages: !include_dir_named packages
   ```

3. Replace `notify.mobile_app_your_phone` with your device's notify service
   (requires the Home Assistant Companion app).
4. Reload YAML: Developer Tools → YAML → All (or restart).

The sensor `sensor.sauna_temperature` is published by the ESP32 — see
[`../esphome/`](../esphome/).

## Prerequisites

- Home Assistant Companion app on the phone (for `notify.mobile_app_*`).
- The ESPHome device online and its sensor discovered in Home Assistant.

## Fahrenheit message

Replace the `message:` line with:

```yaml
message: >
  Sauna hit {{ (states('sensor.sauna_temperature') | float * 9/5 + 32) | round(0) }} °F — good to go.
```

## Notes

- The `configuration.yaml` in this folder is a minimal file used only for CI
  validation (`hass --script check_config`). Do not copy it over a real install;
  merge the `packages:` line into your existing config instead.
- A simpler unarmed version (fires on every upward crossing) and other refinements
  are described in the top-level [`README.md`](../README.md#home-assistant-ready-notification).
