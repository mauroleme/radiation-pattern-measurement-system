%% Radiation Pattern Measurement - main script
% Drives the two-axis positioner (firmware/main) and plots the pattern.
%
%   mode = "2D"        azimuth cut only (as in the report), ~8 min at 5 deg
%   mode = "3D-slices" azimuth cut + one cut on the 2nd axis at the main
%                      lobe; the 3D pattern is reconstructed from the two
%                      cuts (fast, approximate)
%   mode = "3D-grid"   full az x el grid, measured point by point (slow:
%                      ~1 h at 10 deg, several hours at 5 deg)
%
% Set cfg.simulate = true to run everything without hardware.
% Every scan is saved to matlab/results/ (.mat + .csv).
% To re-plot a saved scan or a lab spreadsheet, see PlotSavedMeasurement.m

clear; clc; close all;
addpath(fileparts(mfilename("fullpath")));      % makes the +rpm package visible

cfg = rpm.defaultConfig();

% ======================= Settings ==========================================
cfg.mode       = "2D";            % "2D" | "3D-slices" | "3D-grid"
cfg.azStep     = 5;               % deg
cfg.elStep     = 5;               % deg (3D modes): axis 2 steps 5 deg, then a new azimuth sweep
cfg.elRange    = [-90 90];        % deg (3D modes) - check the cable/mechanics!
cfg.secondAxis = "elevation";     % "elevation" | "roll"
cfg.simulate   = false;           % true = test without the Arduino
% ===========================================================================

result = rpm.run(cfg);
