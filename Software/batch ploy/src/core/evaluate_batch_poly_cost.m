function cost = evaluate_batch_poly_cost(E, D)
%EVALUATE_BATCH_POLY_COST Evaluate the theoretical implementation cost for
% the batched polynomial benchmark.
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

cost = 0;

% n1 = x * y
cost = cost + D(1) * D(2);

% n2 = z * k
cost = cost + D(3) * D(4);

% t1 = n1 * n2
cost = cost + D(6) * D(7);

% t2 = b * n2
cost = cost + E(7);

% t3 = a * t1
cost = cost + E(8);

% t4 = t2 + t3
cost = cost + max(E(9), E(10)) + min(D(9), D(10));

% output = t4 + c
cost = cost + max(E(11), E(5)) + min(D(11), D(5));
end