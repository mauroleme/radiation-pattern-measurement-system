%% Plot a saved measurement (no hardware needed)
% Works with the files written by RadiationPatternMeasurement.m
% (matlab/results/*.mat or *.csv) and with the lab spreadsheets kept in
% measurements/ (average-10_measurements*.xlsx, media*.xlsx).

clear; clc; close all;
here = fileparts(mfilename("fullpath"));
addpath(here);

cfg = rpm.defaultConfig();

% Example: complete system (filter + balun + matching), 22/08/2025 - report Fig. 4.9
file = fullfile(here, "..", "measurements", "2025-08-22_full-system_2d-and-3d", ...
                "average-10_measurements.xlsx");

result = rpm.loadMeasurement(file);
rpm.plotResult(result, cfg);

m = rpm.patternMetrics(result.scans.azimuth.points(:,1), result.scans.azimuth.mean);
fprintf("Peak %.1f dBm | HPBW %.1f deg | F/B %.1f dB | SLL %.1f dB\n", ...
        m.peakDbm, m.hpbw, m.fbr, m.sll);
