function case_data = build_batch_poly_case(cfg)
%BUILD_BATCH_POLY_CASE Construct the batched polynomial benchmark.
%
% Computational graph:
%   n1 = x .* y
%   n2 = z .* k
%   t1 = n1 .* n2
%   t2 = b * n2
%   t3 = a * t1
%   t4 = t2 + t3
%   out = t4 + c
%
% The first batch is typically used as the coarse-grained dynamic profiling
% batch, while the subsequent batches are smaller refinement batches.

batch_sizes = cfg.batch_sizes;
num_batches = numel(batch_sizes);

case_data = struct();
case_data.num_batches = num_batches;
case_data.batch_sizes = batch_sizes;

% Constant coefficients
case_data.a = 3;
case_data.b = 1;
case_data.c = 115.8762;

% Preallocate batch container
case_data.batches = cell(1, num_batches);

for i = 1:num_batches
    Ni = batch_sizes(i);

    batch = struct();
    batch.x = rand(1, Ni) * 15;
    batch.y = rand(1, Ni) * 15;
    batch.z = rand(1, Ni) * 15;
    batch.k = rand(1, Ni) * 15;

    batch.n1 = batch.x .* batch.y;
    batch.n2 = batch.z .* batch.k;
    batch.t1 = batch.n1 .* batch.n2;
    batch.t2 = case_data.b * batch.n2;
    batch.t3 = case_data.a * batch.t1;
    batch.t4 = batch.t2 + batch.t3;
    batch.output = batch.t4 + case_data.c;

    case_data.batches{i} = batch;
end
end