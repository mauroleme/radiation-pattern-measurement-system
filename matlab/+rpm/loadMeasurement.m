function result = loadMeasurement(file, block)
%LOADMEASUREMENT Reads a saved scan or one of the lab spreadsheets.
%   result = rpm.loadMeasurement(file) accepts:
%     .mat  written by rpm.saveResult
%     .csv  written by rpm.saveResult
%     .xlsx the lab files in measurements/:
%           average-10_measurements*.xlsx (theta column + AVERAGE column;
%           some sheets hold several tables stacked vertically, e.g. without
%           and with the filter - pick one with BLOCK, default 1)
%           media*.xlsx (one row of 73 values, -180:5:180)
%   The result always has result.mode and result.scans.<name>.points/mean.

if nargin < 2, block = 1; end
[~, ~, ext] = fileparts(file);
switch lower(ext)
    case ".mat"
        s = load(file, "result");
        result = s.result;

    case ".csv"
        T = readtable(file, "TextType", "string");
        result.mode = "unknown";
        for name = unique(T.scan)'
            r = T(T.scan == name, :);
            result.scans.(name).points = [r.az_deg, r.el_deg];
            result.scans.(name).mean   = r.mean_dBm;
            result.scans.(name).std    = r.std_dB;
        end
        if isfield(result.scans, "grid")
            result.mode = "3D-grid";
        elseif isfield(result.scans, "elevation")
            result.mode = "3D-slices";
        else
            result.mode = "2D";
        end

    case {".xlsx", ".xls"}
        C = readcell(file);
        [theta, avg, label] = labSheet(C, block);
        result.label = label;
        result.mode = "2D";
        result.scans.azimuth.points = [theta, zeros(size(theta))];
        result.scans.azimuth.mean   = avg;
        result.scans.azimuth.std    = nan(size(avg));

    otherwise
        error("rpm:load", "Unsupported file type %s.", ext);
end
result.source = string(file);
end

function [theta, avg, label] = labSheet(C, block)
isText = cellfun(@(c) ischar(c) || isstring(c), C);
txt    = strings(size(C));
txt(isText) = string(C(isText));

[rT, cT] = find(txt == "theta degree");
[rA, cA] = find(txt == "AVERAGE");
label = "";
if ~isempty(rT) && ~isempty(rA)
    % Table headers: rows where "theta degree" and "AVERAGE" sit together
    starts = intersect(rT, rA);
    if block > numel(starts)
        error("rpm:load", "Sheet has %d table(s); block %d requested.", numel(starts), block);
    end
    r0 = starts(block);
    cT = cT(find(rT == r0, 1));
    cA = cA(find(rA == r0, 1));
    titles = find(contains(txt(r0-1, :), "MEASUREMENT"), 1);
    if ~isempty(titles), label = txt(r0-1, titles); end
    theta = []; avg = [];
    for r = r0+1:size(C, 1)
        t = C{r, cT}; a = C{r, cA};
        if ~(isnumeric(t) && isnumeric(a) && isscalar(t) && isscalar(a))
            break;                                   % end of this table
        end
        theta(end+1, 1) = t; avg(end+1, 1) = a; %#ok<AGROW>
    end
    return;
end

% Single-row "media" file
v = cell2mat(C(cellfun(@(c) isnumeric(c) && ~isempty(c) && ~any(ismissing(c)), C)));
v = v(:);
if numel(v) ~= 73
    error("rpm:load", "Unrecognised spreadsheet layout (%d numeric cells).", numel(v));
end
theta = (-180:5:180)';
avg   = v;
end
