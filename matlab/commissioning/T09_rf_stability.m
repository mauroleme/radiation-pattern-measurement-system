function res = T09_rf_stability(b, opt)
%T09_RF_STABILITY Static RF reading over time: noise and drift.
%   Leave the transmitter on and the platform still (the real link, as in a
%   measurement). Every opt.stabPeriodS seconds, 100 raw samples are read
%   and converted to dBm (with the T08 constants if available). Reports
%   the per-point noise and the drift over the run: this is the floor on
%   how well two measured patterns can agree.
%   PASS when the drift (max - min of the means) is below opt.maxRfDriftDb.

res = newResult("T09", "RF reading stability");
A = opt.rfA; B = opt.rfB;
n = max(2, round(opt.stabDurationS / opt.stabPeriodS));
if b.Simulated, b.Rig.GeneratorDbm = -21; end   % typical level on the 2.5 m link
t = nan(n, 1); m = nan(n, 1); s = nan(n, 1);
t0 = tic;
for k = 1:n
    v = A * b.raw(100) + B;
    t(k) = toc(t0); m(k) = mean(v); s(k) = std(v);
    if ~b.Simulated, pause(opt.stabPeriodS); end
end
drift = max(m) - min(m);
res.values = struct("t", t, "meanDbm", m, "stdDb", s, "driftDb", drift);
res.lines = [
    sprintf("%d readings over %.0f s: mean %.2f dBm", n, t(end), mean(m))
    sprintf("Noise within one reading: %.2f dB rms | drift of the means: %.2f dB", mean(s), drift)
    sprintf("Averaging 100 samples gives an uncertainty of about %.3f dB per point", mean(s)/10)
    ];
res.status = pick(drift <= opt.maxRfDriftDb, "PASS", "FAIL");
res.fig = figure("Color", "w", "Name", res.id);
errorbar(t, m, s, "o-"); grid on;
xlabel("Time (s)"); ylabel("Received power (dBm)"); title("RF stability (static)");
end
