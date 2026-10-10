t = -4:0.001:3; % Intervalo de tempo ajustado
T = 2; % Período do sinal

% Definição do sinal alternado entre 1 e 0
a = 1*(t>=-4 & t<-3) + 0*(t>=-3 & t<-2) + ...
    1*(t>=-2 & t<-1) + 0*(t>=-1 & t<0) + ...
    1*(t>=0 & t<1) + 0*(t>=1 & t<2) + ...
    1*(t>=2 & t<=3);

C0 = 0.5; % Valor médio do sinal
xexp = C0*ones(size(t)); % Inicialização para a forma exponencial
xtc = C0*ones(size(t)); % Inicialização para a forma trigonométrica combinada
xt = C0*ones(size(t)); % Inicialização para a forma trigonométrica
erroexp = 1;
errotc = 1;
errot = 1;
k = 1;

while errotc > 0.001 && errot > 0.001 && erroexp > 0.001
    % Coeficiente de Fourier ajustado para o sinal alternado
    C = 1 / (j*k*pi) * (1 - exp(-j*k*pi)); 
    
    % Forma Exponencial Ajustada
    xexp = xexp + 0.5 * (C * exp(1j * k * pi * t) + conj(C) * exp(-1j * k * pi * t));

    
    % Forma Trigonométrica Combinada
    xtc = xtc + 1*abs(C)*cos(k*pi*t + angle(C));
    
    % Forma Trigonométrica (seno)
    xt = xt + (2/(k*pi)) * sin(k*pi*t);
    
    % Calculando os erros
    erroexp = mse(a, xexp);
    errotc = mse(a, xtc);
    errot = mse(a, xt);
    
    disp(['Erro exponencial: ', num2str(erroexp), ...
          ', Erro combinado: ', num2str(errotc), ...
          ', Erro trigonométrico: ', num2str(errot), ...
          ', Termo k: ', num2str(k)]);
    
    k = k + 2; % Incremento para termos ímpares
end

% Gráficos
subplot 221
grid;
plot(t, a);
xlabel('t(s)');
ylabel('Amplitude');
title('Sinal Original');
ylim([-0.5 1.5]);
xlim([-4 3]);
grid;

subplot 222
plot(t, xexp);
xlabel('t(s)');
ylabel('Amplitude');
title('Forma Exponencial');
ylim([-0.5 1.5]);
xlim([-4 3]);

subplot 223
plot(t, xtc);
xlabel('t(s)');
ylabel('Amplitude');
title('Forma Trigonométrica Combinada');
ylim([-0.5 1.5]);
xlim([-4 3]);

subplot 224
plot(t, xt);
xlabel('t(s)');
ylabel('Amplitude');
title('Forma Trigonométrica');
ylim([-0.5 1.5]);
xlim([-4 3]);

