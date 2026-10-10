function res = T03_steps_per_degree(b, opt)
%T03_STEPS_PER_DEGREE Calibrates usteps/deg by counting steps between
%   two consecutive passes over the same magnet edge (one exact turn).
%   Compares with the value hard-coded in firmware/main (56 and 16) and
%   reports the angular error that value accumulates per turn.
%   PASS when that error is below opt.maxErrPerRevDeg.

res = newResult("T03", "Steps per degree (calibration)");
ok  = true;
for j = opt.joints
    nominal = b.StepsPerDeg(j);
    s   = b.scan(j, round(2.2 * b.stepsPerRev(j)), 0);
    e   = s.edges(2:end, :);
    on  = e(e(:,2) == 1, 1);
    off = e(e(:,2) == 0, 1);
    revs = [diff(on); diff(off)];                     % usteps per turn
    if isempty(revs)
        error("T03: joint %d crossed the magnet fewer than twice.", j);
    end
    perRev   = mean(revs);
    measured = perRev / 360;
    errDeg   = (perRev - 360*nominal) / nominal;      % deg lost/gained per turn
    best     = round(measured);
    errBest  = (perRev - 360*best) / best;
    good     = abs(errDeg) <= opt.maxErrPerRevDeg;
    ok       = ok && good;

    res.lines(end+1) = sprintf(("J%d: %.0f usteps/turn (spread %.0f) -> %.3f usteps/deg | firmware uses %d " + ...
        "-> error %+.2f deg/turn %s | best integer %d (error %+.2f deg/turn)"), ...
        j, perRev, max(revs) - min(revs), measured, nominal, errDeg, pick(good, "(OK)", "(TOO BIG)"), best, errBest);
    if abs(errBest) > opt.maxErrPerRevDeg
        res.lines(end+1) = sprintf(("J%d: no integer usteps/deg is accurate enough. firmware/main stores " + ...
            "steps_per_degree as uint16_t; convert in Joint::RotateMotor with usteps per TURN " + ...
            "(%.0f) instead: steps = target_deg * %.0f / 360."), j, perRev, perRev);
    end
    res.values.(sprintf("J%d", j)) = struct("uStepsPerTurn", perRev, "uStepsPerDeg", measured, ...
        "firmwareValue", nominal, "errDegPerTurn", errDeg, "bestInteger", best, "samples", revs);
end
res.lines(end+1) = "Note: an integer value per degree can only be exact if usteps/turn is a multiple of 360.";
res.status = pick(ok, "PASS", "FAIL");
end
