function [az, p] = sortCut(az, p)
%SORTCUT Wraps a cut to -180 <= az < 180, sorts it and drops duplicates.
%   The measurement order (0..180, then -5..-175) and the lab spreadsheets
%   (-180..180, both ends included) end up on the same ascending grid.

az = mod(az(:) + 180, 360) - 180;
p  = p(:);
[az, i] = sort(az);
p = p(i);
[az, iu] = unique(az, "stable");
p = p(iu);
end
