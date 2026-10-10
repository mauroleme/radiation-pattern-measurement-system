function seconds = estimateDuration(pts, cfg)
%ESTIMATEDURATION Rough scan time (s) from the firmware timing constants.
%   Each micro-step takes 2*DELTA_T = 10 ms (joint.h), joint 1 has 56
%   usteps/deg and joint 2 has 16 usteps/deg (main.ino), and the firmware
%   waits SAMPLE_TIME = 1 s at every position before replying.

prev    = [0 0; pts(1:end-1, :)];
moveAz  = abs(diff([prev(:,1), pts(:,1)], 1, 2)) * cfg.secPerDegAz;
moveEl  = abs(diff([prev(:,2), pts(:,2)], 1, 2)) * cfg.secPerDegEl;
seconds = sum(moveAz + moveEl) + size(pts, 1) * (cfg.settleTime + cfg.linkOverhead);
end
