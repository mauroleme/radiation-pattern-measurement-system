function [azVec, elVec, P] = toGrid(points, values)
%TOGRID Rearranges scattered [az el] samples into an el-by-az matrix.
%   Azimuths are wrapped to -180 <= az < 180; missing cells stay NaN.

az = mod(points(:,1) + 180, 360) - 180;
el = points(:,2);
azVec = unique(az)';
elVec = unique(el);
P = nan(numel(elVec), numel(azVec));
[~, ia] = ismember(az, azVec);
[~, ie] = ismember(el, elVec);
P(sub2ind(size(P), ie, ia)) = values;
end
