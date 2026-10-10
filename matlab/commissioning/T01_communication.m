function res = T01_communication(b, opt)
%T01_COMMUNICATION Link, firmware identity, sensors readable, latency.
%   PASS when every PING is answered and the median round trip is below
%   opt.maxLatencyMs. No motion.

res = newResult("T01", "Communication and sensors");
n   = 20;
lat = nan(1, n);
for k = 1:n
    t = tic;
    if ~b.ping(), error("T01: bad PING reply."); end
    lat(k) = toc(t) * 1000;
end
info = b.info();
h    = b.hall();
ha   = b.hallAnalog();

res.values = struct("latencyMs", lat, "info", info, "hall", h, "hallAnalog", ha);
res.lines = [
    "Firmware: " + info
    sprintf("PING x%d: median %.1f ms, max %.1f ms", n, median(lat), max(lat))
    sprintf("Hall now: J1 %d (ADC %d), J2 %d (ADC %d)", h(1), ha(1), h(2), ha(2))
    ];
res.status = pick(median(lat) < opt.maxLatencyMs, "PASS", "FAIL");
end
