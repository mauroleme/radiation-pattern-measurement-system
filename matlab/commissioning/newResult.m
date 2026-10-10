function res = newResult(id, name)
%NEWRESULT Empty result record shared by all tests.
res = struct("id", id, "name", name, "status", "INFO", ...
             "lines", strings(0, 1), "values", struct(), "fig", []);
end
