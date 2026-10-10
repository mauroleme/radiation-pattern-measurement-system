function out = pick(cond, a, b)
%PICK Inline if: returns a when cond is true, b otherwise.
if cond, out = a; else, out = b; end
end
