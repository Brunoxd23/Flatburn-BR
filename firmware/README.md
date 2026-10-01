# Flatburn-firmware

> 🇧🇷 **Documentação em Português:** Consulte o [README.pt-BR.md](README.pt-BR.md) para o guia completo de arquitetura, compilação, gravação e comandos da CLI.

## Environment
- Code developed using [Particle.io plugin for MS Code](https://www.particle.io/workbench/)
- Devices can be flashed both via cable or cloud flash (data costs)
- Compatible with [Particle deviceOS@6.3.4](https://docs.particle.io/reference/device-os/firmware)
- Written in C++ and [Particle deviceOS APIs](https://docs.particle.io/reference/device-os/firmware/)

## Dev Environment Setup

1. Clone this repository
2. Open Particle Workbench
3. Run the `Particle: Import Project` command, follow the prompts, and wait for the project to load
4. Run the `Particle: Configure Workspace for Device` command and select a compatible Device OS version and the `bsom` platform when prompted ([docs](https://docs.particle.io/tutorials/developer-tools/workbench/#cloud-build-and-flash))
5. Connect your device
6. Compile & Flash!

## Quick overview of classes and files
- *cityscanner_config.h* main config file, needs to be updated before flashing
- *main.h* the program startpoint, should not be modified
- *cityscanner class* handles operation modes (more below)
- *CitySense class* manages data acquisition for environmental sensors (air quality, etc)
- *CityVitals class* acquires telemetry data (battery status, solar energy production, etc)
- *CityStore class* manages storing data on the SD card, dumping data over USB
- *MotionService class* used to send the device to sleep when the vehicle is not moving
- *LocationService class* provides GPS data to other classes (e.g. CityStore)

## Operation modes
- *IDLE* sensors off, provides only telemetry data
- *REALTIME* logs data onto the SD card
- *LOGGING* buffer data onto the SD card and send multiple records upon request (via USB)
- *PWRSAVE* like LOGGING but in low power mode

#### Payload

deviceID, timestamp, latitude, longitude, PM1.0, PM 2.5, PM4, PM10, numPM0.5, numPM1, numPM2.5, numPM4, numPM10, PM size, temperature, humidity, gas_op1_w, gas_op1_r, gas_op2_w, gas_op2_r, noise

### Vitals
deviceID, time, latitude, longitude, SOC_batt, temp_batt, voltage_batt, voltage_particle, current_batt, isCharging, isCharginS, temp_int, hum_int, voltage_solar, current_solar, cell_strenght

# Command line interface
A Python script provides a command line interface (CLI) for retrieving data over USB. To use it, follow the step-by-step instructions in the [data retrieval guide](https://mit-senseable-city-lab.github.io/flatburn-lte/deploy/data)

## Date, Time & Timezone Handling (Brasília / UTC-3)
- **Unix Epoch Timestamp:** GPS date is parsed using `CalendarYrToTm(year)` (years since 1970) producing standard Unix Epoch seconds in the CSV `timestamp` column.
- **GPS-to-RTC Sync:** When GPS achieves valid date and time fix (`year >= 2020`), the hardware RTC is synced via `Time.setTime(epoch)` to maintain accurate clock even during temporary satellite loss (e.g. tunnels/urban canyons).
- **Timezone Support:** Configured via `#define TIMEZONE_OFFSET -3` in `cityscanner_config.h` and applied with `Time.zone(-3)`. File names in `/queue/` (`MMDDHHMM.csv`) and formatted outputs reflect local Brasília time.
- **Double Precision Coordinates:** GPS latitude and longitude use 64-bit `double` for sub-meter positioning accuracy.

## Recent Stability & Firmware Fixes
- **Baud Rate:** Serial baud rate updated to `115200` baud in `main.cpp` to match Web Downloader (`flatburn_downloader.html`).
- **ADS1256 Timeout:** Added a 100ms timeout in `waitForLowDRDY()` / `waitForHighDRDY()` inside `ADS1256.cpp` driver to prevent infinite hardware lockups when gas sensor DRDY line stays HIGH.
- **Power Rail Sequencing:** 3.3V and 5V power rails are now enabled at the very start of `Cityscanner::init()` before probing I2C (battery charger) and SPI (SD card), resolving SD mount failures and boot stalls.
- **Library Example Isolation:** Library `.ino` files in `lib/` renamed to `.ino.bak` so `particle compile` only builds the core application (`main.cpp`).
- **Offline Logging:** Added `Cellular.off()` in `STARTUP()` to prevent cellular modem LED green blinking when running offline SD logging.


