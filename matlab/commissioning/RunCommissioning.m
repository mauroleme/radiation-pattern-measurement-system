%% Commissioning of the two-axis positioner
% Runs the hardware tests T01..T09 against firmware/commissioning and writes
% a dated report (REPORT.md + figures + results.mat) to
% matlab/commissioning/reports/. Read PROCEDURE.md first.
%
% The tests are grouped by the physical set-up they need; the script stops
% and asks before each group:
%   A  RF cable DISCONNECTED from the DUT (full turns): T01-T06
%   B  antenna mounted, cable connected (no full turns): T07
%   C  signal generator -> AD8313 input:                  T08
%   D  normal measurement link (TX on, 2.5 m):            T09
%
% Set opt.simulate = true to dry-run everything on SimulatedRig (no
% hardware; the simulator has faults injected on purpose).

clear; clc; close all;
here = fileparts(mfilename("fullpath"));
addpath(here);

% ======================= Settings ==========================================
opt.simulate    = false;          % true = no hardware
opt.port        = "";             % "" = first available COM port
opt.timeout     = 900;            % s - a full turn of joint 1 takes ~3.5 min
opt.joints      = [1 2];          % joints to test
opt.groups      = ["A" "B" "C" "D"];   % which set-ups to run
opt.stepsPerDeg = [56 16];        % values hard-coded in firmware/main
opt.deltaT      = 5000;           % us, DELTA_T in firmware/main/joint.h

% Test parameters
opt.repeats            = 5;                         % T04, T05
opt.dtList             = [5000 3000 2000 1500 1000];% T06, us
opt.holdAngleDeg       = 45;                        % T07
opt.holdSeconds        = 30;                        % T07
opt.calPowers          = -65:5:0;                   % T08, generator setting (dBm)
opt.calCableLossDb     = 0;                         % T08, loss generator -> detector
opt.calFitRange        = [-60 -5];                  % T08, linear range used in the fit
opt.calSamples         = 100;                       % T08
opt.stabDurationS      = 120;                       % T09
opt.stabPeriodS        = 2;                         % T09

% Pass/fail limits
opt.maxLatencyMs       = 50;
opt.maxErrPerRevDeg    = 0.5;
opt.maxBacklashDeg     = 1.0;
opt.maxHomingSpreadDeg = 0.5;
opt.maxDriftDeg        = 0.2;
opt.maxCalResidualDb   = 1.0;
opt.maxRfDriftDb       = 1.0;
% ===========================================================================

opt.stepsPerTurn = round(360 * opt.stepsPerDeg);    % refined by T03
opt.rfA = 0.2722; opt.rfB = -97.115;                % refined by T08
if opt.simulate, opt.rng = 1; rng(1); end

stamp  = string(datetime("now", "Format", "yyyy-MM-dd_HHmmss"));
outDir = fullfile(here, "reports", stamp + pick(opt.simulate, "_SIMULATED", ""));
mkdir(outDir);

b = Bench(opt);
results = {};

groups = {
    "A", "Disconnect the RF cable from the antenna (joints will make FULL turns).", ...
         {@T01_communication, @T02_hall_profile, @T03_steps_per_degree, ...
          @T04_backlash, @T05_homing_repeatability, @T06_lost_steps_vs_speed}
    "B", "Mount the antenna and connect the cable as for a measurement (no full turns).", ...
         {@T07_holding_when_idle}
    "C", "Connect the signal generator (868 MHz CW) to the AD8313 input.", ...
         {@T08_ad8313_calibration}
    "D", "Restore the measurement link: TX on, antennas 2.5 m apart, platform still.", ...
         {@T09_rf_stability}
    };

for g = 1:size(groups, 1)
    if ~ismember(groups{g, 1}, opt.groups), continue; end
    fprintf("\n=== Group %s ===\n%s\n", groups{g, 1}, groups{g, 2});
    if ~opt.simulate, input("Press Enter when ready... ", "s"); end
    for t = groups{g, 3}
        fn = t{1};
        fprintf("\nRunning %s ...\n", func2str(fn));
        tic;
        try
            r = fn(b, opt);
        catch ME
            r = newResult(extractBefore(func2str(fn) + "_", "_"), func2str(fn));
            r.status = "ERROR";
            r.lines  = "Aborted: " + ME.message;
        end
        r.seconds = toc;
        fprintf("  [%s] %s\n", r.status, r.name);
        fprintf("    %s\n", r.lines);
        % Feed calibrations into the following tests
        if r.id == "T03" && r.status ~= "ERROR"
            for j = opt.joints
                opt.stepsPerTurn(j) = round(r.values.(sprintf("J%d", j)).uStepsPerTurn);
            end
        end
        if r.id == "T08" && r.status ~= "ERROR"
            opt.rfA = r.values.A; opt.rfB = r.values.B;
        end
        results{end+1} = r; %#ok<SAGROW>
    end
end

writeReport(results, opt, outDir);
fprintf("\nReport: %s\n", fullfile(outDir, "REPORT.md"));
