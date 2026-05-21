function batch_solution = solve_batch_fractional_widths_lm(profile, cfg)
%SOLVE_BATCH_FRACTIONAL_WIDTHS_LM Solve the continuous bit-width allocation
% problem independently for each batch using a Lagrangian formulation.
%
% Output:
%   batch_solution : structure containing the continuous solutions for all
%                    batches and the raw symbolic solver outputs.

num_batches = numel(profile.Cx);
dout = cfg.output_fractional_bits;

batch_solution = struct();
batch_solution.raw = cell(1, num_batches);

batch_solution.x  = zeros(1, num_batches);
batch_solution.y  = zeros(1, num_batches);
batch_solution.z  = zeros(1, num_batches);
batch_solution.k  = zeros(1, num_batches);
batch_solution.c  = zeros(1, num_batches);
batch_solution.n1 = zeros(1, num_batches);
batch_solution.n2 = zeros(1, num_batches);
batch_solution.t1 = zeros(1, num_batches);
batch_solution.t2 = zeros(1, num_batches);
batch_solution.t3 = zeros(1, num_batches);
batch_solution.t4 = zeros(1, num_batches);

tic;

for i = 1:num_batches
    initial = ones(1, 11) * cfg.vpasolve_initial_value;
    initial(12) = cfg.vpasolve_lambda_init;

    syms dx dy dz dk dc dn1 dn2 dt1 dt2 dt3 dt4 lamd

    eqn1  = dy      == lamd * log(2) * 2^(-dx)  * profile.Cx(i);
    eqn2  = dx      == lamd * log(2) * 2^(-dy)  * profile.Cy(i);
    eqn3  = dk      == lamd * log(2) * 2^(-dz)  * profile.Cz(i);
    eqn4  = dz      == lamd * log(2) * 2^(-dk)  * profile.Ck(i);
    eqn5  = dn2     == lamd * log(2) * 2^(-dn1) * profile.Cn1(i);
    eqn6  = dn1 + profile.Eb == lamd * log(2) * 2^(-dn2) * profile.Cn2(i);
    eqn7  = profile.Ea == lamd * log(2) * 2^(-dt1) * profile.Ct1(i);
    eqn8  = 1       == lamd * log(2) * 2^(-dt2) * profile.Ct2(i);
    eqn9  = 1       == lamd * log(2) * 2^(-dt3) * profile.Ct3(i);
    eqn10 = 1       == lamd * log(2) * 2^(-dt4) * profile.Ct4(i);
    eqn11 = 1       == lamd * log(2) * 2^(-dc)  * profile.Cc(i);

    eqn12 = ...
        2^(-dx)  * profile.Cx(i)  + ...
        2^(-dy)  * profile.Cy(i)  + ...
        2^(-dz)  * profile.Cz(i)  + ...
        2^(-dk)  * profile.Ck(i)  + ...
        2^(-dn1) * profile.Cn1(i) + ...
        2^(-dn2) * profile.Cn2(i) + ...
        2^(-dt1) * profile.Ct1(i) + ...
        2^(-dt2) * profile.Ct2(i) + ...
        2^(-dt3) * profile.Ct3(i) + ...
        2^(-dt4) * profile.Ct4(i) + ...
        2^(-dc)  * profile.Cc(i) == 2^(-dout - 1);

    vars = [dx, dy, dz, dk, dc, dn1, dn2, dt1, dt2, dt3, dt4, lamd];

    sol = vpasolve( ...
        [eqn1, eqn2, eqn3, eqn4, eqn5, eqn6, eqn7, eqn8, eqn9, eqn10, eqn11, eqn12], ...
        vars, ...
        initial);

    batch_solution.raw{i} = sol;

    batch_solution.x(i)  = double(sol.dx);
    batch_solution.y(i)  = double(sol.dy);
    batch_solution.z(i)  = double(sol.dz);
    batch_solution.k(i)  = double(sol.dk);
    batch_solution.c(i)  = double(sol.dc);
    batch_solution.n1(i) = double(sol.dn1);
    batch_solution.n2(i) = double(sol.dn2);
    batch_solution.t1(i) = double(sol.dt1);
    batch_solution.t2(i) = double(sol.dt2);
    batch_solution.t3(i) = double(sol.dt3);
    batch_solution.t4(i) = double(sol.dt4);
end

batch_solution.elapsed_time = toc;
end