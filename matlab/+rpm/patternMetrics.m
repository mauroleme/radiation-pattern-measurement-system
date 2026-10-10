function m = patternMetrics(az, p)
%PATTERNMETRICS Main-lobe direction, HPBW, front-to-back ratio and SLL.
%   m = rpm.patternMetrics(az, p) for one closed cut: az (deg) and p (dBm)
%   covering 360 deg with a uniform step. Duplicate end points (-180 and
%   180) are allowed. Crossings of the -3 dB level are linearly interpolated.
%
%   Fields: peakAz, peakDbm, hpbw, hpbwLeft, hpbwRight (deg),
%           fbr (dB), sll (dB, relative to the peak).

[az, p] = rpm.sortCut(az, p);       % unique, ascending, -180 <= az < 180
n    = numel(az);
step = 360 / n;
pn   = p - max(p);
[~, ip] = max(p);

m.peakAz  = az(ip);
m.peakDbm = p(ip);

% Walk around the circle from the peak until the pattern drops below -3 dB
idx = @(k) mod(k-1, n) + 1;
[m.hpbwRight, kR] = crossing(+1);
[m.hpbwLeft,  kL] = crossing(-1);
m.hpbw = m.hpbwRight - m.hpbwLeft;

% Front-to-back: peak vs the point 180 deg away
[~, ib] = min(abs(angdiff(az, m.peakAz + 180)));
m.fbr   = p(ip) - p(ib);

% Side-lobe level: highest local maximum outside the main lobe, where the
% main lobe ends at the first local minimum on each side of the peak
kR = walkToMin(kR, +1);
kL = walkToMin(kL, -1);
inMain = false(n, 1);
k = kL;
while true
    inMain(idx(k)) = true;
    if idx(k) == idx(kR), break; end
    k = k + 1;
end
isMax = pn >= pn([n 1:n-1]) & pn >= pn([2:n 1]);
cand  = pn(isMax & ~inMain);
if isempty(cand), m.sll = -Inf; else, m.sll = max(cand); end

    function [angle, k] = crossing(dir)
        % k: first index below -3 dB (returned for the side-lobe search)
        for s = 1:n
            k1 = ip + dir*s;
            if pn(idx(k1)) < -3
                f     = (-3 - pn(idx(k1-dir))) / (pn(idx(k1)) - pn(idx(k1-dir)));
                angle = m.peakAz + dir*(s - 1 + f)*step;
                k     = k1;
                return;
            end
        end
        angle = m.peakAz + dir*180; k = ip + dir*n/2;
    end

    function k = walkToMin(k, dir)
        while pn(idx(k+dir)) < pn(idx(k)), k = k + dir; end
    end
end

function d = angdiff(a, b)
d = mod(a - b + 180, 360) - 180;
end
