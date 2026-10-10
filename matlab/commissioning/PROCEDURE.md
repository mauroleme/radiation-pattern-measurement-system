# Commissioning procedure

Hardware check of the two-axis positioner, to run **before** using `firmware/main` and `matlab/RadiationPatternMeasurement.m`, especially before the first 3D measurement. It answers, with numbers:

- Does each axis turn by the angle it is told to? (calibration of µsteps per degree)
- How much play is there between turning forward and turning backward?
- Does homing always land on the same spot?
- Are steps lost during a measurement, and how much faster could the motors go?
- Does axis 2 keep its position when the firmware switches the driver off?
- What is the correct ADC → dBm conversion for the AD8313?
- How stable is the RF reading?

Total time: about **1 h 45 min**, mostly unattended motion.

> **Not yet run on the real platform.** Everything has been dry-run against a software model of the rig (`SimulatedRig`), and both sketches compile for the Arduino Uno. The first real run is the validation.

## What you need

- The platform, 12 V supply, USB cable, a PC with MATLAB (R2019b or newer, no toolbox needed)
- Arduino IDE
- For T08: an RF signal generator at 868 MHz (CW), down to −65 dBm, and the cable/adapters used in the measurements
- For T09: the normal measurement set-up (TX antenna and generator, 2.5 m apart)

## 1. Flash the test firmware

Open `firmware/commissioning/commissioning.ino` in the Arduino IDE, select **Arduino Uno**, and upload it. This sketch replaces the measurement firmware **only while testing**, and the measurement code is not modified.

To check it quickly, open the Serial Monitor (115200 baud, *Both NL & CR*). It shows `READY,commissioning-1.0`. Type `PING` and it answers `PONG`. Type `HALL` and it answers `HALL,0,0` (it shows 1 when a magnet is in front of a sensor). **Close the Serial Monitor before running MATLAB.**

## 2. Run the tests

Open `matlab/commissioning/RunCommissioning.m`. Check the *Settings* block (COM port: leave `""` for the first free one), then run it. The script stops before each group and asks you to change the set-up:

| Group | Set-up | Tests | Time |
|---|---|---|---|
| **A** | ⚠️ **Disconnect the RF cable from the antenna** (or remove the antenna): both axes make **full turns**, and the cable through the mast would twist | T01-T06 | ~80 min |
| **B** | Antenna mounted and cable connected, as for a measurement (no full turns) | T07 | ~3 min |
| **C** | Signal generator → AD8313 input (through the measurement cable) | T08 | ~10 min, you set the generator when asked |
| **D** | Normal link: TX on, antennas 2.5 m apart, platform still | T09 | ~2 min |

To run only some groups, set `opt.groups` (e.g. `["C"]` for the RF calibration alone).

| Test | What it does | Passes when |
|---|---|---|
| T01 | PING ×20, reads firmware and Hall sensors | median latency < 50 ms |
| T02 | One turn per axis, logging the Hall sensor (analog + digital) | exactly 1 magnet window per turn |
| T03 | 2.2 turns, counting µsteps between two passes over the same magnet edge = **µsteps per turn** | firmware value (56 / 16 µsteps/°) errs < 0.5° per turn |
| T04 | Crosses the magnet forward and backward, 5× | backlash + sensor hysteresis < 1° |
| T05 | Homes 5× from random angles (same method as the firmware) | spread < 0.5° |
| T06 | Measurement cycle 0 → +180 → 0 → −180 → 0 at DELTA_T = 5000, 3000, 2000, 1500 and 1000 µs, re-measuring the magnet after each | no drift > 0.2° at 5000 µs, plus the fastest safe speed |
| T07 | Moves 45°, switches the driver off for 30 s (as `MOTOR_SLEEP_TIMEOUT` does), comes back | shift < 0.2° |
| T08 | Generator from −65 to 0 dBm in 5 dB steps → raw ADC → least-squares line | residual < 1 dB, slope 15-23 mV/dB |
| T09 | 2 minutes of static readings | drift < 1 dB |

All limits are in the *Settings* block.

## 3. The report

Each run creates `matlab/commissioning/reports/<date>_<time>/` with:

- `REPORT.md`, a summary table and the detail of each test
- `T0x.png`, the plots
- `results.mat`, all the raw data

Please **commit the report folder** (or send it): it becomes the record of the platform's state.

## 4. Carry the results into the measurement firmware

Put back `firmware/main`, then:

| If… | Change in `firmware/main` |
|---|---|
| T03 gives a different best integer | `joint1.SetStepsPerDegree(...)` / `joint2.SetStepsPerDegree(...)` in `main.ino` |
| T03 says *"no integer usteps/deg is accurate enough"* | Convert with µsteps per **turn** in `Joint::RotateMotor` (the report gives the number) |
| T06 finds a faster safe speed | `DELTA_T` in `joint.h` (leave ~50 % margin: if 1500 µs passed, use ~2500 µs) |
| T07 fails | Raise `MOTOR_SLEEP_TIMEOUT` in `joint.h` so the drivers stay on during a scan |
| T08 always | `power_dBm = raw * A + B` in `capture_sensor_data()` with the A and B printed by T08 |
| 3D modes | `#define HOME_JOINT2 1` in `main.ino` |

Then update `cfg.secPerDegAz` / `cfg.secPerDegEl` in `matlab/+rpm/defaultConfig.m` if `DELTA_T` or the µsteps/° changed, so the duration estimates stay right.

## Trying it without hardware

Set `opt.simulate = true` in `RunCommissioning.m`. The simulated rig has **faults injected on purpose** (a gear ratio 0.18 % off, 0.5° of backlash, lost steps below 1800 µs, axis 2 slipping 1.2° with the driver off) to show that the tests catch them: T03 and T07 fail on purpose. The report folder gets the suffix `_SIMULATED`.

## Test firmware protocol (for reference)

`PING`, `INFO`, `HALL`, `HALLA` (analog), `POS`, `EN,j,0|1`, `ZERO,j`, `DT,us`, `STEP,j,n`, `SCAN,j,n,every` (streams `E,pos,state` on every Hall change and `A,pos,adc` every *every* steps, then `DONE,pos`), `RAW,n` (n raw ADC samples of the AD8313). Details are in the header of `commissioning.ino`.
