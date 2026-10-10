function res = T05_homing_repeatability(b, opt)
%T05_HOMING_REPEATABILITY Homes opt.repeats times from random angles.
%   Same idea as Joint::HomeMotor(): turn in the default (+) direction from
%   wherever the joint is until a whole magnet window is crossed, and take
%   its centre. The step counter is never reset, so every centre must fall
%   on the same count (modulo whole turns); the spread is sensor
%   repeatability plus lost steps.
%   PASS when the spread is below opt.maxHomingSpreadDeg.

res = newResult("T05", "Homing repeatability");
res.fig = figure("Color", "w", "Name", res.id);
ok  = true;
for j = opt.joints
    spd = b.StepsPerDeg(j);
    spt = opt.stepsPerTurn(j);
    c   = nan(1, opt.repeats);
    for k = 1:opt.repeats
        b.step(j, round((20 + 150*rand) * spd * sign(randn)));   % start elsewhere
        c(k) = b.findMagnet(j, +1);
    end
    d      = c - c(1);
    d      = d - spt * round(d / spt);                 % fold whole turns out
    rel    = d / spd;
    spread = max(rel) - min(rel);
    good   = spread <= opt.maxHomingSpreadDeg;
    ok     = ok && good;
    res.lines(end+1) = sprintf("J%d: homing spread %.3f deg (std %.3f, n=%d) %s", ...
        j, spread, std(rel), numel(rel), pick(good, "(OK)", "(TOO BIG)"));
    res.values.(sprintf("J%d", j)) = struct("centreDeg", rel);
    plot(1:numel(rel), rel, "o-", "LineWidth", 1.2, "DisplayName", sprintf("Joint %d", j)); hold on;
end
xlabel("Homing run"); ylabel("Centre relative to run 1 (deg)"); grid on; legend;
title("Homing repeatability");
res.status = pick(ok, "PASS", "FAIL");
end
