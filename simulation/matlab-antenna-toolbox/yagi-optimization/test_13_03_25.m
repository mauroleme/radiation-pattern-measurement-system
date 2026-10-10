fc = 868e6;
wirediameter = 3e-3;
w = cylinder2strip(1.5e-3);
c = physconst("lightspeed");
lambda = c/fc;
Z0 = 50;
BW = 0.015*fc;
fmin = fc - 2*(BW);
fmax = fc + 2*(BW);
Nf = 101;
freq = linspace(fmin,fmax,Nf);

d = dipole;
d.Length = 0.96 * (lambda/2); % Ajustado para melhor ressonância
d.Width = cylinder2strip(wirediameter/2);
d.Tilt = 90;
d.TiltAxis = "Y";

Numdirs = 4;
refLength = 0.55; 
dirLength = [0.47 0.46 0.45 0.44]; % Fração de lambda (menores que o dipolo)
refSpacing = 0.07; 
dirSpacing = [0.024269 0.035833 0.094435 0.063857]; % Fração de lambda
initialdesign = [refLength refSpacing dirSpacing]; % Todos como frações de lambda

yagidesign = yagiUda;
yagidesign.Exciter = d;
yagidesign.NumDirectors = Numdirs;
yagidesign.ReflectorLength = refLength * lambda; % Converte para metros
yagidesign.DirectorLength = dirLength * lambda; % Converte para metros
yagidesign.ReflectorSpacing = refSpacing * lambda;
yagidesign.DirectorSpacing = dirSpacing * lambda;
yagidesign.Conductor = metal('Brass');
yagidesign.Exciter.Conductor = metal('Brass');
show(yagidesign);

% Análise adicional
s = sparameters(yagidesign, freq);
rfplot(s); % Plotar S11
impedance_data = impedance(yagidesign, freq); % Verificar impedância
pattern(yagidesign, fc); % Ver padrão de radiação