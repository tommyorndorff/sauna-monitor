# Bill of Materials

Roughly $50–70 beyond the ESP32. The links are representative product/search links,
not endorsements. Check specs, logic voltage, and price with your own vendor before
buying.

The enclosure is 3D printed from [`../enclosure/`](../enclosure/), so it is not a
purchased line item. You need filament (PETG or ASA — see the enclosure README) and
a silicone gasket cord.

| # | Part | Spec / notes | Approx. | Where to look |
|---|------|--------------|---------|---------------|
| 1 | ESP32 dev board | Standard devkit (ESP32-DevKitC / WROOM-32) | ~$6 | [Espressif DevKitC](https://www.espressif.com/en/products/devkits/esp32-devkitc) · [Adafruit](https://www.adafruit.com/product/3269) · [Amazon search](https://www.amazon.com/s?k=ESP32+DevKitC) |
| 2 | MAX31855 K-type amplifier breakout | 3.3 V logic, SPI, read-only. Genuine MAX31855 preferred; some clones ship a MAX6675 (works, lower resolution) | $5–15 | [Adafruit #269](https://www.adafruit.com/product/269) · [datasheet](https://www.analog.com/media/en/technical-documentation/data-sheets/MAX31855.pdf) |
| 3 | K-type thermocouple probe | Ungrounded, high-temp lead (fiberglass / stainless braid, ≥400 °C). Threaded or ring-terminal tip | $8–15 | [Adafruit #3245](https://www.adafruit.com/product/3245) · [Amazon search](https://www.amazon.com/s?k=K-type+thermocouple+high+temperature+probe) |
| 4 | K-type extension wire/connector | Only if the probe lead won't reach the box. Must be K-type wire, never plain copper | $6 | [Amazon search](https://www.amazon.com/s?k=K-type+thermocouple+extension+wire) |
| 5 | Enclosure | 3D printed — see [`../enclosure/`](../enclosure/). Need only filament + gasket | — | [enclosure/](../enclosure/) |
| 6 | Cable glands (IP68) | One sized to the thermocouple lead OD, one to the power cable OD (PG7 / PG9 common) | $8/pack | [Amazon search](https://www.amazon.com/s?k=IP68+cable+gland+PG7+PG9) |
| 7 | Desiccant packs or Gore vent plug | Prevents internal condensation in the sealed box | $5 | [Desiccant](https://www.amazon.com/s?k=silica+gel+desiccant+packs) · [Gore vent plug](https://www.amazon.com/s?k=Gore+M12+vent+plug) |
| 8 | High-temp RTV silicone | Rated ~260–300 °C, to seal the wall penetration | $7 | [Amazon search](https://www.amazon.com/s?k=high+temp+RTV+silicone+300C) |
| 9 | 5 V USB supply + cable | Fed from a GFCI-protected outdoor outlet | $8 | [Amazon search](https://www.amazon.com/s?k=5V+USB+power+supply) |
| 10 | Hookup wire / jumpers + heat-shrink | For the 5 SPI + power lines | $5 | [Amazon search](https://www.amazon.com/s?k=jumper+wires+heat+shrink) |
| 11 | Probe mount hardware | Stainless bracket/bolt to fix the tip near the ceiling | $5 | local hardware |
| 12 | Lid gasket | Either ~2 mm silicone cord, or print the TPU gasket in [`../enclosure/`](../enclosure/) (needs TPU filament) | $6 | [Silicone cord](https://www.amazon.com/s?k=silicone+rubber+cord+2mm) · [TPU filament](https://www.amazon.com/s?k=TPU+filament) |

Note: SPI does not use the 4.7 kΩ pull-up resistor that a DS18B20 (1-Wire) build
requires. If you're adapting a DS18B20 guide, drop that resistor.
