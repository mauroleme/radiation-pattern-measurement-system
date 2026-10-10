function res = T07_holding_when_idle(b, opt)
%T07_HOLDING_WHEN_IDLE Does a joint keep its position with the driver off?
%   firmware/main switches the drivers off after 10 s without motion
%   (MOTOR_SLEEP_TIMEOUT), which removes the holding torque. Axis 2 carries
%   the antenna, so gravity or a tight cable may turn it. The joint is moved
%   opt.holdAngleDeg away from the magnet, the driver is switched off for
%   opt.holdSeconds, then it comes back and the magnet centre is measured.
%   Run it WITH the antenna mounted: it starts from the magnet found by an
%   earlier test (or searches at most half a turn) and makes no full turns.
%   PASS when the shift is below opt.maxDriftDeg.

res = newResult("T07", "Position held with the driver off (sleep timeout)");
ok  = true;
for j = opt.joints
    spd = b.StepsPerDeg(j);
    spt = opt.stepsPerTurn(j);
    if isnan(b.LastCentre(j))                      % not homed by an earlier test
        b.findMagnet(j, +1, round(0.5*spt));
    end
    c0  = b.approach(j, b.LastCentre(j), +1, 15, spt);
    b.step(j, round(opt.holdAngleDeg * spd));
    b.enable(j, false);
    if ~b.Simulated, pause(opt.holdSeconds); end
    b.enable(j, true);
    b.step(j, -round(opt.holdAngleDeg * spd));
    shift = (b.approach(j, c0, +1, 15, spt) - c0) / spd;
    good  = abs(shift) <= opt.maxDriftDeg;
    ok    = ok && good;
    res.lines(end+1) = sprintf("J%d: %.0f s off at %+.0f deg -> shift %+.2f deg %s", j, ...
        opt.holdSeconds, opt.holdAngleDeg, shift, pick(good, "(OK)", "(POSITION LOST)"));
    res.values.(sprintf("J%d", j)) = struct("shiftDeg", shift);
end
if ~ok
    res.lines(end+1) = "Fix: keep the drivers enabled during a scan (raise MOTOR_SLEEP_TIMEOUT in joint.h) or re-home axis 2 before each row.";
end
res.status = pick(ok, "PASS", "FAIL");
end
