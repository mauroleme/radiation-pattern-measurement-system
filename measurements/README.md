# Measurements

Every test campaign of the project in chronological order, kept **exactly as it was produced** (folder and file names are in Portuguese, as on the lab PC). Nothing was cleaned up, so you can see how the system evolved, failed attempts included.

The radiation pattern was always measured on the same set-up: both antennas outdoors, 2.5 m apart, 1 m above ground, 868 MHz, the receiving antenna rotated in azimuth in 5° steps from −180° to 180°, 100 samples averaged per angle, and **10 or more repetitions** per configuration.

## Reading the spreadsheets

`average-10_measurements*.xlsx` has one row per angle θ (−180…180, step 5°) and one column per repetition (values in dBm), plus the average column. `media*.xlsx` holds only the averaged 1×73 vector. Load that vector into MATLAB as `media` and run [`matlab/analysis/plot_das_medidas.m`](../matlab/analysis/plot_das_medidas.m) to plot it with the beamwidth and side-lobe level.

Touchstone files (`.s1p`, `.s2p`) are NanoVNA exports; open them with NanoVNA-Saver, QucsStudio, scikit-rf or MATLAB's `sparameters`.

---

## 2025-04-23: component characterisation
[`2025-04-23_component-characterisation`](2025-04-23_component-characterisation)

The first full lab session, which characterised every block of the RF chain before any pattern was measured.

| Sub-folder | What was measured |
|---|---|
| `Antena Transmissora/`, `Antena Recetora/` | S11/VSWR/Smith chart of the TX and RX Yagi, 500 MHz-1.2 GHz (`500M_1200M.s1p`, `touchstone.s1p`). `Fig2_v2`/`Fig4_v2` are later re-plots |
| `Antena Transmissora/Casamento_Impedancia_…_prj/` | First QucsStudio simulation of the matching network and of the coax effect |
| `filtro/` | S21 of the 868 MHz SAW band-pass filter, with the instrument settings |
| `Medidor de potÊncia RF/` | **AD8313 calibration**: input power vs output voltage and the fitted linear model |
| `Espectro/` | Spectrum-analyser checks of the signal generator (Rigol) and the TX noise floor |
| `Teste Gerador e SA/` | Photos of the generator/spectrum-analyser bench test |
| `Amplificadores/` | Amplifier test |
| `Ensaio_provisório*.xlsx` | First provisional pattern sweeps, without and with the filter |

## 2025-05-14: S11 iterations and far-field export
[`2025-05-14_s11-and-farfield`](2025-05-14_s11-and-farfield)

Several S11 measurements of the antennas (`s11best`, `S11bom`, `S11recetora`, `smith`…), insertion loss plots, and the CST far-field exports (`Farfield.txt`, `3dRadiationPattern.txt`) used for comparison. `media.csv` is an averaged sweep.

## First measurement: antenna only, then with the filter
[`first-measurement_antenna-only-and-with-filter`](first-measurement_antenna-only-and-with-filter)

Ten sweeps **without the filter** (`sem filtro/`) and ten **with the 868 MHz filter** (`com filtro/`), each one plotted, plus the averages. These became **Figs. 4.6 and 4.7** of the report. The exact date was not recorded, but it was **early May 2025**: the spreadsheet template was created on 2025-05-02, and `com filtro/media_2025-05-03.xlsx` (found in the MATLAB working folder, last edited 2025-05-03) already holds the with-filter average, within 0.19 dB of the final one. The other files were last edited on 2025-08-17.

## 2025-07-26: filter + balun, and the matching-PCB characterisation
[`2025-07-26_filter-balun_pcb-characterisation`](2025-07-26_filter-balun_pcb-characterisation)

- `com balun e com filtro @868 MHz/`: 15 sweeps with the filter and the RG-174 balun, the overall average, the average without outliers, and the average of runs 8-15. This is **Fig. 4.8**.
- `carcaterização do PCB/`: four revisions of the impedance-matching PCB (v1 → v4 with an extra 3.3 nH series inductor), with S11/S21 and Smith charts for TX and RX.

## 2025-08-22: complete system (filter + balun + matching) and 3D
[`2025-08-22_full-system_2d-and-3d`](2025-08-22_full-system_2d-and-3d)

Ten sweeps of the complete chain (`s1…s10.jpg`), their average (`media.jpg`, `medianew.jpg`), the CST comparisons (`sim*.pdf`, `simulation*.png`) and the **3D pattern** (`3d.jpg`, `3d new.jpg`, `3D_new.png`). These are **Figs. 4.9 and 4.10** of the report.

## Oscilloscope
[`oscilloscope`](oscilloscope): Tektronix oscilloscope screen captures (`TEK000x.png`) taken during the project.
