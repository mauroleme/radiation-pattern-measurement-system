function res = T04_backlash(b, opt)
%T04_BACKLASH Crosses the magnet forward and backward, locally.
%   The window CENTRE seen turning forward and turning backward differs by
%   the mechanical play (belt, pulleys, gear) PLUS the Hall sensor
%   hysteresis, which also shifts the centre in the direction of motion.
%   The result is therefore an upper bound on the backlash, and it is the
%   number that matters for the measurement: it is the angular error between
%   a forward and a backward sweep. Repeated opt.repeats times.
%   PASS when it is below opt.maxBacklashDeg.

res = newResult("T04", "Backlash + Hall hysteresis (forward vs backward)");
ok  = true;
for j = opt.joints
    spd = b.StepsPerDeg(j);
    spt = opt.stepsPerTurn(j);
    c0  = b.findMagnet(j, +1);
    bl  = nan(1, opt.repeats);
    for k = 1:opt.repeats
        cF = b.approach(j, c0, +1, 20, spt);
        cB = b.approach(j, c0, -1, 20, spt);
        bl(k) = abs(cF - cB) / spd;
    end
    good = mean(bl) <= opt.maxBacklashDeg;
    ok   = ok && good;
    res.lines(end+1) = sprintf("J%d: backlash + hysteresis %.2f deg (min %.2f, max %.2f, n=%d) %s", ...
        j, mean(bl), min(bl), max(bl), numel(bl), pick(good, "(OK)", "(TOO BIG)"));
    res.values.(sprintf("J%d", j)) = struct("backlashDeg", bl);
end
res.status = pick(ok, "PASS", "FAIL");
end
