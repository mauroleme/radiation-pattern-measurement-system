function res = T02_hall_profile(b, opt)
%T02_HALL_PROFILE One full turn per joint, recording the Hall sensor.
%   Checks that each joint sees exactly ONE magnet window per revolution
%   and plots the analog profile with the digital state on top, so the
%   margin between the magnet and the logic threshold is visible.
%   Needs a full turn: the RF cable must be disconnected (see PROCEDURE).

res = newResult("T02", "Hall sensor profile (one turn per joint)");
res.fig = figure("Color", "w", "Name", res.id);
ok = true;
for j = opt.joints
    nRev  = b.stepsPerRev(j);
    every = max(1, round(b.StepsPerDeg(j)));            % ~1 sample per degree
    s     = b.scan(j, round(1.05*nRev), every);
    p0    = s.edges(1, 1);
    on    = s.edges(2:end, :); on = on(on(:,2) == 1, 1);
    off   = s.edges(2:end, :); off = off(off(:,2) == 0, 1);
    nWin  = numel(on);
    if nWin >= 1 && ~isempty(off)
        width = (off(find(off > on(1), 1)) - on(1)) / b.StepsPerDeg(j);
    else
        width = NaN;
    end
    idle = median(s.analog(:,2));
    peak = min(s.analog(:,2));
    good = nWin == 1;
    ok   = ok && good;

    res.lines(end+1) = sprintf("J%d: %d magnet window(s) per turn %s | width %.1f deg | analog idle %d, at magnet %d (ADC)", ...
        j, nWin, pick(good, "(OK)", "(expected 1)"), width, round(idle), round(peak));
    res.values.(sprintf("J%d", j)) = struct("windows", nWin, "widthDeg", width, ...
        "analogIdle", idle, "analogMagnet", peak, "scan", s);

    subplot(numel(opt.joints), 1, find(opt.joints == j));
    ang = (s.analog(:,1) - p0) / b.StepsPerDeg(j);
    yyaxis left;  plot(ang, s.analog(:,2), "LineWidth", 1.2); ylabel("Hall ADC");
    yyaxis right; stairs((s.edges(:,1) - p0)/b.StepsPerDeg(j), s.edges(:,2), "LineWidth", 1.2);
    ylim([-0.2 1.2]); ylabel("Digital (1 = magnet)");
    xlabel("Angle from start (deg, nominal)"); grid on;
    title(sprintf("Joint %d", j));
end
res.status = pick(ok, "PASS", "FAIL");
end
