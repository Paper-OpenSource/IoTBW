clc;
clear;
close all;

% -------------------------------------------------------------------------
% IoTBW demo: batch-aware dynamic bit-width optimization
%
% This script demonstrates a batched dynamic optimization workflow for a
% polynomial-style benchmark. The implementation follows the methodology of
% the original research prototype while exposing all stages in a modular and
% reproducible manner:
%
%   1) multi-batch Monte Carlo simulation,
%   2) dynamic range profiling,
%   3) reverse-mode sensitivity aggregation,
%   4) per-batch Lagrangian optimization,
%   5) cross-batch allocation consolidation,
%   6) cost-aware integer projection,
%   7) theoretical cost and error evaluation.
%
% The present code is intended as a research artifact rather than a fully
% generalized optimization framework.
% -------------------------------------------------------------------------

addpath(fullfile(pwd, 'src', 'core'));
addpath(fullfile(pwd, 'src', 'batch_examples'));

rng(0);

cfg = struct();
cfg.batch_sizes = [1000, repmat(50, 1, 40)];
cfg.output_fractional_bits = 8;
cfg.vpasolve_initial_value = 25;
cfg.vpasolve_lambda_init = 100000;
cfg.enable_sensitivity_weighted_update = true;
cfg.rounding_search_descending = true;

fprintf('============================================================\n');
fprintf('IoTBW Research Prototype - Batch Polynomial Demo\n');
fprintf('============================================================\n');
fprintf('Number of batches          : %d\n', numel(cfg.batch_sizes));
fprintf('Primary batch size         : %d\n', cfg.batch_sizes(1));
fprintf('Secondary batch size       : %d\n', cfg.batch_sizes(2));
fprintf('Target output precision    : %d fractional bits\n', cfg.output_fractional_bits);

% -------------------------------------------------------------------------
% Stage 1: build benchmark case across batches
% -------------------------------------------------------------------------
case_data = build_batch_poly_case(cfg);

% -------------------------------------------------------------------------
% Stage 2: dynamic range profiling and per-batch sensitivity estimation
% -------------------------------------------------------------------------
profile_data = profile_batch_poly_sensitivity(case_data);

% -------------------------------------------------------------------------
% Stage 3: solve the Lagrangian system independently for each batch
% -------------------------------------------------------------------------
batch_solution = solve_batch_fractional_widths_lm(profile_data, cfg);

% -------------------------------------------------------------------------
% Stage 4: aggregate continuous solutions across batches
% -------------------------------------------------------------------------
aggregate_result = aggregate_batch_solutions(batch_solution, profile_data, cfg);

% -------------------------------------------------------------------------
% Stage 5: cost-aware integer projection
% -------------------------------------------------------------------------
final_result = round_batch_poly_allocation(aggregate_result, profile_data, cfg);

% -------------------------------------------------------------------------
% Stage 6: summary report
% -------------------------------------------------------------------------
summarize_batch_poly_results(final_result, profile_data, cfg);

fprintf('============================================================\n');