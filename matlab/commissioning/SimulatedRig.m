classdef SimulatedRig < handle
%SIMULATEDRIG Software model of the positioner running firmware/commissioning.
%   It answers the same serial commands, so every test can be dry-run
%   without hardware. Some imperfections are injected ON PURPOSE (defaults
%   below) to show that the tests detect them. Results obtained with the
%   simulator say nothing about the real platform.
%
%   Model per joint j:
%     output angle = motor angle (usteps / TrueStepsPerDeg) minus backlash
%     Hall ON when |output - MagnetDeg| < MagnetWidth/2 (with hysteresis)
%     steps are lost with probability LossProb when DT < MinDt
%     the joint slips SlipOnDisableDeg when its driver is switched off
%   AD8313: V = Slope*P + Intercept (clipped), ADC = V/5*1023 + noise

    properties
        TrueStepsPerDeg   = [56.10 16.00]   % j1 gear ~0.18 % off on purpose
        MagnetDeg         = [0 0]
        MagnetWidth       = [6 8]           % deg
        HallHysteresis    = [0.3 0.3]       % deg
        BacklashDeg       = [0.5 0.3]       % deg (dead band on reversal)
        MinDt             = [1800 1200]     % us; faster than this loses steps
        LossProb          = 0.02
        SlipOnDisableDeg  = [0 1.2]         % deg, j2 carries the antenna
        Slope             = 0.0185          % V/dBm (report eq. 4.3)
        Intercept         = 1.8621          % V
        AdcNoise          = 1.5             % LSB rms
        GeneratorDbm      = -30             % power at the detector input
    end

    properties (SetAccess = private)
        MotorSteps = [0 0]    % true motor position (usteps)
        Counter    = [0 0]    % what the firmware believes (usteps)
        OutputDeg  = [0 0]    % true output angle (deg)
        Play       = [0 0]    % position inside the backlash band (deg)
        HallState  = [false false]
        Enabled    = [false false]
        DeltaT     = 5000
        Queue string = "READY,commissioning-sim"
    end

    methods
        function obj = SimulatedRig(opt)
            if isfield(opt, "rng"), rng(opt.rng); end
            % start somewhere that is not the magnet
            obj.OutputDeg = [137 -64];
            for j = 1:2, obj.HallState(j) = obj.hallAt(j, obj.OutputDeg(j)); end
        end

        function writeLine(obj, cmd)
            cmd = strtrim(string(cmd));
            v = str2double(split(extractAfter(cmd, ","), ","));
            switch extractBefore(cmd + ",", ",")
                case "PING",  obj.out("PONG");
                case "INFO",  obj.out(sprintf("INFO,commissioning-sim,%d", obj.DeltaT));
                case "HALL",  obj.out(sprintf("HALL,%d,%d", obj.HallState));
                case "HALLA", obj.out(sprintf("HALLA,%d,%d", obj.analogHall(1), obj.analogHall(2)));
                case "POS",   obj.out(sprintf("POS,%d,%d", obj.Counter));
                case "EN"
                    j = v(1);
                    if obj.Enabled(j) && ~v(2)
                        obj.moveOutput(j, -obj.SlipOnDisableDeg(j));   % gravity
                    end
                    obj.Enabled(j) = logical(v(2)); obj.out("OK");
                case "ZERO",  obj.Counter(v(1)) = 0; obj.out("OK");
                case "DT",    obj.DeltaT = v(1); obj.out("OK");
                case "STEP"
                    obj.Enabled(v(1)) = true;
                    obj.run(v(1), v(2), 0, false);
                    obj.out(sprintf("OK,%d", obj.Counter(v(1))));
                case "SCAN"
                    obj.Enabled(v(1)) = true;
                    obj.out(sprintf("E,%d,%d", obj.Counter(v(1)), obj.HallState(v(1))));
                    obj.run(v(1), v(2), v(3), true);
                    obj.out(sprintf("DONE,%d", obj.Counter(v(1))));
                case "RAW"
                    obj.out(strjoin(string(round(obj.adc(v(1)))), ","));
                otherwise
                    obj.out("ERR,unknown command: " + cmd);
            end
        end

        function line = readLine(obj)
            if isempty(obj.Queue), error("SimulatedRig:empty", "Nothing to read."); end
            line = obj.Queue(1); obj.Queue(1) = [];
        end
    end

    methods (Access = private)
        function out(obj, s), obj.Queue(end+1) = string(s); end

        function run(obj, j, n, every, report)
            dir = sign(n); if dir == 0, return; end
            lossy = obj.DeltaT < obj.MinDt(j);
            for i = 1:abs(n)
                obj.Counter(j) = obj.Counter(j) + dir;
                if lossy && rand < obj.LossProb, continue; end     % step lost
                obj.MotorSteps(j) = obj.MotorSteps(j) + dir;
                obj.moveMotorDeg(j, dir / obj.TrueStepsPerDeg(j));
                h = obj.hallAt(j, obj.OutputDeg(j));
                if report && h ~= obj.HallState(j)
                    obj.out(sprintf("E,%d,%d", obj.Counter(j), h));
                end
                obj.HallState(j) = h;
                if report && every > 0 && mod(i, every) == 0
                    obj.out(sprintf("A,%d,%d", obj.Counter(j), obj.analogHall(j)));
                end
            end
        end

        function moveMotorDeg(obj, j, d)
            % Backlash: the output only moves once the play is taken up
            b = obj.BacklashDeg(j) / 2;
            p = obj.Play(j) + d;
            if p > b,      obj.moveOutput(j, p - b);  p = b;
            elseif p < -b, obj.moveOutput(j, p + b);  p = -b;
            end
            obj.Play(j) = p;
        end

        function moveOutput(obj, j, d), obj.OutputDeg(j) = obj.OutputDeg(j) + d; end

        function h = hallAt(obj, j, ang)
            d = abs(mod(ang - obj.MagnetDeg(j) + 180, 360) - 180);
            if obj.HallState(j)
                h = d < obj.MagnetWidth(j)/2 + obj.HallHysteresis(j);
            else
                h = d < obj.MagnetWidth(j)/2;
            end
        end

        function a = analogHall(obj, j)
            d = mod(obj.OutputDeg(j) - obj.MagnetDeg(j) + 180, 360) - 180;
            a = round(520 - 430*exp(-(d/(0.6*obj.MagnetWidth(j)))^2) + 2*randn);
        end

        function a = adc(obj, n)
            v = obj.Slope*obj.GeneratorDbm + obj.Intercept;
            v = min(max(v, 0.55), 1.80);                     % detector limits
            a = v/5*1023 + obj.AdcNoise*randn(1, n);
        end
    end
end
