clc;
clear;
close all;

% -------------------------------------------------------------------------
% IoTBW demo: matrix-polynomial style benchmark
%
% This script demonstrates the complete optimization flow used in the
% research prototype:
%   1) dynamic range profiling,
%   2) reverse-mode sensitivity aggregation,
%   3) Lagrangian-based continuous bit-width optimization,
%   4) cost-aware integer projection,
%   5) theoretical cost and error evaluation.
%
% The implementation is intentionally structured as a research artifact:
% it preserves the methodology of the original work while exposing all
% intermediate steps in a reproducible and readable form.
% -------------------------------------------------------------------------

% Add source folders to MATLAB path
addpath(fullfile(pwd, 'src', 'core'));
addpath(fullfile(pwd, 'src', 'examples'));

% Reproducibility
rng(0);

% Configuration
cfg = struct();
cfg.Npath = 10000;
cfg.output_fractional_bits = 8;
cfg.vpasolve_initial_value = 25;
cfg.vpasolve_lambda_init = 300000;
cfg.rounding_search_descending = true;

fprintf('============================================================\n');
fprintf('IoTBW Research Prototype - Matrix Polynomial Demo\n');
fprintf('============================================================\n');
fprintf('Number of Monte Carlo samples: %d\n', cfg.Npath);
fprintf('Target output fractional precision: %d bits\n', cfg.output_fractional_bits);

% -------------------------------------------------------------------------
% Stage 1: build benchmark instance
% -------------------------------------------------------------------------
case_data = build_matrix_poly_case(cfg.Npath);

% -------------------------------------------------------------------------
% Stage 2: dynamic range profiling
% -------------------------------------------------------------------------
range_data = estimate_signal_exponents(case_data);

% -------------------------------------------------------------------------
% Stage 3: reverse-mode sensitivity aggregation
% -------------------------------------------------------------------------
sens_data = compute_matrix_poly_sensitivity(case_data, range_data);

% -------------------------------------------------------------------------
% Stage 4: continuous optimization via Lagrange multiplier
% -------------------------------------------------------------------------
solution = solve_fractional_widths_lm(sens_data, cfg);

% -------------------------------------------------------------------------
% Stage 5: integer projection with cost-aware prioritization
% -------------------------------------------------------------------------
result = round_bitwidth_allocation(solution, range_data, sens_data, cfg);

% -------------------------------------------------------------------------
% Report
% -------------------------------------------------------------------------
fprintf('\n');
fprintf('---------------- Continuous solution ----------------\n');
disp(result.continuous_table);

fprintf('---------------- Integer allocation -----------------\n');
disp(result.integer_table);

fprintf('---------------- Summary ----------------------------\n');
fprintf('Theoretical implementation cost : %.6f\n', result.total_cost);
fprintf('Estimated total output error    : %.6e\n', result.total_error);
fprintf('Target error bound              : %.6e\n', 2^(-cfg.output_fractional_bits - 1));
fprintf('Constraint satisfied            : %s\n', string(result.total_error <= 2^(-cfg.output_fractional_bits - 1)));

fprintf('============================================================\n');