%% Clear Workspace and Close figures
clear; close all; clc;

%% Intialize Laplace variable
s = zpk('s');

addpath('./src/');
addpath('examples/cant_beam/');

K = extractMatrix('cant_beam_K.txt');

M = extractMatrix('cant_beam_M.txt');

[int_xyz, int_i] = extractNodes('cant_beam.txt');

open('cant_beam');

%% Name of the Simulink File
mdl = 'cant_beam';

%% Input/Output definition
clear io; io_i = 1;
io(io_i) = linio([mdl, '/F'], 1, 'openinput');  io_i = io_i + 1;
io(io_i) = linio([mdl, '/z'], 1, 'openoutput'); io_i = io_i + 1;

G = linearize(mdl, io);

freqs = logspace(-2, 4, 1000);

figure;
hold on;
plot(freqs, abs(squeeze(freqresp(G, freqs, 'Hz'))), 'k-');
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
ylabel('Amplitude'); xlabel('Frequency [Hz]');

%% Clear Workspace and Close figures
clear; close all; clc;

%% Intialize Laplace variable
s = zpk('s');

addpath('./src/');
addpath('examples/cant_beam_ansys/');

[xn, f0] = extractEigs('cantbeam30bl.eig', 'dirs', [1 0 0 0 0 0]');

n_nodes = size(xn, 1);
n_modes = size(xn, 2);

i_input = 14; % middle of the beam
i_output = 29; % end of the beam

xi = 0.01;

Adiag = zeros(2*n_modes,1);
Adiag(2:2:end) = -2*xi.*(2*pi*f0);

Adiagsup = zeros(2*n_modes-1,1);
Adiagsup(1:2:end) = 1;

Adiaginf = zeros(2*n_modes-1,1);
Adiaginf(1:2:end) = -(2*pi*f0).^2;

A = diag(Adiag) + diag(Adiagsup, 1) + diag(Adiaginf, -1);

B = zeros(2*n_modes, length(i_input));

for i = 1:length(i_input)
    % Physical Coordinates
    Fp = zeros(n_nodes, 1);
    Fp(i_input(i)) = 1;

    B(2:2:end, i) = xn'*Fp;
end

C = zeros(length(i_output), 2*n_modes);
C(:, 1:2:end) = xn(i_output, :);

D = zeros(length(i_output), length(i_input));

G_f = ss(A, B, C, D);

figure;
plot(1:n_modes, f0, 'ko-');
xlabel('Mode Number'); ylabel('Frequency [Hz]');
set(gca, 'XScale', 'lin'); set(gca, 'YScale', 'log');

dc_gain = abs(xn(i_input, :).*xn(i_output, :))./(2*pi*f0).^2;

figure;
plot(1:n_modes, dc_gain, 'ko-');
xlabel('Sorted Modes'); ylabel('DC Values');
set(gca, 'XScale', 'lin'); set(gca, 'YScale', 'log');

m_max = 10;
xn_t = xn(:, 1:m_max);
f0_t = f0(1:m_max);

Adiag = zeros(2*m_max,1);
Adiag(2:2:end) = -2*xi.*(2*pi*f0_t);

Adiagsup = zeros(2*m_max-1,1);
Adiagsup(1:2:end) = 1;

Adiaginf = zeros(2*m_max-1,1);
Adiaginf(1:2:end) = -(2*pi*f0_t).^2;

A = diag(Adiag) + diag(Adiagsup, 1) + diag(Adiaginf, -1);

B = zeros(2*m_max, length(i_input));

for i = 1:length(i_input)
    % Physical Coordinates
    Fp = zeros(n_nodes, 1);
    Fp(i_input(i)) = 1;

    B(2:2:end, i) = xn_t'*Fp;
end

C = zeros(length(i_output), 2*m_max);
C(:, 1:2:end) = xn_t(i_output, :);

D = zeros(length(i_output), length(i_input));

G_t = ss(A, B, C, D);

dc_gain = abs(xn(i_input, :).*xn(i_output, :))./(2*pi*f0).^2;

[dc_gain_sort, index_sort] = sort(dc_gain, 'descend');

figure;
plot(1:n_modes, dc_gain_sort, 'ko-');
xlabel('Sorted Modes'); ylabel('DC Values');
set(gca, 'XScale', 'lin'); set(gca, 'YScale', 'log');

m_max = 10;

xn_s = xn(:, index_sort(1:m_max));
f0_s = f0(index_sort(1:m_max));

Adiag = zeros(2*m_max,1);
Adiag(2:2:end) = -2*xi.*(2*pi*f0_s);

Adiagsup = zeros(2*m_max-1,1);
Adiagsup(1:2:end) = 1;

Adiaginf = zeros(2*m_max-1,1);
Adiaginf(1:2:end) = -(2*pi*f0_s).^2;

A = diag(Adiag) + diag(Adiagsup, 1) + diag(Adiaginf, -1);

B = zeros(2*m_max, length(i_input));

for i = 1:length(i_input)
    % Physical Coordinates
    Fp = zeros(n_nodes, 1);
    Fp(i_input(i)) = 1;

    B(2:2:end, i) = xn_s'*Fp;
end

C = zeros(length(i_output), 2*m_max);
C(:, 1:2:end) = xn_s(i_output, :);

D = zeros(length(i_output), length(i_input));

G_s = ss(A, B, C, D);

freqs = logspace(0, 5, 1000);

figure;
hold on;
plot(freqs, abs(squeeze(freqresp(G_f, freqs, 'Hz'))), 'DisplayName', 'Full');
plot(freqs, abs(squeeze(freqresp(G_t, freqs, 'Hz'))), 'DisplayName', 'Trun');
plot(freqs, abs(squeeze(freqresp(G_s, freqs, 'Hz'))), 'DisplayName', 'Sort');
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
ylabel('Amplitude'); xlabel('Frequency [Hz]');
legend();

freqs = logspace(0, 4, 1000);

figure;
hold on;
for mode_i = 1:10
    A = zeros(2);
    A(2,2) = -2*xi.*(2*pi*f0(mode_i));
    A(1,2) = 1;
    A(2,1) = -(2*pi*f0(mode_i)).^2;

    B = [0; xn(i_input, mode_i)'];

    C = [xn(i_output, mode_i), 0];

    D = zeros(length(i_output), length(i_input));

    plot(freqs, abs(squeeze(freqresp(ss(A,B,C,D), freqs, 'Hz'))), ...
         'DisplayName', sprintf('Mode %i', mode_i));
end
plot(freqs, abs(squeeze(freqresp(G_f, freqs, 'Hz'))), 'k--', ...
     'DisplayName', 'Full');
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
ylabel('Amplitude'); xlabel('Frequency [Hz]');
ylim([1e-9, 1e2]);
legend('location', 'southwest');

a = 1e-2;
b = 1e-6;
xi = (a + b * (2*pi*f0).^2)./(2*pi*f0);

Adiag = zeros(2*n_modes,1);
Adiag(2:2:end) = -2*xi.*(2*pi*f0);

Adiagsup = zeros(2*n_modes-1,1);
Adiagsup(1:2:end) = 1;

Adiaginf = zeros(2*n_modes-1,1);
Adiaginf(1:2:end) = -(2*pi*f0).^2;

A = diag(Adiag) + diag(Adiagsup, 1) + diag(Adiaginf, -1);

B = zeros(2*n_modes, length(i_input));

for i = 1:length(i_input)
    % Physical Coordinates
    Fp = zeros(n_nodes, 1);
    Fp(i_input(i)) = 1;

    B(2:2:end, i) = xn'*Fp;
end

C = zeros(length(i_output), 2*n_modes);
C(:, 1:2:end) = xn(i_output, :);

D = zeros(length(i_output), length(i_input));

G_d = ss(A, B, C, D);

freqs = logspace(0, 5, 1000);

figure;
hold on;
plot(freqs, abs(squeeze(freqresp(G_f, freqs, 'Hz'))), 'DisplayName', 'Uniform Damping');
plot(freqs, abs(squeeze(freqresp(G_d, freqs, 'Hz'))), 'DisplayName', 'Non-Uniform Damping');
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
ylabel('Amplitude'); xlabel('Frequency [Hz]');
legend();

dc_gain = abs(xn(i_input, :).*xn(i_output, :))./(2*pi*f0).^2;
peak_gain = dc_gain./xi;

[peak_gain_sort, index_sort] = sort(peak_gain, 'descend');

figure;
plot(1:n_modes, peak_gain_sort, 'ko-');
xlabel('Sorted Modes'); ylabel('Peak Values');
set(gca, 'XScale', 'lin'); set(gca, 'YScale', 'log');

m_max = 10;

xn_s = xn(:, index_sort(1:m_max));
f0_s = f0(index_sort(1:m_max));
xi_s = xi(index_sort(1:m_max));

Adiag = zeros(2*m_max,1);
Adiag(2:2:end) = -2*xi_s.*(2*pi*f0_s);

Adiagsup = zeros(2*m_max-1,1);
Adiagsup(1:2:end) = 1;

Adiaginf = zeros(2*m_max-1,1);
Adiaginf(1:2:end) = -(2*pi*f0_s).^2;

A = diag(Adiag) + diag(Adiagsup, 1) + diag(Adiaginf, -1);

B = zeros(2*m_max, length(i_input));

for i = 1:length(i_input)
    % Physical Coordinates
    Fp = zeros(n_nodes, 1);
    Fp(i_input(i)) = 1;

    B(2:2:end, i) = xn_s'*Fp;
end

C = zeros(length(i_output), 2*m_max);
C(:, 1:2:end) = xn_s(i_output, :);

D = zeros(length(i_output), length(i_input));

G_p = ss(A, B, C, D);

freqs = logspace(0, 5, 1000);

figure;
hold on;
plot(freqs, abs(squeeze(freqresp(G_f, freqs, 'Hz'))), 'DisplayName', 'Uniform Damping');
plot(freqs, abs(squeeze(freqresp(G_d, freqs, 'Hz'))), 'DisplayName', 'Non-Uniform Damping');
plot(freqs, abs(squeeze(freqresp(G_p, freqs, 'Hz'))), 'DisplayName', 'Peak sort');
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
ylabel('Amplitude'); xlabel('Frequency [Hz]');
legend();

i_input = [14, 31];
i_output = [14, 31];

Adiag = zeros(2*n_modes,1);
Adiag(2:2:end) = -2*xi.*(2*pi*f0);

Adiagsup = zeros(2*n_modes-1,1);
Adiagsup(1:2:end) = 1;

Adiaginf = zeros(2*n_modes-1,1);
Adiaginf(1:2:end) = -(2*pi*f0).^2;

A = diag(Adiag) + diag(Adiagsup, 1) + diag(Adiaginf, -1);

B = zeros(2*n_modes, length(i_input));

for i = 1:length(i_input)
    % Physical Coordinates
    Fp = zeros(n_nodes, 1);
    Fp(i_input(i)) = 1;

    B(2:2:end, i) = xn'*Fp;
end

C = zeros(length(i_output), 2*n_modes);
C(:, 1:2:end) = xn(i_output, :);

D = zeros(length(i_output), length(i_input));

G_m = ss(A, B, C, D);

wc = gram(G_m, 'c');
wo = gram(G_m, 'o');

figure;

subplot(1,2,1);
title('Observability Gramians')
hold on;
plot(1:2:size(A,1), diag(wo(1:2:end, 1:2:end)), 'x', ...
     'DisplayName', 'pos');
plot(2:2:size(A,1), diag(wo(2:2:end, 2:2:end)), 'o', ...
     'DisplayName', 'vel');
hold off;
set(gca, 'XScale', 'lin'); set(gca, 'YScale', 'log');
ylabel('Amplitude'); xlabel('States');
legend();

subplot(1,2,2);
title('Controllability Gramians')
hold on;
plot(1:2:size(A,1), diag(wc(1:2:end, 1:2:end)), 'x', ...
     'DisplayName', 'pos');
plot(2:2:size(A,1), diag(wc(2:2:end, 2:2:end)), 'o', ...
     'DisplayName', 'vel');
hold off;
set(gca, 'XScale', 'lin'); set(gca, 'YScale', 'log');
ylabel('Amplitude'); xlabel('States');
legend();

[G_b, G, T, Ti] = balreal(G_m);

figure;
hold on;
plot(G, 'k.-');
hold off;
set(gca, 'XScale', 'lin'); set(gca, 'YScale', 'log');
ylabel('Diagonal of balanced gramian'); xlabel('State Number');

n_states_b = 10;

G_br = modred(G_b, n_states_b+1:size(A,1), 'truncate');

G_min = 1e-4;
G_br = modred(G_b, G<G_min, 'truncate');

freqs = logspace(0, 4, 1000);

figure;

ax1 = subplot(2, 2, 1);
hold on;
plot(freqs, abs(squeeze(freqresp(G_br(1, 1), freqs, 'Hz'))));
plot(freqs, abs(squeeze(freqresp(G_m( 1, 1), freqs, 'Hz'))));
hold off;
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
xlabel('Frequency [Hz]'); ylabel('$\left|Z_1/F_1\right|$');

ax2 = subplot(2, 2, 2);
hold on;
plot(freqs, abs(squeeze(freqresp(G_br(1, 2), freqs, 'Hz'))));
plot(freqs, abs(squeeze(freqresp(G_m( 1, 2), freqs, 'Hz'))));
hold off;
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
xlabel('Frequency [Hz]'); ylabel('$\left|Z_1/F_2\right|$');

ax3 = subplot(2, 2, 3);
hold on;
plot(freqs, abs(squeeze(freqresp(G_br(2, 1), freqs, 'Hz'))));
plot(freqs, abs(squeeze(freqresp(G_m( 2, 1), freqs, 'Hz'))));
hold off;
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
xlabel('Frequency [Hz]'); ylabel('$\left|Z_2/F_1\right|$');

ax4 = subplot(2, 2, 4);
hold on;
plot(freqs, abs(squeeze(freqresp(G_br(2, 2), freqs, 'Hz'))), 'DisplayName', 'Balanced Red.');
plot(freqs, abs(squeeze(freqresp(G_m( 2, 2), freqs, 'Hz'))), 'DisplayName', 'Full');
hold off;
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
xlabel('Frequency [Hz]'); ylabel('$\left|Z_2/F_2\right|$');
legend('location', 'northeast');
