close all;
clear all;
clc;

% Definir o raio desejado
radius = 1.5e-3; % 1.5 mm
width = cylinder2strip(radius); % Calcular a largura equivalente

% Criar uma antena Yagi-Uda
antennaObject = design(yagiUda, 868*1e6);

% Criar um dipolo reto como Exciter
d = dipole('Length', 0.14765, 'Width', width);
d.Conductor = metal('Brass');

% Ajustar a orientação do dipolo
d.Tilt = 90; % Girar 90 graus
d.TiltAxis = [0 1 0]; % Girar em torno do eixo Y

% Atribuir o dipolo reto como Exciter
antennaObject.Exciter = d;

% Configurar propriedades da antena
antennaObject.NumDirectors = 4;
antennaObject.DirectorLength = [0.13101, 0.14532, 0.13172, 0.14197];
antennaObject.DirectorSpacing = [0.11438, 0.11935, 0.11202, 0.10794];
antennaObject.ReflectorLength = 0.17233;
antennaObject.ReflectorSpacing = 0.066072;
antennaObject.Conductor = metal('Brass');

% Ajustar a largura dos elementos para representar cilindros
antennaObject.Exciter.Width = width; % Usar largura equivalente para o exciter

% Visualizar a antena
figure;
show(antennaObject);

% Análise da Antena
% Definir frequência de plotagem
plotFrequency = 868*1e6;
% Definir faixa de frequência
freqRange = (781.2:8.68:954.8)*1e6;
% Impedância de referência
refImpedance = 50;

% Impedância
figure;
impedance(antennaObject, freqRange);

% Parâmetros S
figure;
s = sparameters(antennaObject, freqRange, refImpedance);
rfplot(s);

% Padrão de radiação
figure;
pattern(antennaObject, plotFrequency);

% Padrão de azimute
figure;
patternAzimuth(antennaObject, plotFrequency, 0, 'Azimuth', 0:5:360);

% Padrão de elevação
figure;
patternElevation(antennaObject, plotFrequency, 0, 'Elevation', 0:5:360);

% Corrente
figure;
current(antennaObject, plotFrequency);