#!/usr/bin/octave -qf
% Complex Octave Demonstration: Nonlinear Equation Solving
% Showcases: fsolve, optimization, numerical integration, plotting, and more

clear all;
close all;
clc;

% Suppress convergence warnings for cleaner output
warning('off', 'Octave:singular-matrix');
warning('off', 'Octave:nearly-singular-matrix');

fprintf('\n========================================\n');
fprintf('OCTAVE NONLINEAR SOLVER DEMONSTRATION\n');
fprintf('========================================\n\n');

%% PART 1: Solve System of Nonlinear Equations
fprintf('PART 1: Solving System of Nonlinear Equations\n');
fprintf('----------------------------------------------\n');
fprintf('System:\n');
fprintf('  x^2 + y^2 = 25\n');
fprintf('  x*y = 12\n\n');

% Define the system of equations
function F = nonlinear_system(x)
    F(1) = x(1)^2 + x(2)^2 - 25;  % x^2 + y^2 = 25 (circle)
    F(2) = x(1) * x(2) - 12;       % x*y = 12 (hyperbola)
endfunction

% Solve from different initial guesses
initial_guesses = [1, 1; -1, -1; 5, 5; -5, -5];
solutions = [];

for i = 1:size(initial_guesses, 1)
    x0 = initial_guesses(i, :);
    [x, fval, info] = fsolve(@nonlinear_system, x0);

    if info == 1
        fprintf('Solution %d (from initial guess [%.1f, %.1f]):\n', i, x0(1), x0(2));
        fprintf('  x = %.6f, y = %.6f\n', x(1), x(2));
        fprintf('  Verification: x^2 + y^2 = %.6f, x*y = %.6f\n', x(1)^2 + x(2)^2, x(1)*x(2));
        fprintf('  Residual norm: %.2e\n\n', norm(fval));
        solutions = [solutions; x];
    endif
endfor

%% PART 2: Nonlinear Least Squares Fitting
fprintf('\nPART 2: Nonlinear Least Squares Curve Fitting\n');
fprintf('----------------------------------------------\n');
fprintf('Fitting data to: y = a*exp(b*x) + c\n\n');

% Generate noisy exponential data
x_data = linspace(0, 5, 50)';
a_true = 2.5; b_true = -0.8; c_true = 1.0;
y_true = a_true * exp(b_true * x_data) + c_true;
y_data = y_true + 0.1 * randn(size(y_true));

% Objective function for least squares (sum of squared residuals)
function [sse, grad] = exponential_objective(params, x, y)
    a = params(1);
    b = params(2);
    c = params(3);
    y_model = a * exp(b * x) + c;
    residuals = y_model - y;
    sse = sum(residuals.^2);

    if nargout > 1
        % Gradient
        dsse_da = 2 * sum(residuals .* exp(b * x));
        dsse_db = 2 * sum(residuals .* (a * x .* exp(b * x)));
        dsse_dc = 2 * sum(residuals);
        grad = [dsse_da; dsse_db; dsse_dc];
    endif
endfunction

% Fit the model using fminunc
initial_params = [1, -1, 0];
params_fit = fminunc(@(p) exponential_objective(p, x_data, y_data), initial_params);
residual = a_true * exp(b_true * x_data) + c_true - (params_fit(1) * exp(params_fit(2) * x_data) + params_fit(3));

fprintf('True parameters:   a = %.4f, b = %.4f, c = %.4f\n', a_true, b_true, c_true);
fprintf('Fitted parameters: a = %.4f, b = %.4f, c = %.4f\n', params_fit(1), params_fit(2), params_fit(3));
fprintf('RMS error: %.6f\n\n', sqrt(mean(residual.^2)));

%% PART 3: Root Finding for Transcendental Equation
fprintf('\nPART 3: Finding Roots of Transcendental Equation\n');
fprintf('------------------------------------------------\n');
fprintf('Equation: x*exp(x) - 5 = 0\n\n');

% Define transcendental equation
function y = transcendental(x)
    y = x .* exp(x) - 5;
endfunction

% Find root using fzero
x_root = fzero(@transcendental, 1);
fprintf('Root found: x = %.10f\n', x_root);
fprintf('Verification: x*exp(x) = %.10f\n', x_root * exp(x_root));
fprintf('Error: %.2e\n\n', abs(x_root * exp(x_root) - 5));

%% PART 4: Optimization - Find Minimum of Complex Function
fprintf('\nPART 4: Unconstrained Optimization\n');
fprintf('----------------------------------\n');
fprintf('Minimize: f(x,y) = (x-3)^2 + (y+2)^2 + sin(x*y)\n\n');

% Define objective function
function [f, g] = rosenbrock_like(x)
    f = (x(1) - 3)^2 + (x(2) + 2)^2 + sin(x(1) * x(2));
    if nargout > 1
        % Gradient
        g(1) = 2*(x(1) - 3) + x(2)*cos(x(1)*x(2));
        g(2) = 2*(x(2) + 2) + x(1)*cos(x(1)*x(2));
    endif
endfunction

% Minimize
[x_min, fmin, info] = fminunc(@rosenbrock_like, [0, 0]);
fprintf('Minimum found at: x = %.6f, y = %.6f\n', x_min(1), x_min(2));
fprintf('Function value at minimum: f = %.6f\n\n', fmin);

%% PART 5: Numerical Integration of Nonlinear Function
fprintf('\nPART 5: Numerical Integration\n');
fprintf('-----------------------------\n');
fprintf('Integrate: ∫[0,π] x*sin(x^2) dx\n\n');

% Define integrand
function y = integrand(x)
    y = x .* sin(x.^2);
endfunction

% Perform integration
[integral_val, ier, nfun, err] = quad(@integrand, 0, pi);
fprintf('Integral value: %.10f\n', integral_val);
fprintf('Estimated error: %.2e\n', err);
fprintf('Function evaluations: %d\n\n', nfun);

%% PART 6: Solve Nonlinear ODE System (Lorenz Attractor)
fprintf('\nPART 6: Solving Lorenz Attractor (Chaotic System)\n');
fprintf('-------------------------------------------------\n');

% Lorenz system parameters
sigma = 10;
rho = 28;
beta = 8/3;

% Define Lorenz equations
function xdot = lorenz(x, t)
    sigma = 10;
    rho = 28;
    beta = 8/3;

    xdot(1) = sigma * (x(2) - x(1));
    xdot(2) = x(1) * (rho - x(3)) - x(2);
    xdot(3) = x(1) * x(2) - beta * x(3);
endfunction

% Initial conditions and time span
x0 = [1; 1; 1];
t = linspace(0, 20, 2000);

% Solve ODE system
x = lsode(@lorenz, x0, t);

fprintf('Initial conditions: [%.1f, %.1f, %.1f]\n', x0(1), x0(2), x0(3));
fprintf('Final state: [%.4f, %.4f, %.4f]\n', x(end,1), x(end,2), x(end,3));
fprintf('Time span: %.1f to %.1f seconds\n', t(1), t(end));
fprintf('Points computed: %d\n\n', length(t));

%% PART 7: Matrix Operations and Eigenvalue Problems
fprintf('\nPART 7: Nonlinear Eigenvalue Problem\n');
fprintf('------------------------------------\n');

% Create a nonlinear matrix problem
A = [4, -1, 0; -1, 4, -1; 0, -1, 4];
fprintf('Matrix A:\n');
disp(A);

[eigvec, eigval] = eig(A);
fprintf('Eigenvalues:\n');
disp(diag(eigval)');

% Power iteration to find dominant eigenvalue
x_iter = ones(3, 1);
for i = 1:20
    x_iter = A * x_iter;
    x_iter = x_iter / norm(x_iter);
endfor
lambda_dominant = (x_iter' * A * x_iter) / (x_iter' * x_iter);
fprintf('Dominant eigenvalue (power iteration): %.10f\n', lambda_dominant);
fprintf('Dominant eigenvector: [%.6f, %.6f, %.6f]\n\n', x_iter(1), x_iter(2), x_iter(3));

%% PART 8: Create Visualizations
fprintf('\nPART 8: Generating Visualizations\n');
fprintf('---------------------------------\n');
fprintf('Creating plots...\n\n');

% Figure 1: Nonlinear system intersections
figure(1, 'position', [100, 100, 1200, 400]);

subplot(1, 3, 1);
theta = linspace(0, 2*pi, 100);
x_circle = 5 * cos(theta);
y_circle = 5 * sin(theta);
x_hyp = linspace(-6, 6, 100);
y_hyp1 = 12 ./ x_hyp;
plot(x_circle, y_circle, 'b-', 'linewidth', 2); hold on;
plot(x_hyp, y_hyp1, 'r-', 'linewidth', 2);
if size(solutions, 1) > 0
    plot(solutions(:,1), solutions(:,2), 'ko', 'markersize', 10, 'markerfacecolor', 'g');
endif
grid on;
xlabel('x'); ylabel('y');
title('Nonlinear System Solutions');
legend('x^2 + y^2 = 25', 'xy = 12', 'Solutions');
axis equal;
xlim([-6 6]); ylim([-6 6]);

% Figure 2: Curve fitting
subplot(1, 3, 2);
x_fit = linspace(0, 5, 200)';
y_fit = params_fit(1) * exp(params_fit(2) * x_fit) + params_fit(3);
plot(x_data, y_data, 'b.', 'markersize', 10); hold on;
plot(x_fit, y_fit, 'r-', 'linewidth', 2);
grid on;
xlabel('x'); ylabel('y');
title('Nonlinear Curve Fitting');
legend('Data', 'Fitted curve');

% Figure 3: Lorenz attractor
subplot(1, 3, 3);
plot3(x(:,1), x(:,2), x(:,3), 'b-', 'linewidth', 0.5);
grid on;
xlabel('X'); ylabel('Y'); zlabel('Z');
title('Lorenz Attractor (Chaotic System)');
view(45, 30);

% Figure 2: More visualizations
figure(2, 'position', [100, 600, 1200, 400]);

subplot(1, 3, 1);
x_trans = linspace(-1, 3, 200);
y_trans = transcendental(x_trans);
plot(x_trans, y_trans, 'b-', 'linewidth', 2); hold on;
plot(x_root, 0, 'ro', 'markersize', 10, 'markerfacecolor', 'r');
plot(x_trans, zeros(size(x_trans)), 'k--');
grid on;
xlabel('x'); ylabel('f(x)');
title('Transcendental Equation Root');
legend('f(x) = x*exp(x) - 5', 'Root');

subplot(1, 3, 2);
[X, Y] = meshgrid(linspace(-2, 6, 100), linspace(-5, 2, 100));
Z = (X - 3).^2 + (Y + 2).^2 + sin(X .* Y);
contour(X, Y, Z, 30);
hold on;
plot(x_min(1), x_min(2), 'r*', 'markersize', 15, 'linewidth', 2);
colorbar;
grid on;
xlabel('x'); ylabel('y');
title('Optimization Contours');

subplot(1, 3, 3);
x_int = linspace(0, pi, 200);
y_int = integrand(x_int);
area(x_int, y_int, 'facecolor', [0.7 0.9 1.0]);
grid on;
xlabel('x'); ylabel('f(x)');
title(sprintf('Numerical Integration\nArea = %.4f', integral_val));

fprintf('Plots generated successfully!\n');
fprintf('Close the plot windows to exit.\n\n');

fprintf('========================================\n');
fprintf('DEMONSTRATION COMPLETE\n');
fprintf('========================================\n\n');

% Keep plots open
fprintf('Press Enter to close and exit...\n');
pause;
