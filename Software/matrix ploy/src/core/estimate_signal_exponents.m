function range_data = estimate_signal_exponents(data)
%ESTIMATE_SIGNAL_EXPONENTS Estimate integer bit-width exponents from
% dynamic range profiling.
%
% For each signal x, the exponent e is estimated as:
%   e = ceil(log2(max(abs(x))))
%
% This function separates range profiling from optimization, which makes
% the research code easier to inspect and reuse.

range_data = struct();

% Signals represented by Monte Carlo samples
range_data.Ex1 = max(compute_exponent(data.x1));
range_data.Ex2 = max(compute_exponent(data.x2));
range_data.Ez1 = max(compute_exponent(data.z1));
range_data.Ez2 = max(compute_exponent(data.z2));
range_data.Ez3 = max(compute_exponent(data.z3));
range_data.Ez4 = max(compute_exponent(data.z4));
range_data.Ee1 = max(compute_exponent(data.e1));
range_data.Ee2 = max(compute_exponent(data.e2));
range_data.Eg1 = max(compute_exponent(data.g1));
range_data.Eg2 = max(compute_exponent(data.g2));
range_data.Ek1 = max(compute_exponent(data.k1));
range_data.Ea1 = max(compute_exponent(data.a1));
range_data.Ea2 = max(compute_exponent(data.a2));
range_data.Ec1 = max(compute_exponent(data.c1));
range_data.Eo  = max(compute_exponent(data.o));

% Scalar constants
range_data.Ey1 = max(compute_exponent(data.y1));
range_data.Ey2 = max(compute_exponent(data.y2));
range_data.Ed1 = max(compute_exponent(data.d1));
range_data.Ed2 = max(compute_exponent(data.d2));
range_data.Ef1 = max(compute_exponent(data.f1));
range_data.Ef2 = max(compute_exponent(data.f2));
range_data.Eh1 = max(compute_exponent(data.h1));
range_data.Eh2 = max(compute_exponent(data.h2));
range_data.Eb1 = max(compute_exponent(data.b1));
range_data.Eb2 = max(compute_exponent(data.b2));
end

function e = compute_exponent(x)
%COMPUTE_EXPONENT Compute elementwise exponent estimate.
%
% Zeros are replaced by eps to avoid -Inf caused by log2(0).

x_abs = abs(x);
x_abs(x_abs == 0) = eps;
e = ceil(log2(x_abs));
end