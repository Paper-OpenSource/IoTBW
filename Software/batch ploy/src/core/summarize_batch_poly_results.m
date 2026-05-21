function summarize_batch_poly_results(result, profile, cfg)
%SUMMARIZE_BATCH_POLY_RESULTS Print a compact report for the batch demo.

fprintf('\n');
fprintf('---------------- Batch optimization summary ----------------\n');
fprintf('Global exponent profile:\n');
fprintf('  Ex=%d, Ey=%d, Ez=%d, Ek=%d, Ec=%d, En1=%d, En2=%d, Et1=%d, Et2=%d, Et3=%d, Et4=%d\n', ...
    profile.Ex, profile.Ey, profile.Ez, profile.Ek, profile.Ec, ...
    profile.En1, profile.En2, profile.Et1, profile.Et2, profile.Et3, profile.Et4);

fprintf('\n');
fprintf('Continuous allocation:\n');
disp(result.continuous_table);

fprintf('Integer allocation:\n');
disp(result.integer_table);

fprintf('Final theoretical cost        : %.6f\n', result.total_cost);
fprintf('Estimated output error        : %.6e\n', result.total_error);
fprintf('Target output error bound     : %.6e\n', result.target_error);
fprintf('Constraint satisfied          : %s\n', string(result.total_error <= result.target_error));

fprintf('\n');
fprintf('Signal ranking order for integer projection:\n');
disp(string(result.signal_names(result.priority)));
end