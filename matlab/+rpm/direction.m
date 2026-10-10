function u = direction(az, el, secondAxis)
%DIRECTION Unit vector (antenna frame) seen by the DUT at positioner angles.
%   u = rpm.direction(az, el, secondAxis) returns an N-by-3 matrix of unit
%   vectors [x y z] for the azimuth angles az and second-axis angles el
%   (degrees, same size or scalar-expandable).
%
%   secondAxis = "elevation": the 2nd axis tilts the DUT up/down.
%       u = [cos(el)cos(az), cos(el)sin(az), sin(el)]
%   secondAxis = "roll": the 2nd axis spins the DUT about its boresight, so
%       each azimuth sweep is a great-circle cut rotated by el.
%       u = [cos(az), sin(az)cos(el), sin(az)sin(el)]

az = az(:); el = el(:);
if isscalar(az), az = repmat(az, size(el)); end
if isscalar(el), el = repmat(el, size(az)); end

switch lower(secondAxis)
    case "elevation"
        u = [cosd(el).*cosd(az), cosd(el).*sind(az), sind(el)];
    case "roll"
        u = [cosd(az), sind(az).*cosd(el), sind(az).*sind(el)];
    otherwise
        error("rpm:axis", "secondAxis must be ""elevation"" or ""roll"".");
end
end
