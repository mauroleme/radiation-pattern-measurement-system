classdef Bench < handle
%BENCH Connection to firmware/commissioning (or to a SimulatedRig).
%   b = Bench(opt) opens opt.port (or the first free COM port), or a
%   SimulatedRig when opt.simulate is true. Every method maps to one
%   command of the commissioning sketch (see commissioning.ino).

    properties
        Simulated logical = false
        Rig                          % SimulatedRig when simulated
        StepsPerDeg double           % nominal usteps/deg per joint [j1 j2]
        LastCentre = [NaN NaN]       % last magnet centre found (usteps, counter)
    end

    properties (Access = private)
        Port
    end

    methods
        function obj = Bench(opt)
            obj.StepsPerDeg = opt.stepsPerDeg;
            if opt.simulate
                obj.Simulated = true;
                obj.Rig = SimulatedRig(opt);
                obj.Rig.readLine();                      % READY banner
                return;
            end
            port = opt.port;
            if port == ""
                ports = serialportlist("available");
                if isempty(ports), error("Bench:noPort", "No available COM port."); end
                port = ports(1);
            end
            obj.Port = serialport(port, 115200, "Timeout", opt.timeout);
            configureTerminator(obj.Port, "CR/LF");
            banner = readline(obj.Port);                 % the Uno resets on open
            if ~startsWith(banner, "READY")
                error("Bench:banner", "Unexpected banner ""%s"". Is firmware/commissioning flashed?", banner);
            end
        end

        function delete(obj)
            if ~isempty(obj.Port), delete(obj.Port); end
        end

        % ---- raw I/O ---------------------------------------------------------------
        function send(obj, cmd)
            if obj.Simulated, obj.Rig.writeLine(cmd); else, writeline(obj.Port, cmd); end
        end

        function line = receive(obj)
            if obj.Simulated, line = obj.Rig.readLine(); else, line = readline(obj.Port); end
            line = strtrim(string(line));
            if startsWith(line, "ERR")
                error("Bench:firmware", "Firmware error: %s", line);
            end
        end

        function line = query(obj, cmd)
            obj.send(cmd);
            line = obj.receive();
        end

        % ---- commands ------------------------------------------------------------------
        function ok = ping(obj),          ok = obj.query("PING") == "PONG"; end
        function s = info(obj),           s = obj.query("INFO"); end
        function enable(obj, j, on),      obj.expectOK(obj.query(sprintf("EN,%d,%d", j, on))); end
        function zero(obj, j),            obj.expectOK(obj.query(sprintf("ZERO,%d", j))); end
        function setDelay(obj, us),       obj.expectOK(obj.query(sprintf("DT,%d", round(us)))); end

        function h = hall(obj)
            v = sscanf(obj.query("HALL"), "HALL,%d,%d"); h = logical(v(:)');
        end

        function a = hallAnalog(obj)
            a = sscanf(obj.query("HALLA"), "HALLA,%d,%d")';
        end

        function p = pos(obj)
            p = sscanf(obj.query("POS"), "POS,%d,%d")';
        end

        function p = step(obj, j, n)
            r = obj.query(sprintf("STEP,%d,%d", j, round(n)));
            p = sscanf(r, "OK,%d");
        end

        function s = scan(obj, j, n, every)
            %SCAN Moves n usteps and returns the Hall edges and analog samples.
            %   s.edges  = [pos state] at the start and at every change
            %   s.analog = [pos adc] every 'every' steps (if every > 0)
            if nargin < 4, every = 0; end
            obj.send(sprintf("SCAN,%d,%d,%d", j, round(n), every));
            s.edges = zeros(0, 2); s.analog = zeros(0, 2);
            while true
                line = obj.receive();
                parts = split(line, ",");
                switch parts(1)
                    case "E", s.edges(end+1, :)  = str2double(parts(2:3))';
                    case "A", s.analog(end+1, :) = str2double(parts(2:3))';
                    case "DONE", s.final = str2double(parts(2)); return;
                    otherwise, error("Bench:scan", "Unexpected line ""%s"".", line);
                end
            end
        end

        function v = raw(obj, n)
            v = str2double(split(obj.query(sprintf("RAW,%d", n)), ","))';
        end

        % ---- helpers built on the commands -----------------------------------------
        function n = stepsPerRev(obj, j)
            n = round(360 * obj.StepsPerDeg(j));
        end

        function [center, win] = findMagnet(obj, j, dir, maxSteps)
            %FINDMAGNET Scans in direction dir until a full magnet window has
            %   been crossed; returns its centre and [entry exit] positions.
            if nargin < 4, maxSteps = round(1.15 * obj.stepsPerRev(j)); end
            s = obj.scan(j, dir * maxSteps, 0);
            % First complete window: an ON edge followed by an OFF edge
            e = s.edges(2:end, :);                       % row 1 is the initial state
            k = find(e(:,2) == 1, 1);
            if isempty(k) || k == size(e, 1)
                error("Bench:magnet", "Joint %d: no complete magnet window found.", j);
            end
            win    = [e(k,1), e(k+1,1)];
            center = mean(win);
            obj.LastCentre(j) = center;
        end

        function center = approach(obj, j, c0, dir, marginDeg, stepsPerTurn)
            %APPROACH Crosses the magnet near c0 in direction dir, locally.
            %   Moves to c0 - dir*margin (choosing the copy of that target
            %   nearest to the current position, one turn = stepsPerTurn),
            %   scans 2*margin in direction dir and returns the window centre
            %   in the same turn as c0. Used to measure without full turns.
            spd    = obj.StepsPerDeg(j);
            p      = obj.pos(); p = p(j);
            target = c0 - dir*marginDeg*spd;
            turns  = round((p - target) / stepsPerTurn);
            target = target + turns*stepsPerTurn;
            obj.step(j, target - p);
            [center, ~] = obj.findMagnet(j, dir, round(2*marginDeg*spd));
            center = center - turns*stepsPerTurn;           % back to c0's turn
            obj.LastCentre(j) = center;
        end

        function expectOK(~, r)
            if ~startsWith(r, "OK"), error("Bench:reply", "Expected OK, got ""%s"".", r); end
        end
    end
end
