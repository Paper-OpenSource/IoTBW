function error_value = evaluate_batch_poly_error_model(D)
%EVALUATE_BATCH_POLY_ERROR_MODEL Evaluate the explicit first-order / mixed
% error model used in the original batch prototype.
%
% Signal order:
%   1  x
%   2  y
%   3  z
%   4  k
%   5  c
%   6  n1
%   7  n2
%   8  t1
%   9  t2
%   10 t3
%   11 t4

a = 3;
b = 1;

delta_x  = 2^(-D(1)  - 1);
delta_y  = 2^(-D(2)  - 1);
delta_z  = 2^(-D(3)  - 1);
delta_k  = 2^(-D(4)  - 1);
delta_c  = 2^(-D(5)  - 1);
delta_n1 = 2^(-D(6)  - 1);
delta_n2 = 2^(-D(7)  - 1);
delta_t1 = 2^(-D(8)  - 1);
delta_t2 = 2^(-D(9)  - 1);
delta_t3 = 2^(-D(10) - 1);
delta_t4 = 2^(-D(11) - 1);

error_n1 = 15 * delta_x + 15 * delta_y + delta_x * delta_y + delta_n1;
error_n2 = 15 * delta_z + 15 * delta_k + delta_z * delta_k + delta_n2;
error_t1 = 225 * error_n1 + 255 * error_n2 + error_n1 * error_n2 + delta_t1;
error_t2 = b * error_n2 + delta_t2;
error_t3 = a * error_t1 + delta_t3;
error_t4 = error_t2 + error_t3 + delta_t4;
error_value = delta_c + error_t4;
end