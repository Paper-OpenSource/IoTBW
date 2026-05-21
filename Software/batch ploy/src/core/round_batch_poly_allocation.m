function result = round_batch_poly_allocation(aggregate, profile, cfg)
%ROUND_BATCH_POLY_ALLOCATION Perform cost-aware integer projection for the
% batched polynomial benchmark.
%
% The integer projection stage uses a ranking metric analogous to the
% CostError-style heuristic employed in the original prototype.

D = aggregate.D_continuous;
C = aggregate.C_updated;

% Exponent vector
E = [ ...
    profile.Ex, profile.Ey, profile.Ez, profile.Ek, profile.Ec, ...
    profile.En1, profile.En2, profile.Et1, profile.Et2, profile.Et3, profile.Et4];

target_error = 2^(-cfg.output_fractional_bits - 1);

D_floor = floor(D);
D_ceil = ceil(D);
D_frac = D - D_floor;
D_frac(D_frac == 0) = eps;

% Error contribution induced by flooring
effect = C .* 2.^(-D_floor) .* (1 - 2.^(-D_frac));

% Bit-cost reduction proxy
effect_cost = zeros(1, 11);
effect_cost(1)  = effect(1)  / max(D_frac(1)  * max(D_floor(2), 1), eps);
effect_cost(2)  = effect(2)  / max(D_frac(2)  * max(D_floor(3), 1), eps);
effect_cost(3)  = effect(3)  / max(D_frac(3)  * max(D_floor(4), 1), eps);
effect_cost(4)  = effect(4)  / max(D_frac(4)  * max(D_floor(3), 1), eps);
effect_cost(5)  = effect(5)  / max(D_frac(5), eps);
effect_cost(6)  = effect(6)  / max(D_frac(6)  * max(D_floor(7), 1), eps);
effect_cost(7)  = effect(7)  / max(D_frac(7)  * max(D_floor(6) + profile.Eb, 1), eps);
effect_cost(8)  = effect(8)  / max(D_frac(8)  * max(profile.Ea, 1), eps);
effect_cost(9)  = effect(9)  / max(D_frac(9), eps);
effect_cost(10) = effect(10) / max(D_frac(10), eps);
effect_cost(11) = effect(11) / max(D_frac(11), eps);

if cfg.rounding_search_descending
    [~, priority] = sort(effect_cost, 'descend');
else
    [~, priority] = sort(effect_cost, 'ascend');
end

L_left = 0;
L_right = numel(D);
D_best = D_ceil;

while (L_right - L_left) > 1
    L_mid = floor((L_left + L_right) / 2);
    D_trial = D_ceil;

    for i = 1:L_mid
        idx = priority(i);
        D_trial(idx) = D_floor(idx);
    end

    D_trial_offset = D_trial;
    total_error = evaluate_batch_poly_error_model(D_trial_offset);

    if total_error <= target_error
        D_best = D_trial;
        L_left = L_mid;
    else
        L_right = L_mid;
    end
end

total_error = evaluate_batch_poly_error_model(D_best);
total_cost = evaluate_batch_poly_cost(E, D_best);

result = struct();
result.signal_names = aggregate.names;
result.D_continuous = D;
result.D_integer = D_best;
result.E = E;
result.C = C;
result.effect = effect;
result.effect_cost = effect_cost;
result.priority = priority;
result.total_error = total_error;
result.total_cost = total_cost;
result.target_error = target_error;

result.continuous_table = table( ...
    string(aggregate.names(:)), ...
    D(:), ...
    D_floor(:), ...
    D_frac(:), ...
    C(:), ...
    effect_cost(:), ...
    'VariableNames', {'Signal','WordLengthCont','FloorValue','FractionalPart','CValue','PriorityMetric'});

result.integer_table = table( ...
    string(aggregate.names(:)), ...
    E(:), ...
    D_best(:), ...
    'VariableNames', {'Signal','Exponent','WordLengthInt'});
end