close all; clear; clc;

% Definir frequência de operação
freq = 868e6; % 868 MHz

% Criar uma antena Yagi-Uda com 3 diretores
yagi = yagiUda('NumDirectors', 3);

% Ajustar os comprimentos e espaçamentos dos elementos
yagi.ReflectorLength = 0.5; % Comprimento do refletor em metros
yagi.ReflectorSpacing = 0.2; % Espaçamento entre o refletor e o elemento ativo em metros
yagi.DirectorLength = 0.38; % Comprimento dos diretores em metros
yagi.DirectorSpacing = 0.2; % Espaçamento entre os diretores em metros

% Definir o material dos elementos como latão (brass)
yagi.Conductor         = metal('Brass');
yagi.Exciter.Conductor = metal('Brass');

% Visualizar a antena
figure;
show(yagi);

% Calcular e visualizar o padrão de radiação
figure;
pattern(yagi, freq);