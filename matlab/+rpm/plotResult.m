function plotResult(result, cfg)
%PLOTRESULT Draws a measurement in whatever mode it was taken.
%   2D        -> polar plot of the azimuth cut
%   3D-slices -> polar plots of both cuts + reconstructed 3D surface
%   3D-grid   -> polar plot of the el = 0 row + measured 3D surface

s = result.scans;
switch result.mode
    case "2D"
        rpm.plot2D(s.azimuth.points(:,1), s.azimuth.mean, cfg, "Azimuth cut");

    case "3D-slices"
        rpm.plot2D(s.azimuth.points(:,1),   s.azimuth.mean,   cfg, "Azimuth cut");
        el = s.elevation.points(:,2);
        cfgEl = cfg; cfgEl.plotOffsetDeg = 90;          % el = 0 drawn at 90 deg
        polarCut(el, s.elevation.mean, cfgEl, "Elevation cut");
        [azVec, elVec, P] = rpm.fromSlices(s.azimuth.points(:,1), s.azimuth.mean, ...
                                           el, s.elevation.mean);
        rpm.plot3D(azVec, elVec, P, cfg, "3D pattern (reconstructed from two cuts)");

    case "3D-grid"
        [azVec, elVec, P] = rpm.toGrid(s.grid.points, s.grid.mean);
        row = find(elVec == 0, 1);
        if ~isempty(row)
            rpm.plot2D(azVec, P(row, :), cfg, "Azimuth cut (el = 0)");
        end
        rpm.plot3D(azVec, elVec, P, cfg, "3D pattern (measured grid)");

    otherwise
        error("rpm:mode", "Unknown mode ""%s"".", result.mode);
end
end

function polarCut(angle, p, cfg, titleText)
% Elevation cuts usually do not span 360 deg, so no metrics/closing here
[angle, i] = sort(angle(:));
figure("Color", "w", "Name", titleText);
polarplot(deg2rad(angle + cfg.plotOffsetDeg), p(i), "r", "LineWidth", 1.5);
ax = gca;
set(ax, "ThetaZeroLocation", "top", "ThetaDir", "counterclockwise");
rlim(ax, cfg.rLim);
title(ax, titleText);
end
