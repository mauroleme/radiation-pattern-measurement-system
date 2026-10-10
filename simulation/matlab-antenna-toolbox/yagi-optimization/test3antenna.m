close all; clear; clc;

% Definir frequência de operação
fc = 868e6; % 868 MHz
lambda = physconst('lightspeed') / fc;

% Criar dipolo dobrado como elemento ativo
wirediameter = 1.5e-3; % 1.5 mm
d = dipoleFolded('Length', lambda/2, 'Width', cylinder2strip(wirediameter/2), 'Spacing', lambda/300);
d.Conductor = metal('Brass');

% Criar antena Yagi-Uda com 4 diretores
Numdirs = 4;
refLength = 0.5;
dirLength = 0.5 * ones(1, Numdirs);
refSpacing = 0.3;
dirSpacing = 0.25 * ones(1, Numdirs);

yagidesign = yagiUda('Exciter', d, 'NumDirectors', Numdirs, ...
    'ReflectorLength', refLength*lambda, 'DirectorLength', dirLength*lambda, ...
    'ReflectorSpacing', refSpacing*lambda, 'DirectorSpacing', dirSpacing*lambda);
yagidesign.Conductor = metal('Brass');
yagidesign.Exciter.Conductor = metal('Brass');

% Plotar padrão de radiação inicial
figure;
pattern(yagidesign, fc);

% Definir limites e restrições
LB = [0.4, 0.3*ones(1, Numdirs), 0.1, 0.1*ones(1, Numdirs)] * lambda;
UB = [0.6, 0.7*ones(1, Numdirs), 0.35, 0.3*ones(1, Numdirs)] * lambda;
constraints = struct('S11min', -10, 'Gmin', 10.5, 'Gdeviation', 0.1, 'FBmin', 15, 'Penalty', 50);

% Opções de otimização
optimizerparams = optimoptions(@patternsearch, 'UseCompletePoll', true, ...
    'PlotFcns', @psplotbestf, 'MaxIter', 100, 'FunctionTolerance', 1e-2);

% Função de otimização
optimdesign = patternsearch(@(controlVals) yagi_objective_function_direct(yagidesign, controlVals, fc, constraints), ...
    [refLength, dirLength, refSpacing, dirSpacing], [], [], [], [], LB, UB, [], optimizerparams);

% Atualizar e plotar design otimizado
yagidesign.ReflectorLength = optimdesign(1);
yagidesign.DirectorLength = optimdesign(2:5);
yagidesign.ReflectorSpacing = optimdesign(6);
yagidesign.DirectorSpacing = optimdesign(7:10);

figure;
pattern(yagidesign, fc);

% Função objetivo
function objectivevalue = yagi_objective_function_direct(y, controlVals, fc, constraints)
    y.ReflectorLength = controlVals(1);
    y.DirectorLength = controlVals(2:5);
    y.ReflectorSpacing = controlVals(6);
    y.DirectorSpacing = controlVals(7:10);
    
    % Calcular parâmetros de desempenho
    s = sparameters(y, fc);
    S11 = max(20*log10(abs(rfparam(s, 1, 1))));
    
    % Calcular diretividade e outras métricas
    Dmax = pattern(y, fc, 0, 90);
    Dback = pattern(y, fc, 180, 90);
    FB = Dmax - Dback;
    
    % Restrições
    c1 = max(0, constraints.Gmin - Dmax);
    c2 = max(0, constraints.FBmin - FB);
    c3 = max(0, S11 - constraints.S11min);
    
    % Valor objetivo
    objectivevalue = -Dmax + c1 + c2 + c3 * constraints.Penalty;
end