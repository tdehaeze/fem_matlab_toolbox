%% Clear Workspace and Close figures
clear; close all; clc;

%% Intialize Laplace variable
s = zpk('s');

addpath('./src/');
addpath('examples/piezo_stack/');

open('piezo_stack');

K = extractMatrix('piezo_stack_half_K.txt');
M = extractMatrix('piezo_stack_half_M.txt');

[int_xyz, int_i, n_xyz, n_i, nodes] = extractNodes('piezo_stack_half.txt');

m = 0;

%% Name of the Simulink File
mdl = 'piezo_stack';

%% Input/Output definition
clear io; io_i = 1;
io(io_i) = linio([mdl, '/F'], 1, 'openinput');  io_i = io_i + 1;
io(io_i) = linio([mdl, '/x'], 1, 'openoutput'); io_i = io_i + 1;

Gh = linearize(mdl, io);

m = 1;

%% Name of the Simulink File
mdl = 'piezo_stack';

%% Input/Output definition
clear io; io_i = 1;
io(io_i) = linio([mdl, '/F'], 1, 'openinput');  io_i = io_i + 1;
io(io_i) = linio([mdl, '/x'], 1, 'openoutput'); io_i = io_i + 1;

Ghm = linearize(mdl, io);

freqs = logspace(3, 6, 1000);

figure;

ax1 = subplot(2,1,1);
hold on;
plot(freqs, abs(squeeze(freqresp(Gh, freqs, 'Hz'))), 'k-');
plot(freqs, abs(squeeze(freqresp(Ghm, freqs, 'Hz'))), 'k--');
hold off;
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
ylabel('Amplitude'); set(gca, 'XTickLabel',[]);
hold off;

ax2 = subplot(2,1,2);
hold on;
plot(freqs, 180/pi*angle(squeeze(freqresp(Gh, freqs, 'Hz'))), 'k-', ...
     'DisplayName', '$m = 0kg$');
plot(freqs, 180/pi*angle(squeeze(freqresp(Ghm, freqs, 'Hz'))), 'k--', ...
     'DisplayName', '$m = 1kg$');
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'lin');
yticks(-180:90:180);
ylim([-180 180]);
xlabel('Frequency [Hz]'); ylabel('Phase [deg]');
hold off;
linkaxes([ax1,ax2],'x');
xlim([freqs(1), freqs(end)]);
legend('location', 'southwest');

K = extractMatrix('piezo_stack_actuator_K.txt');
M = extractMatrix('piezo_stack_actuator_M.txt');

[int_xyz, int_i, n_xyz, n_i, nodes] = extractNodes('piezo_stack_actuator.txt');

m = 0;

%% Name of the Simulink File
mdl = 'piezo_stack_sensor';

%% Input/Output definition
clear io; io_i = 1;
io(io_i) = linio([mdl, '/F'], 1, 'openinput');  io_i = io_i + 1;
io(io_i) = linio([mdl, '/x'], 1, 'openoutput'); io_i = io_i + 1;

Ga = linearize(mdl, io);

m = 1;

%% Name of the Simulink File
mdl = 'piezo_stack_sensor';

%% Input/Output definition
clear io; io_i = 1;
io(io_i) = linio([mdl, '/F'], 1, 'openinput');  io_i = io_i + 1;
io(io_i) = linio([mdl, '/x'], 1, 'openoutput'); io_i = io_i + 1;

Gam = linearize(mdl, io);

freqs = logspace(3, 6, 1000);

figure;

ax1 = subplot(2,1,1);
hold on;
plot(freqs, abs(squeeze(freqresp(Ga, freqs, 'Hz'))), 'k-');
plot(freqs, abs(squeeze(freqresp(Gam, freqs, 'Hz'))), 'k--');
hold off;
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
ylabel('Amplitude'); set(gca, 'XTickLabel',[]);
hold off;

ax2 = subplot(2,1,2);
hold on;
plot(freqs, 180/pi*angle(squeeze(freqresp(Ga, freqs, 'Hz'))), 'k-', ...
     'DisplayName', '$m = 0kg$');
plot(freqs, 180/pi*angle(squeeze(freqresp(Gam, freqs, 'Hz'))), 'k--', ...
     'DisplayName', '$m = 1kg$');
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'lin');
yticks(-180:90:180);
ylim([-180 180]);
xlabel('Frequency [Hz]'); ylabel('Phase [deg]');
hold off;
linkaxes([ax1,ax2],'x');
xlim([freqs(1), freqs(end)]);
legend('location', 'southwest');

freqs = logspace(3, 6, 1000);

figure;

ax1 = subplot(2,1,1);
hold on;
plot(freqs, abs(squeeze(freqresp(Gh, freqs, 'Hz'))), 'k-');
plot(freqs, abs(squeeze(freqresp(Ga, freqs, 'Hz'))), 'k--');
hold off;
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
ylabel('Amplitude'); set(gca, 'XTickLabel',[]);
hold off;

ax2 = subplot(2,1,2);
hold on;
plot(freqs, 180/pi*angle(squeeze(freqresp(Gh, freqs, 'Hz'))), 'k-', ...
     'DisplayName', 'Half');
plot(freqs, 180/pi*angle(squeeze(freqresp(Ga, freqs, 'Hz'))), 'k--', ...
     'DisplayName', 'Mostly Actuator');
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'lin');
yticks(-180:90:180);
ylim([-180 180]);
xlabel('Frequency [Hz]'); ylabel('Phase [deg]');
hold off;
linkaxes([ax1,ax2],'x');
xlim([freqs(1), freqs(end)]);
legend('location', 'southwest');
