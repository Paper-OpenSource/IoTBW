function total_error = compute_total_error_bound(C_vec, D_vec)
%COMPUTE_TOTAL_ERROR_BOUND Evaluate the first-order global output error
% bound used in the optimization framework.
%
% Input:
%   C_vec : vector of first-order coefficients
%   D_vec : vector of total word lengths
%
% Output:
%   total_error : estimated sum of first-order error contributions

total_error = sum(C_vec .* 2.^(-D_vec));
end