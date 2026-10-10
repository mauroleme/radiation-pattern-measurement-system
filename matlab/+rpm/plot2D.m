function [ax, m] = plot2D(az, p, cfg, titleText)
%PLOT2D Polar plot of one cut with the -3 dB beamwidth and a metrics box.
%   [ax, m] = rpm.plot2D(az, p, cfg, titleText)
%   cfg.plotOffsetDeg rotates the display only (the report used +270 deg so
%   that the main lobe, measured at az = +/-180, is drawn at 90 deg).
%   cfg.rLim sets the radial limits in dBm.

if nargin < 4, titleText = "Antenna Radiation Pattern"; end

[az, p] = rpm.sortCut(az, p);
m       = rpm.patternMetrics(az, p);
show    = @(a) deg2rad(mod(a + cfg.plotOffsetDeg, 360));

figure("Color", "w", "Name", titleText);
polarplot(show([az; az(1)]), [p; p(1)], "r", "LineWidth", 1.5);
ax = gca;
hold(ax, "on");
set(ax, "ThetaZeroLocation", "top", "ThetaDir", "counterclockwise");
rlim(ax, cfg.rLim);
ax.RTick = cfg.rLim(1):15:cfg.rLim(2);

for edge = [m.hpbwLeft, m.hpbwRight]
    polarplot(ax, show([edge edge]), cfg.rLim, "b--", "LineWidth", 1.2);
end
title(ax, titleText);

summary = {
    sprintf("Main lobe: %.0f%s (%.1f dBm)", mod(m.peakAz + cfg.plotOffsetDeg, 360), char(176), m.peakDbm)
    sprintf("HPBW (-3 dB): %.1f%s", m.hpbw, char(176))
    sprintf("Front-to-back: %.1f dB", m.fbr)
    sprintf("Side-lobe level: %.1f dB", m.sll)
    };
annotation("textbox", [0.01 0.01 0.4 0.12], "String", summary, ...
           "FitBoxToText", "on", "BackgroundColor", "w", "EdgeColor", "k");
end
