function data = build_matrix_poly_case(Npath)
%BUILD_MATRIX_POLY_CASE Construct the benchmark instance used in the matrix
% polynomial style case study.
%
% Input:
%   Npath : number of Monte Carlo samples used for dynamic profiling
%
% Output:
%   data  : structure containing all primary inputs, constants, and
%           intermediate forward signals
%
% This function follows the computational graph used in the original
% research script while packaging it in a self-contained and reusable form.

data = struct();
data.Npath = Npath;

% -------------------------------------------------------------------------
% Random primary inputs
% -------------------------------------------------------------------------
data.x1 = rand(1, Npath) * 2;
data.x2 = rand(1, Npath) * 2;

data.a1 = rand(1, Npath) * 2;
data.a2 = rand(1, Npath) * 2;

% -------------------------------------------------------------------------
% Constant coefficients
% -------------------------------------------------------------------------
data.y1 = 2.234;
data.y2 = 2.111;
data.d1 = 6.452;
data.d2 = 4.898;
data.f1 = 2.031;
data.f2 = 4.796;
data.h1 = 2.098;
data.h2 = 1.145;
data.b1 = 2.456;
data.b2 = 1.087;

% -------------------------------------------------------------------------
% Forward evaluation of the benchmark graph
% -------------------------------------------------------------------------
data.z1 = data.x1 * data.y1;
data.z2 = data.x1 * data.y2;
data.z3 = data.x2 * data.y1;
data.z4 = data.x2 * data.y2;

data.e1 = data.z1 * data.d1 + data.z2 * data.d2;
data.e2 = data.z3 * data.d1 + data.z4 * data.d2;

data.g1 = data.f1 + data.e1;
data.g2 = data.f2 + data.e2;

data.k1 = data.h1 * data.g1 + data.h2 * data.g2;
data.c1 = data.a1 * data.b1 + data.a2 * data.b2;

data.o = data.k1 + data.c1;
end