function profile = profile_batch_poly_sensitivity(case_data)
%PROFILE_BATCH_POLY_SENSITIVITY Estimate dynamic exponents and first-order
% error coefficients for each batch.
%
% The implementation follows the reverse-mode sensitivity structure of the
% original prototype and uses per-batch Monte Carlo averaging to estimate
% the coefficients employed in the first-order error model.

num_batches = case_data.num_batches;
batches = case_data.batches;

profile = struct();

% -------------------------------------------------------------------------
% Exponent profiling
% Global exponents are derived from the primary batch to preserve the style
% of the original prototype.
% -------------------------------------------------------------------------
primary = batches{1};

profile.Ex = 4;
profile.Ey = 4;
profile.Ez = 4;
profile.Ek = 4;

profile.Ea = max(compute_local_exponent(case_data.a));
profile.Eb = max(compute_local_exponent(case_data.b));
profile.Ec = max(compute_local_exponent(case_data.c));
profile.En1 = max(compute_local_exponent(primary.n1));
profile.En2 = max(compute_local_exponent(primary.n2));
profile.Et1 = max(compute_local_exponent(primary.t1));
profile.Et2 = max(compute_local_exponent(primary.t2));
profile.Et3 = max(compute_local_exponent(primary.t3));
profile.Et4 = max(compute_local_exponent(primary.t4));

% -------------------------------------------------------------------------
% Per-batch coefficient estimation
% -------------------------------------------------------------------------
profile.Cx  = zeros(1, num_batches);
profile.Cy  = zeros(1, num_batches);
profile.Cz  = zeros(1, num_batches);
profile.Ck  = zeros(1, num_batches);
profile.Cc  = zeros(1, num_batches);
profile.Cn1 = zeros(1, num_batches);
profile.Cn2 = zeros(1, num_batches);
profile.Ct1 = zeros(1, num_batches);
profile.Ct2 = zeros(1, num_batches);
profile.Ct3 = zeros(1, num_batches);
profile.Ct4 = zeros(1, num_batches);

for i = 1:num_batches
    batch = batches{i};
    Ni = case_data.batch_sizes(i);

    % Reverse-mode sensitivities
    t4_d = 1;
    c_d  = 1;
    t3_d = 1;
    t2_d = 1;
    a_d  = batch.t1;
    t1_d = case_data.a;
    n1_d = batch.n2 * case_data.a;
    n2_d = batch.n1 * case_data.a + case_data.b;
    x_d  = batch.y .* batch.n2 * case_data.a;
    y_d  = batch.x .* batch.n2 * case_data.a;
    z_d  = batch.k .* batch.n1 * case_data.a + batch.k * case_data.b;
    k_d  = batch.z .* batch.n1 * case_data.a + batch.z * case_data.b;

    for j = 1:Ni
        profile.Cx(i)  = 2^(profile.Ex  - 1) * abs(x_d(j))  / Ni + profile.Cx(i);
        profile.Cy(i)  = 2^(profile.Ey  - 1) * abs(y_d(j))  / Ni + profile.Cy(i);
        profile.Cz(i)  = 2^(profile.Ez  - 1) * abs(z_d(j))  / Ni + profile.Cz(i);
        profile.Ck(i)  = 2^(profile.Ek  - 1) * abs(k_d(j))  / Ni + profile.Ck(i);
        profile.Cc(i)  = 2^(profile.Ec  - 1) * abs(c_d)     / Ni + profile.Cc(i);
        profile.Cn1(i) = 2^(profile.En1 - 1) * abs(n1_d(j)) / Ni + profile.Cn1(i);
        profile.Cn2(i) = 2^(profile.En2 - 1) * abs(n2_d(j)) / Ni + profile.Cn2(i);
        profile.Ct1(i) = 2^(profile.Et1 - 1) * abs(t1_d)    / Ni + profile.Ct1(i);
        profile.Ct2(i) = 2^(profile.Et2 - 1) * abs(t2_d)    / Ni + profile.Ct2(i);
        profile.Ct3(i) = 2^(profile.Et3 - 1) * abs(t3_d)    / Ni + profile.Ct3(i);
        profile.Ct4(i) = 2^(profile.Et4 - 1) * abs(t4_d)    / Ni + profile.Ct4(i);
    end
end
end

function e = compute_local_exponent(x)
x_abs = abs(x);
x_abs(x_abs == 0) = eps;
e = ceil(log2(x_abs));
end