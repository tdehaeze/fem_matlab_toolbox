%% Clear Workspace and Close figures
clear; close all; clc;

%% Intialize Laplace variable
s = zpk('s');

addpath('./src/');
addpath('examples/piezo_stack_sensor/');

K = extractMatrix('piezo_stack_sensor_K.txt');

M = extractMatrix('piezo_stack_sensor_M.txt');

[int_xyz, int_i] = extractNodes('piezo_stack_sensor.txt');

open('piezo_stack_sensor');

m = 0;

%% Name of the Simulink File
mdl = 'piezo_stack_sensor';

%% Input/Output definition
clear io; io_i = 1;
io(io_i) = linio([mdl, '/F'], 1, 'openinput');  io_i = io_i + 1;
io(io_i) = linio([mdl, '/x'], 1, 'openoutput'); io_i = io_i + 1;

G = linearize(mdl, io);

m = 10;

%% Name of the Simulink File
mdl = 'piezo_stack_sensor';

%% Input/Output definition
clear io; io_i = 1;
io(io_i) = linio([mdl, '/F'], 1, 'openinput');  io_i = io_i + 1;
io(io_i) = linio([mdl, '/x'], 1, 'openoutput'); io_i = io_i + 1;

Gm = linearize(mdl, io);

freqs = logspace(2, 6, 1000);

figure;

ax1 = subplot(2,1,1);
hold on;
plot(freqs, abs(squeeze(freqresp(G, freqs, 'Hz'))), 'k-');
plot(freqs, abs(squeeze(freqresp(Gm, freqs, 'Hz'))), 'k--');
hold off;
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
ylabel('Amplitude'); set(gca, 'XTickLabel',[]);
hold off;

ax2 = subplot(2,1,2);
hold on;
plot(freqs, 180/pi*angle(squeeze(freqresp(G, freqs, 'Hz'))), 'k-');
plot(freqs, 180/pi*angle(squeeze(freqresp(Gm, freqs, 'Hz'))), 'k--');
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'lin');
yticks(-180:90:180);
ylim([-180 180]);
xlabel('Frequency [Hz]'); ylabel('Phase [deg]');
hold off;
linkaxes([ax1,ax2],'x');
xlim([freqs(1), freqs(end)]);
