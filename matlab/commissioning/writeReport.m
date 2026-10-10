function writeReport(results, opt, outDir)
%WRITEREPORT Saves REPORT.md, one PNG per test figure and results.mat.

fid = fopen(fullfile(outDir, "REPORT.md"), "w", "n", "UTF-8");
cleanup = onCleanup(@() fclose(fid));

fprintf(fid, "# Commissioning report\n\n");
fprintf(fid, "- Date: %s\n", string(datetime("now", "Format", "yyyy-MM-dd HH:mm")));
if opt.simulate
    fprintf(fid, "- **SIMULATED RUN** (SimulatedRig, faults injected on purpose). Not a hardware result.\n");
end
fprintf(fid, "- Joints tested: %s | firmware usteps/deg: %s | DELTA_T: %d us\n\n", ...
        mat2str(opt.joints), mat2str(opt.stepsPerDeg), opt.deltaT);

fprintf(fid, "| Test | Result | Time |\n|---|---|---|\n");
for k = 1:numel(results)
    r = results{k};
    fprintf(fid, "| %s %s | **%s** | %.0f s |\n", r.id, r.name, r.status, r.seconds);
end
fprintf(fid, "\n");

for k = 1:numel(results)
    r = results{k};
    fprintf(fid, "## %s %s: %s\n\n", r.id, r.name, r.status);
    fprintf(fid, "- %s\n", r.lines);
    if ~isempty(r.fig) && isvalid(r.fig)
        png = r.id + ".png";
        exportgraphics(r.fig, fullfile(outDir, png), "Resolution", 110);
        fprintf(fid, "\n![%s](%s)\n", r.id, png);
    end
    fprintf(fid, "\n");
end

fprintf(fid, "## Values to carry into firmware/main\n\n");
fprintf(fid, "- `SetStepsPerDegree`: use T03 *best integer* per joint (main.ino setup()).\n");
fprintf(fid, "- `DELTA_T` (joint.h): the fastest T06 setting without lost steps, with some margin.\n");
fprintf(fid, "- RF conversion in `capture_sensor_data()`: the T08 line `power_dBm = raw * A + B`.\n");
fprintf(fid, "- If T07 failed: raise `MOTOR_SLEEP_TIMEOUT` so the drivers stay on during a scan.\n");

for k = 1:numel(results), results{k}.fig = []; end   % figures already saved as PNG
save(fullfile(outDir, "results.mat"), "results", "opt");
end
