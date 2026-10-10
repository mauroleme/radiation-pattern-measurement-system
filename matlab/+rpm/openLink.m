function link = openLink(cfg)
%OPENLINK Opens the connection to the positioner (real Arduino or simulator).
%   link = rpm.openLink(cfg) returns a struct with function handles:
%       link.write(msg)  - send one line
%       link.read()      - read one line (string)
%       link.close()     - release the port
%   cfg.simulate = true  uses rpm.Simulator instead of a serial port, so the
%   whole chain (scan, save, plot) can be tested without hardware.

if cfg.simulate
    sim       = rpm.Simulator(cfg);
    link.write = @(msg) sim.write(msg);
    link.read  = @() sim.read();
    link.close = @() [];
    link.name  = "simulator";
    return;
end

port = cfg.port;
if port == ""
    availablePorts = serialportlist("available");
    if isempty(availablePorts)
        error("rpm:noPort", "No available COM ports detected.");
    end
    disp("Available COM ports:"); disp(availablePorts);
    port = availablePorts(1);                   % First available port
end

s         = serialport(port, cfg.baudRate);
s.Timeout = cfg.timeout;
configureTerminator(s, "CR/LF");

link.write = @(msg) writeline(s, msg);
link.read  = @() readline(s);
link.close = @() delete(s);
link.name  = port;
end
