function result = run(cfg)
%RUN Plans, measures, saves and plots one scan in cfg.mode.
%   result = rpm.run(cfg)  - see RadiationPatternMeasurement.m for the modes.

switch cfg.mode
    case "2D",        plan = rpm.scanPlan("azimuth", cfg);
    case "3D-slices", plan = [rpm.scanPlan("azimuth", cfg); rpm.scanPlan("elevation", cfg, 0)];
    case "3D-grid",   plan = rpm.scanPlan("grid", cfg);
    otherwise,        error("rpm:mode", "Unknown mode ""%s"".", cfg.mode);
end
if cfg.mode == "3D-slices" && cfg.secondAxis ~= "elevation"
    error("rpm:mode", "3D-slices needs secondAxis = ""elevation""; use 3D-grid for ""roll"".");
end
fprintf("Mode %s: %d positions, estimated duration %s (hh:mm:ss)\n", cfg.mode, ...
        size(plan, 1), char(duration(0, 0, rpm.estimateDuration(plan, cfg), "Format", "hh:mm:ss")));

% Connect and home
link    = rpm.openLink(cfg);
cleanup = onCleanup(@() link.close());
disp("Waiting for the Arduino to initialise...");
waitFor(link, "Ready?");
link.write("Set.");
disp("Homing the joints...");
waitFor(link, "Go.");

% Measure
result.mode      = cfg.mode;
result.timestamp = datetime("now");
result.cfg       = cfg;
switch cfg.mode
    case "2D"
        result.scans.azimuth = rpm.acquire(link, rpm.scanPlan("azimuth", cfg), cfg);

    case "3D-slices"
        result.scans.azimuth = rpm.acquire(link, rpm.scanPlan("azimuth", cfg), cfg);
        % Second cut through the main lobe found in the first one
        m = rpm.patternMetrics(result.scans.azimuth.points(:,1), result.scans.azimuth.mean);
        az0 = round(m.peakAz);
        fprintf("Main lobe at az = %d deg; measuring the second-axis cut there.\n", az0);
        result.scans.elevation = rpm.acquire(link, rpm.scanPlan("elevation", cfg, az0), cfg);

    case "3D-grid"
        result.scans.grid = rpm.acquire(link, rpm.scanPlan("grid", cfg), cfg);
end

% Park the DUT at the origin (the firmware answers with one set of samples)
link.write("0,0");
link.read();

rpm.saveResult(result, cfg);
rpm.plotResult(result, cfg);
end

function waitFor(link, expected)
while true
    try
        if strtrim(link.read()) == expected, return; end
    catch
        pause(0.5);
    end
end
end
