function files = saveResult(result, cfg)
%SAVERESULT Writes a measurement to <cfg.outputDir>/<timestamp>_<mode>.mat/.csv
%   The .mat file keeps everything (config, raw samples); the .csv has one
%   row per position: az_deg, el_deg, mean_dBm, std_dB.

if ~exist(cfg.outputDir, "dir"), mkdir(cfg.outputDir); end
stem  = fullfile(cfg.outputDir, string(result.timestamp, "yyyyMMdd_HHmmss") + "_" + result.mode);
files = [stem + ".mat", stem + ".csv"];

save(files(1), "result");

T = table();
for f = string(fieldnames(result.scans))'
    s = result.scans.(f);
    T = [T; table(repmat(f, size(s.mean)), s.points(:,1), s.points(:,2), s.mean, s.std, ...
         'VariableNames', ["scan", "az_deg", "el_deg", "mean_dBm", "std_dB"])]; %#ok<AGROW>
end
writetable(T, files(2));
fprintf("Saved: %s\n       %s\n", files(1), files(2));
end
