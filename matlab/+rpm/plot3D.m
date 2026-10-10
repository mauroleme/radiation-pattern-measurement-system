function ax = plot3D(azVec, elVec, P, cfg, titleText)
%PLOT3D Spherical surface of a pattern sampled on an az x el grid.
%   ax = rpm.plot3D(azVec, elVec, P, cfg, titleText)
%   P is numel(elVec)-by-numel(azVec) in dBm. The radius is the power above
%   (peak - cfg.dynamicRange), normalised to 1, and the colour is the power.
%   cfg.secondAxis ("elevation" or "roll") defines how el maps to space and
%   cfg.plotOffsetDeg rotates the azimuth the same way as in rpm.plot2D.

if nargin < 5, titleText = "3D Radiation Pattern"; end

% Close the surface in azimuth
azVec = azVec(:)';
elVec = elVec(:);
if mod(azVec(end) - azVec(1), 360) ~= 0
    azVec = [azVec, azVec(1) + 360];
    P     = [P, P(:, 1)];
end
[AZ, EL] = meshgrid(azVec + cfg.plotOffsetDeg, elVec);

r = max(P - max(P(:)) + cfg.dynamicRange, 0) / cfg.dynamicRange;
u = rpm.direction(AZ(:), EL(:), cfg.secondAxis);
X = reshape(r(:) .* u(:,1), size(P));
Y = reshape(r(:) .* u(:,2), size(P));
Z = reshape(r(:) .* u(:,3), size(P));

figure("Color", "w", "Name", titleText);
surf(X, Y, Z, P, "EdgeColor", "none", "FaceColor", "interp");
ax = gca;
hold(ax, "on");
axis(ax, "equal", "off");
colormap(ax, jet);
cb = colorbar(ax);
cb.Label.String = "Received power (dBm)";
clim(ax, [max(P(:)) - cfg.dynamicRange, max(P(:))]);

% Reference circles (xy, xz, yz) and axes, as in the report figure
t = linspace(0, 2*pi, 181);
plot3(ax, cos(t), sin(t), 0*t, "b", "LineWidth", 1.5);
plot3(ax, cos(t), 0*t, sin(t), "r", "LineWidth", 1.5);
plot3(ax, 0*t, cos(t), sin(t), "g", "LineWidth", 1.5);
L = 1.15;
plot3(ax, [0 L], [0 0], [0 0], "r");  text(ax, L, 0, 0, "x");
plot3(ax, [0 0], [0 L], [0 0], "g");  text(ax, 0, L, 0, "y");
plot3(ax, [0 0], [0 0], [0 L], "b");  text(ax, 0, 0, L, "z");

view(ax, 35, 20);
camlight(ax, "headlight");
lighting(ax, "gouraud");
title(ax, titleText);
end
