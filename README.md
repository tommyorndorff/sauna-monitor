# Wi-Fi Sauna Temperature Monitor (ESP32 + K-Type Thermocouple)

A DIY remote temperature monitor for a hot sauna. An ESP32 reads a K-type
thermocouple through a MAX31855 amplifier, runs [ESPHome](https://esphome.io), and
reports temperature over Wi-Fi to [Home Assistant](https://www.home-assistant.io),
which pushes a "sauna is ready" notification to your phone when it hits temperature.

Monitor-only build: it reports the temperature, it does not switch the heater.
Remote-starting a hardwired sauna heater is a separate, safety-critical project and
is out of scope here.

---

## Repository layout

The YAML in this guide is the documentation copy. The maintained, CI-validated
sources live in their own files:

| Path | What |
|------|------|
| [`esphome/sauna-monitor.yaml`](esphome/sauna-monitor.yaml) | ESPHome device config (copy `secrets.yaml.example` → `secrets.yaml`) |
| [`homeassistant/packages/sauna_monitor.yaml`](homeassistant/packages/sauna_monitor.yaml) | Home Assistant package: arming helper + notification automations |
| [`enclosure/`](enclosure/) | 3D-printable enclosure (parametric OpenSCAD) + STLs |
| [`docs/BOM.md`](docs/BOM.md) | Bill of materials with links |
| [`.github/workflows/ci.yml`](.github/workflows/ci.yml) | CI: yamllint + ESPHome + Home Assistant config validation |

---

## Design decisions

- The ESP32 lives outside the hot room. Its silicon and Wi-Fi front-end top out
  around 85 °C, so it cannot survive sauna air. Only the thermocouple probe and its
  lead go into the sauna; the electronics sit in a sealed box on a cool exterior wall.
- K-type thermocouple, not a DS18B20. A DS18B20 is rated to ~125 °C and its cable
  jacket is often the weak point near a sauna ceiling. A K-type probe with a high-temp
  lead handles any sauna temperature with margin. The tradeoff is accuracy
  (~±2 °C vs ±0.5 °C), which does not matter for "is it ready yet."
- IP-rated enclosure protects against outdoor weather and sauna humidity. IP rating is
  about water, not heat, so box placement still matters.

Signal chain: K-type probe → MAX31855 (amplifier + cold-junction compensation) →
SPI → ESP32 → Wi-Fi → Home Assistant.

---

## Bill of materials

Full parts list with purchase links: [`docs/BOM.md`](docs/BOM.md). Summary:

| # | Part | Spec / notes | Approx. |
|---|------|--------------|---------|
| 1 | ESP32 dev board | Standard devkit (ESP32-DevKitC / WROOM-32) | ~$6 |
| 2 | MAX31855 K-type amplifier breakout | 3.3 V logic, SPI, read-only. Genuine MAX31855 preferred; some clones ship a MAX6675 (works, lower resolution) | $5–15 |
| 3 | K-type thermocouple probe | Ungrounded, high-temp lead (fiberglass / stainless braid, ≥400 °C). Threaded or ring-terminal tip for mounting | $8–15 |
| 4 | K-type extension wire/connector | Only if the probe lead won't reach the box. Must be K-type wire, never plain copper | $6 |
| 5 | Enclosure | 3D printed — see [`enclosure/`](enclosure/) (PETG/ASA). Filament + gasket cord only | — |
| 6 | Cable glands (IP68) | One sized to the thermocouple lead OD, one to the power cable OD | $8/pack |
| 7 | Desiccant packs or Gore vent plug | Prevents internal condensation in the sealed box | $5 |
| 8 | High-temp RTV silicone | Rated ~260–300 °C, to seal the wall penetration | $7 |
| 9 | 5 V USB supply + cable | Fed from a GFCI-protected outdoor outlet | $8 |
| 10 | Hookup wire / jumpers + heat-shrink | For the 5 SPI + power lines | $5 |
| 11 | Probe mount hardware | Stainless bracket/bolt to fix the tip near the ceiling | $5 |

Roughly $50–70 beyond the ESP32. Prices vary by vendor; check before buying.

Note: SPI does not use the 4.7 kΩ pull-up resistor that a DS18B20 (1-Wire) build
requires. If you're adapting a DS18B20 guide, drop that resistor.

---

## Wiring

MAX31855 is SPI and read-only, so it uses CLK, MISO (DO), and CS. There is no MOSI.

| MAX31855 pin | ESP32 pin (example) | Notes |
|--------------|---------------------|-------|
| VIN / VCC | 3.3 V | 3.3 V logic board — do not use a 5 V-only module |
| GND | GND | |
| SCK / CLK | GPIO18 | SPI clock |
| DO / SO (MISO) | GPIO19 | data out from the chip |
| CS | GPIO5 | chip select (any free GPIO) |

Thermocouple to the breakout screw terminals — polarity matters:

- K-type convention: yellow = + (positive), red = − (negative).
- Reversed leads read backwards / cold. If the reading moves the wrong way when heated,
  swap the two.
- If extending, splice with K-type wire or a K-type connector only. Plain copper creates
  a second thermocouple junction and a measurement error.

Layout rule: keep the MAX31855 close to the ESP32 (the thermocouple signal is
microvolt-level). Run the thermocouple wire as the long leg into the sauna; do not run
a long SPI cable.

---

## Enclosure, mounting & sealing

- Mount the box on a cool, shaded exterior surface of the sauna building.
- Probe tip goes a hand's width (~10–15 cm) below the ceiling, ideally above or near the
  heater where the air is hottest — the conventional meaning of "sauna temperature."
- Bring the thermocouple lead into the box through an IP68 gland; seal the wall
  penetration into the sauna with high-temp RTV silicone.
- Drop a desiccant pack (or fit a Gore vent plug) inside the box. A sealed enclosure with
  large temperature swings condenses internally — the classic "waterproof" failure.
- Keep the mains side to code for a wet outdoor location; power from a GFCI outlet.

The printable enclosure and print settings are in [`enclosure/`](enclosure/).

---

## Firmware (ESPHome)

Requires ESPHome 2025.x or newer (the `max31855` platform under the SPI bus). Put your
Wi-Fi credentials in `secrets.yaml`. The maintained config is
[`esphome/sauna-monitor.yaml`](esphome/sauna-monitor.yaml).

```yaml
esphome:
  name: sauna-monitor

esp32:
  board: esp32dev

wifi:
  ssid: !secret wifi_ssid
  password: !secret wifi_password

logger:
api:
  encryption:
    key: !secret api_key   # optional but recommended
ota:
  - platform: esphome

# MAX31855 is read-only: CLK + MISO only, no MOSI
spi:
  clk_pin: GPIO18
  miso_pin: GPIO19

sensor:
  - platform: max31855
    name: "Sauna Temperature"
    cs_pin: GPIO5
    update_interval: 10s
```

After the first flash, confirm the sensor appears in ESPHome logs and reads plausible
room temperature before you seal anything up. It publishes to Home Assistant as
`sensor.sauna_temperature` (°C).

---

## Home Assistant: ready notification

Requires the Home Assistant Companion app on your phone for the `notify.mobile_app_*`
service. Rename `notify.mobile_app_your_phone` to your device. The maintained package is
[`homeassistant/packages/sauna_monitor.yaml`](homeassistant/packages/sauna_monitor.yaml).

### Version A — basic (fires on every crossing)

```yaml
alias: Sauna Ready
description: Notify when the sauna reaches usable temperature
triggers:
  - trigger: numeric_state
    entity_id: sensor.sauna_temperature
    above: 80          # °C  (80 °C ≈ 176 °F) — set to taste
    for:
      minutes: 2       # must hold above threshold to ignore spikes
conditions: []
actions:
  - action: notify.mobile_app_your_phone
    data:
      title: "🔥 Sauna is ready"
      message: >
        Sauna hit {{ states('sensor.sauna_temperature') }} °C — good to go.
mode: single
```

The `numeric_state` trigger is edge-triggered, so it fires only on the upward crossing,
not continuously while the sauna holds temperature. The `for: 2 minutes` guards against a
brief overshoot firing it early.

### Version B — arming helper (recommended)

Prevents mid-session false alerts (for example, temp dips after throwing water, then
climbs back through 80 °C). You arm it when you start the heater; it self-disarms after
alerting.

1. Create the helper — Settings → Devices & Services → Helpers → Toggle →
   name it `Sauna Heating` (entity `input_boolean.sauna_heating`). Flip it on when you
   start the heater (dashboard button, phone, or a voice assistant).

2. Ready automation (armed, one-shot):

```yaml
alias: Sauna Ready (armed)
triggers:
  - trigger: numeric_state
    entity_id: sensor.sauna_temperature
    above: 80
    for:
      minutes: 2
conditions:
  - condition: state
    entity_id: input_boolean.sauna_heating
    state: "on"
actions:
  - action: notify.mobile_app_your_phone
    data:
      title: "🔥 Sauna is ready"
      message: >
        Sauna hit {{ states('sensor.sauna_temperature') }} °C — good to go.
  - action: input_boolean.turn_off        # disarm so it won't re-alert this session
    target:
      entity_id: input_boolean.sauna_heating
mode: single
```

3. Auto-disarm on cooldown (clears state if you armed but never went / cancelled):

```yaml
alias: Sauna Disarm on Cooldown
triggers:
  - trigger: numeric_state
    entity_id: sensor.sauna_temperature
    below: 40
    for:
      minutes: 10
conditions:
  - condition: state
    entity_id: input_boolean.sauna_heating
    state: "on"
actions:
  - action: input_boolean.turn_off
    target:
      entity_id: input_boolean.sauna_heating
mode: single
```

### Fahrenheit message (without changing firmware)

Replace the `message:` line in any automation above with:

```yaml
      message: >
        Sauna hit {{ (states('sensor.sauna_temperature') | float * 9/5 + 32) | round(0) }} °F — good to go.
```

### Optional refinements

- Notify all devices: use `action: notify.notify` instead of a single mobile app.
- Announce out loud: add a TTS action to a nearby speaker.
- Auto-arm instead of manual: trigger on temperature rising through a low threshold.
  Simpler to use but more prone to misfires, so manual arming is the default here.

---

## Bring-up checklist

1. Flash ESPHome; confirm the sensor reads room temp on the bench.
2. Warm the probe tip by hand; the reading should rise. If it drops, swap thermocouple polarity.
3. Wire, gland, and seal only after the reading is verified.
4. Add desiccant, close the box, mount it on a cool exterior wall.
5. Run the sauna once and confirm the notification fires at your target temp.

---

## Safety notes

- This device monitors only. It does not and should not control the heater.
- Respect your heater's built-in thermostat, overheat limiter, and auto-shutoff timer.
- All mains wiring to local code; outdoor/wet locations require GFCI protection.
- Never leave a heating sauna unattended, and keep combustibles off the stones.

---

## License

MIT — no warranty. Provided as-is; you are responsible for your own electrical work
and safety.
