function pts = scanPlan(kind, cfg, azFixed)
%SCANPLAN Ordered list of [az el] positions (degrees) for one scan.
%   pts = rpm.scanPlan("azimuth", cfg)          azimuth cut at el = 0
%   pts = rpm.scanPlan("elevation", cfg, az0)   second-axis cut at az = az0
%   pts = rpm.scanPlan("grid", cfg)             full az x el grid
%
%   Cable rule (as in the original set-up): the coaxial cable runs through
%   the mast, so the azimuth never crosses +/-180 deg. A single cut goes
%   0 -> +180, back to 0, then 0 -> -180 (the original order). In the grid,
%   each row is swept from -180 to +180 and the next one back (serpentine),
%   which keeps the same +/-180 limit but avoids two 180 deg returns per row.

azStep = cfg.azStep;
elStep = cfg.elStep;
elMin  = cfg.elRange(1);
elMax  = cfg.elRange(2);

switch kind
    case "azimuth"
        az  = [0:azStep:180, -azStep:-azStep:-180+azStep]';
        pts = [az, zeros(size(az))];

    case "elevation"
        el  = [0:elStep:elMax, -elStep:-elStep:elMin]';
        pts = [repmat(azFixed, size(el)), el];

    case "grid"
        azRow = (-180+azStep:azStep:180)';
        elAll = (elMin:elStep:elMax)';
        pts   = zeros(numel(azRow)*numel(elAll), 2);
        k = 0;
        for i = 1:numel(elAll)
            row = azRow;
            if mod(i, 2) == 0, row = flipud(row); end
            pts(k+(1:numel(row)), :) = [row, repmat(elAll(i), size(row))];
            k = k + numel(row);
        end

    otherwise
        error("rpm:plan", "Unknown scan kind ""%s"".", kind);
end
end
