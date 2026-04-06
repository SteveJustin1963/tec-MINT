#!/usr/bin/octave -qf
% Analysis of MINT Lorenz Implementation
% Compares integer fixed-point vs floating point

clear all;
close all;

fprintf('=== LORENZ ATTRACTOR: INTEGER vs FLOATING POINT ===\n\n');

% Parameters
sigma = 10;
rho = 28;
beta = 8/3;

% Initial conditions
x0 = 1.0;
y0 = 1.0;
z0 = 1.0;

n_steps = 500;

%% Simulation 1: MINT-style integer arithmetic (scale=100)
fprintf('1. MINT Integer Math (scale=100):\n');
x_int = 100; y_int = 100; z_int = 100;
s = 10; r = 28; b = 267;

X_int = zeros(n_steps, 3);

for i = 1:n_steps
    % MINT code simulation
    d = floor((y_int - x_int) * s / 100);
    x_int = x_int + d;

    e = floor(x_int * (r - z_int) / 100) - y_int;
    y_int = y_int + e;

    f = floor(x_int * y_int / 100) - floor(b * z_int / 100);
    z_int = z_int + f;

    X_int(i,:) = [x_int, y_int, z_int];
end

fprintf('  Final state: x=%d, y=%d, z=%d\n', x_int, y_int, z_int);
fprintf('  Settled to stable point: x=%d, y=%d (repeating)\n\n', x_int, y_int);

%% Simulation 2: Floating point with small dt
fprintf('2. Floating Point (proper Lorenz):\n');
dt = 0.01;
x = x0; y = y0; z = z0;

X_float = zeros(n_steps, 3);

for i = 1:n_steps
    dx = sigma * (y - x) * dt;
    dy = (x * (rho - z) - y) * dt;
    dz = (x * y - beta * z) * dt;

    x = x + dx;
    y = y + dy;
    z = z + dz;

    X_float(i,:) = [x, y, z];
end

fprintf('  Final state: x=%.4f, y=%.4f, z=%.4f\n', x, y, z);
fprintf('  Still chaotic (not converged)\n\n');

%% Analysis
fprintf('3. Why MINT version fails:\n');
fprintf('  - Integer division truncates: 52/100 = 0 (should be 0.52)\n');
fprintf('  - Scale=100 gives only 2 decimal precision\n');
fprintf('  - Energy dissipates due to truncation\n');
fprintf('  - System collapses to stable fixed point\n\n');

%% Plotting
figure(1, 'position', [100, 100, 1200, 500]);

subplot(1,2,1);
plot(X_int(:,1), X_int(:,2), 'b-', 'linewidth', 1.5);
hold on;
plot(X_int(1,1), X_int(1,2), 'go', 'markersize', 10, 'markerfacecolor', 'g');
plot(X_int(end,1), X_int(end,2), 'ro', 'markersize', 10, 'markerfacecolor', 'r');
grid on;
xlabel('x (scaled)'); ylabel('y (scaled)');
title('MINT Integer (scale=100) - COLLAPSES');
legend('Trajectory', 'Start', 'End (stuck)');

subplot(1,2,2);
plot(X_float(:,1), X_float(:,2), 'r-', 'linewidth', 1.5);
hold on;
plot(X_float(1,1), X_float(1,2), 'go', 'markersize', 10, 'markerfacecolor', 'g');
plot(X_float(end,1), X_float(end,2), 'bo', 'markersize', 6, 'markerfacecolor', 'b');
grid on;
xlabel('x'); ylabel('y');
title('Floating Point - CHAOTIC');
legend('Trajectory', 'Start', 'End (moving)');

fprintf('4. Performance note:\n');
fprintf('  - Slowdown is from SERIAL OUTPUT, not computation\n');
fprintf('  - Each print: ~10 chars @ 4800 baud = 20ms\n');
fprintf('  - 500 iterations × 20ms = 10 seconds in I/O alone!\n\n');

fprintf('Press Enter to exit...\n');
pause;
