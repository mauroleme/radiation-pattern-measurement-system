% Design of a choke balun
% Coaxial cable RG174 (2.6 mm diameter)
% Inductance formula for a single-layer coil:
%             4 * pi^2 * N^2 * r^2
%     Ls = -------------------------- * K
%                   l
%
% where:
%   l = N * d_cable        -> coil length
%   K = f(l/D), with D = 2r
%
% Reference: https://coil32.net/single-layer-coil.html

Lt = 550;              % Target inductance: 550 nH
d_cable = 0.26;        % Cable diameter in cm (2.6 mm)
N = 1:10;              % Number of turns tested (1 to 10)
l = N * d_cable;       % Coil length (cm)
D = 1.8;               % Internal coil diameter (cm)

% Inductance calculation (nH)
L = 2 * pi * D .* N.^2 .* ( ...
        log(1 + (pi * D) ./ (2 * l)) + ...
        1 ./ (2.3004 + 3.437 * (l ./ D) + ...
        1.7636 * (l ./ D).^2 - ...
        (0.47 ./ (0.755 + D ./ l).^1.44)) );

% Plot results
plot(N, L, N, ones(size(N)) * Lt, 'r--')
xlabel('Number of turns (N)')
ylabel('Inductance (nH)')
title('Choke Balun Inductance vs. Number of Turns')
legend('Calculated inductance', 'Target inductance')
grid on
