function data = acquire(link, pts, cfg)
%ACQUIRE Moves the positioner through pts and records the RF power.
%   data = rpm.acquire(link, pts, cfg) sends "<az>,<el>" for every row of
%   pts, reads the samples (dBm) returned by the Arduino and returns:
%       data.points  N-by-2 [az el] (deg)
%       data.mean    N-by-1 mean power (dBm)
%       data.std     N-by-1 standard deviation of the samples (dB)
%       data.raw     N-by-S all samples

n         = size(pts, 1);
data.points = pts;
data.mean   = nan(n, 1);
data.std    = nan(n, 1);
data.raw    = [];

t0 = tic;
for k = 1:n
    cmd = sprintf("%d,%d", round(pts(k,1)), round(pts(k,2)));
    for attempt = 1:cfg.maxRetries
        response = "";
        try
            link.write(cmd);
            response = link.read();
            if startsWith(response, "Error: ")
                error("rpm:arduino", "Arduino error: %s", extractAfter(response, "Error: "));
            end
            samples = str2double(split(response, ","))';
            if isempty(samples) || any(isnan(samples))
                error("rpm:format", "Invalid numeric format.");
            end
            break;
        catch ME
            fprintf("Error at %s (attempt %d/%d): %s. Response was: %s\n", ...
                    cmd, attempt, cfg.maxRetries, ME.message, response);
            if attempt == cfg.maxRetries
                rethrow(ME);
            end
            pause(0.1);
        end
    end

    if isempty(data.raw)
        data.raw = nan(n, numel(samples));
    end
    data.raw(k, 1:numel(samples)) = samples;
    data.mean(k) = mean(samples);
    data.std(k)  = std(samples);

    if cfg.verbose
        elapsed = toc(t0);
        eta     = elapsed / k * (n - k);
        fprintf("[%4d/%4d] az %4d  el %4d  %7.2f dBm   ETA %s\n", k, n, ...
                round(pts(k,1)), round(pts(k,2)), data.mean(k), ...
                char(duration(0, 0, eta, "Format", "hh:mm:ss")));
    end
end
end
