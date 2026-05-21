function result = round_bitwidth_allocation(solution, E, C, cfg)
%ROUND_BITWIDTH_ALLOCATION Project continuous bit-widths to integer values
% using a cost-aware rounding strategy.
%
% This function implements a practical integer projection step that is
% consistent with the paper's rounding philosophy:
%   1) solve the continuous relaxation,
%   2) estimate the penalty of flooring each variable,
%   3) prioritize signals according to a cost-aware metric,
%   4) search for a valid integer allocation under the error bound.
%
% Output:
%   result : structure containing the final integer allocation, tables,
%            theoretical cost, and estimated total error

target_error = 2^(-cfg.output_fractional_bits - 1);

signal_names = { ...
    'x1','x2','y1','y2','z1','z2','z3','z4', ...
    'd1','d2','e1','e2','f1','f2','g1','g2', ...
    'h1','h2','a1','a2','b1','b2','c1','k1'};

% -------------------------------------------------------------------------
% Continuous solution vector
% -------------------------------------------------------------------------
D_cont = [solution.dx1, solution.dx2, solution.dy1, solution.dy2, ...
          solution.dz1, solution.dz2, solution.dz3, solution.dz4, ...
          solution.dd1, solution.dd2, solution.de1, solution.de2, ...
          solution.df1, solution.df2, solution.dg1, solution.dg2, ...
          solution.dh1, solution.dh2, solution.da1, solution.da2, ...
          solution.db1, solution.db2, solution.dc1, solution.dk1];

D_cont = double(D_cont);

% Integer exponent vector
E_vec = [E.Ex1,E.Ex2,E.Ey1,E.Ey2,E.Ez1,E.Ez2,E.Ez3,E.Ez4,...
         E.Ed1,E.Ed2,E.Ee1,E.Ee2,E.Ef1,E.Ef2,E.Eg1,E.Eg2,...
         E.Eh1,E.Eh2,E.Ea1,E.Ea2,E.Eb1,E.Eb2,E.Ec1,E.Ek1];

% Coefficient vector
C_vec = [C.Cx1,C.Cx2,C.Cy1,C.Cy2,C.Cz1,C.Cz2,C.Cz3,C.Cz4,...
         C.Cd1,C.Cd2,C.Ce1,C.Ce2,C.Cf1,C.Cf2,C.Cg1,C.Cg2,...
         C.Ch1,C.Ch2,C.Ca1,C.Ca2,C.Cb1,C.Cb2,C.Cc1,C.Ck1];

% -------------------------------------------------------------------------
% Fractional remainder
% -------------------------------------------------------------------------
frac = D_cont - floor(D_cont);
frac(frac == 0) = eps;

% -------------------------------------------------------------------------
% Error penalty caused by flooring the continuous solution
% -------------------------------------------------------------------------
error_penalty = C_vec .* (2.^(-floor(D_cont)) - 2.^(-D_cont));

% -------------------------------------------------------------------------
% Bit-cost reduction approximation
%
% The expressions below preserve the structural dependency used in the
% original prototype and provide a practical ranking signal for rounding.
% -------------------------------------------------------------------------
bit_cost = zeros(1, 24);

bit_cost(1)  = floor(D_cont(3)) + floor(D_cont(4));
bit_cost(2)  = floor(D_cont(3)) + floor(D_cont(4));
bit_cost(3)  = floor(D_cont(1)) + floor(D_cont(2));
bit_cost(4)  = floor(D_cont(1)) + floor(D_cont(2));
bit_cost(5)  = floor(D_cont(9));
bit_cost(6)  = floor(D_cont(10));
bit_cost(7)  = floor(D_cont(9));
bit_cost(8)  = floor(D_cont(10));
bit_cost(9)  = floor(D_cont(5)) + floor(D_cont(7));
bit_cost(10) = floor(D_cont(6)) + floor(D_cont(8));
bit_cost(11) = 1;
bit_cost(12) = 1;
bit_cost(13) = 1;
bit_cost(14) = 1;
bit_cost(15) = floor(D_cont(17));
bit_cost(16) = floor(D_cont(18));
bit_cost(17) = floor(D_cont(15));
bit_cost(18) = floor(D_cont(16));
bit_cost(19) = floor(D_cont(21));
bit_cost(20) = floor(D_cont(22));
bit_cost(21) = floor(D_cont(19));
bit_cost(22) = floor(D_cont(20));
bit_cost(23) = 1;
bit_cost(24) = 1;

cost_error_metric = bit_cost ./ max(error_penalty, eps);

% -------------------------------------------------------------------------
% Priority ordering
% Signals with larger CostError are better candidates for flooring.
% -------------------------------------------------------------------------
if cfg.rounding_search_descending
    [~, priority] = sort(cost_error_metric, 'descend');
else
    [~, priority] = sort(cost_error_metric, 'ascend');
end

% -------------------------------------------------------------------------
% Bisection-like search over the rounding boundary
%
% For the first L variables in the sorted priority list:
%   use floor
% For the remaining variables:
%   use ceil
% -------------------------------------------------------------------------
L_left = 0;
L_right = numel(D_cont);
D_best = ceil(D_cont);

while (L_right - L_left) > 1
    L_mid = floor((L_left + L_right) / 2);
    D_trial = ceil(D_cont);

    for i = 1:L_mid
        idx = priority(i);
        D_trial(idx) = floor(D_cont(idx));
    end

    total_error_trial = compute_total_error_bound(C_vec, D_trial);

    if total_error_trial <= target_error
        D_best = D_trial;
        L_left = L_mid;
    else
        L_right = L_mid;
    end
end

% Check if flooring zero variables is the only feasible candidate
if L_left == 0
    D_best = ceil(D_cont);
end

% Final metrics
total_error = compute_total_error_bound(C_vec, D_best);
D_offset = D_best - E_vec;
total_cost = evaluate_theoretical_cost(E_vec, D_offset);

% -------------------------------------------------------------------------
% Assemble output tables
% -------------------------------------------------------------------------
continuous_table = table( ...
    string(signal_names(:)), ...
    E_vec(:), ...
    D_cont(:), ...
    (D_cont(:) - E_vec(:)), ...
    frac(:), ...
    C_vec(:), ...
    cost_error_metric(:), ...
    'VariableNames', {'Signal','Exponent','WordLengthCont','FracBitsCont','FractionalPart','CValue','CostErrorMetric'});

integer_table = table( ...
    string(signal_names(:)), ...
    E_vec(:), ...
    D_best(:), ...
    D_offset(:), ...
    C_vec(:), ...
    'VariableNames', {'Signal','Exponent','WordLengthInt','FracBitsInt','CValue'});

% Output structure
result = struct();
result.signal_names = signal_names;
result.E_vec = E_vec;
result.C_vec = C_vec;
result.D_cont = D_cont;
result.D_int = D_best;
result.D_offset = D_offset;
result.priority = priority;
result.total_error = total_error;
result.total_cost = total_cost;
result.continuous_table = continuous_table;
result.integer_table = integer_table;
end