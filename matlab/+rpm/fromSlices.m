function [azVec, elVec, P] = fromSlices(azCut, pAz, elCut, pEl)
%FROMSLICES 3D pattern estimated from one azimuth and one elevation cut.
%   [azVec, elVec, P] = rpm.fromSlices(azCut, pAz, elCut, pEl)
%   Summing method (in dB): G(az,el) = Gaz(az) + Gel(el), both cuts
%   normalised to their own peak, then shifted back to the measured peak.
%   It is exact for separable patterns and a good approximation for
%   directive antennas such as the Yagi-Uda; side and back lobes away
%   from the two measured planes are only estimated.
%
%   azCut/pAz : cut at el = 0 (deg, dBm), 360 deg
%   elCut/pEl : cut at the azimuth of the main lobe (deg, dBm), e.g. -90..90

[azVec, pAz] = rpm.sortCut(azCut, pAz);
[elVec, i]   = sort(elCut(:));
pEl          = pEl(i);

Gaz = pAz - max(pAz);
Gel = pEl - max(pEl);
P   = max(pAz) + Gel + Gaz';          % numel(el)-by-numel(az)
end
