close all;
clear;
clc;

fc = 868e6;
wirediameter = 1.5e-3;
c = physconst("lightspeed");
lambda = c/fc;
Z0 = 50;
BW = 0.05*fc;
fmin = fc - 2*(BW);
fmax = fc + 2*(BW);
Nf = 101;
freq = linspace(fmin,fmax,Nf);

d = dipole;
d.Length = (lambda*0.456);
d.Width = cylinder2strip(wirediameter/2);

% Rotacionar o dipolo 90 graus em torno do eixo Y
d.Tilt = 90;
d.TiltAxis = 'Y';

Numdirs = 4;
refLength = 0.565;
dirLength = 0.45*ones(1,Numdirs);
refSpacing = 0.2;

% Defina espaçamentos individuais para cada diretor
dirSpacing = [0.08, 0.14, 0.16, 0.18] * lambda;

exLength = d.Length/lambda;
initialdesign = [refLength dirLength refSpacing dirSpacing exLength].*lambda;

yagidesign = yagiUda;
yagidesign.Exciter = d;
yagidesign.NumDirectors = Numdirs;
yagidesign.ReflectorLength = refLength*lambda;
yagidesign.DirectorLength = dirLength.*lambda;
yagidesign.ReflectorSpacing = refSpacing*lambda;
yagidesign.DirectorSpacing = dirSpacing; % Aplique o vetor de espaçamentos
yagidesign.Conductor = metal('Brass');
yagidesign.Exciter.Conductor = metal('Brass');

% Mostrar a antena
show(yagidesign);

% Definir faixa de frequência
freqRange = (781.2:8.68:954.8)*1e6;
plotFrequency = 868*1e6;

% Impedância
figure;
impedance(yagidesign, freqRange);

% Parâmetro S com bandwidth
bandwidth(yagidesign,750e6:1e6:950e6);

% Padrão de radiação
figure;
pattern(yagidesign, plotFrequency);

% Padrão de azimute
figure;
patternAzimuth(yagidesign, plotFrequency, 0, 'Azimuth', 0:5:360);

% Padrão de elevação
figure;
patternElevation(yagidesign, plotFrequency, 0, 'Elevation', 0:5:360);

% Calcular parâmetros S
s = sparameters(yagidesign, freqRange);

% Extrair S11
s11 = rfparam(s, 1, 1);

% Converter para dB
s11_dB = 20*log10(abs(s11));

% Encontrar a largura de banda onde S11 < -10 dB
bwMask = s11_dB < -10;
bandwidthFreqs = freqRange(bwMask);

% Calcular a largura de banda
if ~isempty(bandwidthFreqs)
    absBW = bandwidthFreqs(end) - bandwidthFreqs(1);
else
    absBW = 0;
end

disp(['Largura de banda: ', num2str(absBW/1e6), ' MHz']);