% === Entrada dos dados ===
% Se 'withfilter' for tabela, use a primeira coluna:
% db_values = withfilter{:,1};
% Se já for vetor, use:
db_values = media;

db_values = db_values(:);  % vetor coluna

% Ângulos correspondentes (-180° a 180°, passo 5° → 73 pontos)
degreeResolution = 5;
angles = (-180:degreeResolution:180)';  

if length(angles) ~= length(db_values)
    error('Número de pontos não bate entre ângulos e valores dB.');
end

% === Pré-processamento ===
mappedAngles = mod(angles, 360);
[sortedAngles, sortIdx] = sort(mappedAngles);
sorted_db = db_values(sortIdx);

% Fechar o círculo
fullAnglesClosed = [sortedAngles; sortedAngles(1)];
dbClosed         = [sorted_db; sorted_db(1)];

invrt = dbClosed;

% Rotacionar por +90° (ajuste de referência)
rotatedAngles = mod(fullAnglesClosed + 270, 360);

% === Encontrar lobo principal e largura de feixe ===
invrt_rel = invrt - max(invrt);   % normalizado ao pico
level = -3;

[~, idx_max] = max(invrt_rel);
main_dir = rotatedAngles(idx_max);

% Caminhar para a esquerda
idx_left = idx_max;
while idx_left > 1 && invrt_rel(idx_left) >= level
    idx_left = idx_left - 1;
end
angle_left = rotatedAngles(idx_left);

% Caminhar para a direita
idx_right = idx_max;
while idx_right < length(invrt_rel) && invrt_rel(idx_right) >= level
    idx_right = idx_right + 1;
end
angle_right = rotatedAngles(idx_right);

beamwidth = angle_right - angle_left;

% --- Ajuste simétrico em torno do main_dir ---
angle_left_sym  = main_dir - beamwidth/2;
angle_right_sym = main_dir + beamwidth/2;

% === Calcular Side Lobe Level (SLL) ===
% Procurar apenas no lado oposto ao lobo principal
opposite_mask = rotatedAngles >= 185 & rotatedAngles <= 355;
side_values = invrt_rel;
side_values(~opposite_mask) = -Inf;   % ignora lado do main lobe
sll = max(side_values);               % maior lóbulos secundários

% === Plot ===
figure;
h1 = polarplot(deg2rad(rotatedAngles), invrt, 'r', 'LineWidth', 1.5);
set(gca, 'ThetaZeroLocation','top','ThetaDir','counterclockwise');
rlim([-75 0]);
title('Antenna Radiation Pattern');
text(-0.2, -0.9, 'Azimuth', 'Units', 'normalized');
text(-0.9, -0.2, 'Gain (dB)', 'Units', 'normalized');
hold on;

% Beamwidth (linhas azuis simétricas)
h2 = polarplot(deg2rad([angle_left_sym angle_left_sym]), rlim, 'b--', 'LineWidth', 1.5);
h3 = polarplot(deg2rad([angle_right_sym angle_right_sym]), rlim, 'b--', 'LineWidth', 1.5);

% Ajustar ticks radiais manualmente
pax = gca;
pax.RTick = -75:15:0;
pax.RTickLabel = arrayfun(@(x) sprintf('%d', x), pax.RTick, 'UniformOutput', false);

% === Legenda em caixa separada ===
legend_str = {
    ['\color{red}—\color{black} Radiation Pattern'], ...
    ['\color{blue}--\color{black} Beamwidth (-3 dB): ', num2str(beamwidth, '%.2f°')], ...
    ['Main Lobe Direction: ', num2str(main_dir, '%.0f°')], ...
    ['Side Lobe Level: ', num2str(sll, '%.2f dB')]
};


annotation('textbox',[0.3, 0.02, 0.4, 0.1],...
           'String',legend_str,...
           'Interpreter','tex',...  
           'FitBoxToText','on',...
           'BackgroundColor','white',...
           'EdgeColor','black');



