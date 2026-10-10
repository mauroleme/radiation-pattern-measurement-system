# Hardware

| Folder | Contents |
|---|---|
| [`electronics`](electronics) | Wiring schematic, block diagram, connection diagram and the **AD8313 calibration** (V vs dBm curve + spreadsheet) |
| [`impedance-matching`](impedance-matching) | Matching network for the Yagi feed: QucsStudio project (`.sch`, `.dpl`, `.dat`, `.s2p`), board calculation, PCB layout, before/after S11, NanoVNA screenshots |
| [`balun`](balun) | RG-174 air-choke balun: the written study (`study/`), VNA characterisation (differential and common mode) and photos. The design script is [`matlab/balun/code_balun.m`](../matlab/balun/code_balun.m) |
| [`bandpass-filter-868MHz`](bandpass-filter-868MHz) | S21 of the commercial 868 MHz SAW filter, with the instrument settings |
| [`cad`](cad) | Mechanical design: SolidWorks parts and assemblies, STL files for 3D printing, previews |

## Balun in numbers
Target inductance 550 nH, RG-174 (Ø 2.6 mm) wound on an 18 mm former. Measured at 868 MHz: differential-mode insertion loss −0.58 dB and common-mode attenuation > 47 dB.

## Matching PCB in numbers
Antenna alone: S11 ≈ −10 to −11 dB at 868 MHz (best match at ≈ 876 MHz). With the PCB: **S11 = −20.3 dB, VSWR 1.21, Z = 43.1 − j5.76 Ω**, so reflected power fell from 7.9 % to 0.92 %. The board was designed in QucsStudio and EasyEDA and CNC-milled by MORE CoLAB.
