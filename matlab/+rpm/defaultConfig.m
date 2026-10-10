function cfg = defaultConfig()
%DEFAULTCONFIG Default settings; override any field in the main script.

% --- What to measure -------------------------------------------------------
cfg.mode       = "2D";          % "2D" | "3D-slices" | "3D-grid"
cfg.azStep     = 5;             % azimuth step (deg, integer)
cfg.elStep     = 5;             % second-axis step (deg, integer)
cfg.elRange    = [-90 90];      % second-axis travel (deg); check the mechanics
cfg.secondAxis = "elevation";   % "elevation" (tilts the DUT) | "roll" (spins it
                                % about its boresight) - how axis B is mounted

% --- Connection --------------------------------------------------------------
cfg.simulate     = false;       % true = no hardware, use rpm.Simulator
cfg.simBoresight = [180 0];     % simulator: [az el] where the DUT faces TX
cfg.port         = "";          % "" = first available COM port
cfg.baudRate     = 115200;
cfg.timeout      = 120;         % s
cfg.maxRetries   = 5;
cfg.verbose      = true;

% --- Firmware timing, used only for the duration estimate --------------------
cfg.secPerDegAz  = 56 * 0.010;  % 56 usteps/deg x 10 ms/ustep (joint 1)
cfg.secPerDegEl  = 16 * 0.010;  % 16 usteps/deg x 10 ms/ustep (joint 2)
cfg.settleTime   = 1.0;         % SAMPLE_TIME in main.ino
cfg.linkOverhead = 0.15;        % serial transfer of 100 samples, approx.

% --- Plot and output -----------------------------------------------------------
cfg.plotOffsetDeg = 270;        % display rotation (report convention)
cfg.rLim          = [-75 0];    % polar plot radial limits (dBm)
cfg.dynamicRange  = 40;         % 3D plot: dB shown below the peak
cfg.outputDir     = fullfile(fileparts(fileparts(mfilename("fullpath"))), "results");
end
