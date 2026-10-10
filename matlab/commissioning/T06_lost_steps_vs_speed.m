function res = T06_lost_steps_vs_speed(b, opt)
%T06_LOST_STEPS_VS_SPEED Runs the measurement motion and checks for lost steps.
%   For each half-period in opt.dtList (us; firmware/main uses 5000), the
%   joint does the measurement cycle 0 -> +180 -> 0 -> -180 -> 0 and the
%   magnet centre is measured again (always approached from the same side,
%   so backlash cancels, and always at the nominal speed). Any shift is
%   steps lost while moving at that speed.
%   PASS when the firmware speed loses less than opt.maxDriftDeg; the
%   fastest speed that also passes is reported as a safe speed-up.

res = newResult("T06", "Lost steps in the measurement cycle vs speed");
res.fig = figure("Color", "w", "Name", res.id);
ok  = true;
for j = opt.joints
    spd = b.StepsPerDeg(j);
    spt = opt.stepsPerTurn(j);
    b.setDelay(opt.deltaT);
    c0  = b.approach(j, b.findMagnet(j, +1), +1, 15, spt);
    drift = nan(size(opt.dtList));
    for k = 1:numel(opt.dtList)
        b.setDelay(opt.dtList(k));
        for move = [180 -180 -180 180]
            b.step(j, round(move * spd));
        end
        b.setDelay(opt.deltaT);
        drift(k) = (b.approach(j, c0, +1, 15, spt) - c0) / spd;
    end
    atFw  = drift(opt.dtList == opt.deltaT);
    good  = isempty(atFw) || abs(atFw) <= opt.maxDriftDeg;
    ok    = ok && good;
    safe  = opt.dtList(abs(drift) <= opt.maxDriftDeg);
    for k = 1:numel(opt.dtList)
        res.lines(end+1) = sprintf("J%d: DT = %5d us (%.1f s per 90 deg) -> drift %+.2f deg %s", j, ...
            opt.dtList(k), 90*spd*2*opt.dtList(k)*1e-6, drift(k), ...
            pick(abs(drift(k)) <= opt.maxDriftDeg, "(OK)", "(LOST STEPS)"));
    end
    if ~isempty(safe)
        res.lines(end+1) = sprintf("J%d: fastest setting without lost steps: DELTA_T = %d us", j, min(safe));
    end
    res.values.(sprintf("J%d", j)) = struct("dtUs", opt.dtList, "driftDeg", drift);
    semilogx(opt.dtList, drift, "o-", "LineWidth", 1.2, "DisplayName", sprintf("Joint %d", j)); hold on;
end
yline([-1 1]*opt.maxDriftDeg, "r--", "HandleVisibility", "off");
xlabel("Half step period DELTA\_T (us)"); ylabel("Drift after one cycle (deg)");
grid on; legend; title("Lost steps vs speed");
res.status = pick(ok, "PASS", "FAIL");
end
