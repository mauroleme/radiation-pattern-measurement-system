classdef Simulator < handle
%SIMULATOR Software stand-in for the Arduino firmware (firmware/main).
%   Speaks the same serial protocol ("Ready?" -> "Set." -> "Go.", then
%   "<az>,<el>" -> 100 comma-separated samples in dBm) and returns the power
%   of an idealised directional antenna plus noise. Used by cfg.simulate.
%
%   The model is only meant to look like a Yagi-Uda (main lobe, a back lobe
%   ~17 dB down, a noise floor); it is not an electromagnetic simulation.

    properties
        Boresight   % [az el] in positioner degrees where the DUT points at TX
        PeakDbm     % received power on boresight (dBm)
        NoiseDb     % std of the per-sample noise (dB)
        Samples     % samples returned per position
        SecondAxis  % "elevation" or "roll", must match cfg.secondAxis
    end

    properties (Access = private)
        Queue string = "Ready?"
    end

    methods
        function obj = Simulator(cfg)
            obj.Boresight  = cfg.simBoresight;
            obj.PeakDbm    = -20;
            obj.NoiseDb    = 0.4;
            obj.Samples    = 100;
            obj.SecondAxis = cfg.secondAxis;
        end

        function write(obj, msg)
            msg = strtrim(string(msg));
            if msg == "Set."
                obj.Queue(end+1) = "Go.";
                return;
            end
            ang = sscanf(msg, "%d,%d");
            if numel(ang) ~= 2
                obj.Queue(end+1) = "Error: Invalid input format.";
                return;
            end
            p = obj.power(ang(1), ang(2)) + obj.NoiseDb*randn(1, obj.Samples);
            obj.Queue(end+1) = strjoin(compose("%.2f", p), ",");
        end

        function line = read(obj)
            if isempty(obj.Queue)
                error("rpm:simTimeout", "Simulator has nothing to send.");
            end
            line = obj.Queue(1);
            obj.Queue(1) = [];
        end

        function p = power(obj, az, el)
            % Angle between the measured direction and the antenna boresight
            u = rpm.direction(az, el, obj.SecondAxis);
            b = rpm.direction(obj.Boresight(1), obj.Boresight(2), "elevation");
            psi = acosd(max(-1, min(1, u*b')));
            % Main lobe (cos^n) + back lobe 17 dB down + floor at -45 dB
            front = ((1 + cosd(psi))/2).^14;          % HPBW ~ 50 deg
            back  = 10^(-17/10) * ((1 - cosd(psi))/2).^8;
            g     = front + back + 10^(-45/10);
            p     = obj.PeakDbm + 10*log10(g);
        end
    end
end
