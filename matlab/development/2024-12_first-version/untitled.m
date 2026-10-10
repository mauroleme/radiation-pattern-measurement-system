t = -2.5:0.001:3.5;
a=-2*(t>=-2)+2*(t>=-1)-2*(t>=0)+2*(t>=1)-2*(t>=2)+2*(t>=3);
C0 = -1;
xexp = C0*ones(size(t));
xtc = C0*ones(size(t));
xt = C0*ones(size(t));
erroexp = 1;
errotc= 1;
errot = 1;
k = 1;
while errotc > 0.001 && errot > 0.001 && erroexp > 0.00
    C = (exp(-1j*k*pi)-1)/(1j*k*pi);
    xexp = xexp+C*exp(1j*k*pi*t)+conj(C)*exp(-1j*k*pi*t);
    xtc = xtc+(2*abs(C))*(cos(k*pi*t+angle(C)));
    xt = xt-4/(k*pi)*sin(k*pi*t);
    erroexp = mse(a, xexp);
    errotc = mse(a, xtc);
    errot = mse(a, xt);
    erroexp
    errotc
    errot
    k
    k = k+2;
end
subplot 221
plot(t,a);
xlabel('t(s)');
ylabel('Amplitude');
title('Sinal Original');
ylim([-2.3 0.3]);
xlim([-2.5 3.5]);
subplot 222
plot(t,xexp);
xlabel('t(s)');
ylabel('Amplitude');
title('Forma Exponencial');
ylim([-2.3 0.3]);
xlim([-2.5 3.5]);
subplot 223
plot(t, xtc);
xlabel('t(s)');
ylabel('Amplitude');
title('Forma Trigonométrica Combinada');
ylim([-2.3 0.3]);
xlim([-2.5 3.5]);
subplot 224
plot(t,xt);
xlabel('t(s)');
ylabel('Amplitude');
title('Forma Trigonométrica');
ylim([-2.3 0.3]);
xlim([-2.5 3.5]);