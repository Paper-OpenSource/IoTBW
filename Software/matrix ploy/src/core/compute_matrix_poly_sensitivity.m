function sens = compute_matrix_poly_sensitivity(data, range_data)

Npath = data.Npath;

% Reverse-mode sensitivity seeds
k1_d = 1;
c1_d = 1;

% Reverse propagation through k1 = h1*g1 + h2*g2
h1_d = data.g1;
h2_d = data.g2;
g1_d = data.h1;
g2_d = data.h2;

% Reverse propagation through g1 = f1 + e1 and g2 = f2 + e2
f1_d = h1_d;
f2_d = h2_d;
e1_d = h1_d;
e2_d = h2_d;

% Reverse propagation through e1 = z1*d1 + z2*d2 and e2 = z3*d1 + z4*d2
z1_d = data.d1 .* e1_d;
z2_d = data.d2 .* e1_d;
z3_d = data.d1 .* e2_d;
z4_d = data.d2 .* e2_d;

d1_d = data.z1 .* e1_d + data.z3 .* e2_d;
d2_d = data.z2 .* e1_d + data.z4 .* e2_d;

% Reverse propagation through z1, z2, z3, z4
y1_d = data.x1 .* z1_d + data.x2 .* z3_d;
y2_d = data.x1 .* z2_d + data.x2 .* z4_d;

x1_d = data.y1 .* z1_d + data.y2 .* z2_d;
x2_d = data.y1 .* z3_d + data.y2 .* z4_d;

% Reverse propagation through c1 = a1*b1 + a2*b2
b1_d = data.a1;
b2_d = data.a2;
a1_d = data.b1;
a2_d = data.b2;

sens = struct();

sens.Cd1 = 0;
sens.Cd2 = 0;
sens.Ch1 = 0;
sens.Ch2 = 0;
sens.Cy1 = 0;
sens.Cy2 = 0;
sens.Cb1 = 0;
sens.Cb2 = 0;

for i = 1:Npath
    sens.Cd1 = 2^(range_data.Ed1 - 1) * abs(d1_d(i)) / Npath + sens.Cd1;
    sens.Cd2 = 2^(range_data.Ed2 - 1) * abs(d2_d(i)) / Npath + sens.Cd2;
    sens.Ch1 = 2^(range_data.Eh1 - 1) * abs(h1_d(i)) / Npath + sens.Ch1;
    sens.Ch2 = 2^(range_data.Eh2 - 1) * abs(h2_d(i)) / Npath + sens.Ch2;
    sens.Cy1 = 2^(range_data.Ey1 - 1) * abs(y1_d(i)) / Npath + sens.Cy1;
    sens.Cy2 = 2^(range_data.Ey2 - 1) * abs(y2_d(i)) / Npath + sens.Cy2;
    sens.Cb1 = 2^(range_data.Eb1 - 1) * abs(b1_d(i)) / Npath + sens.Cb1;
    sens.Cb2 = 2^(range_data.Eb2 - 1) * abs(b2_d(i)) / Npath + sens.Cb2;
end

sens.Cx1 = mean(2^(range_data.Ex1 - 1) * abs(x1_d));
sens.Cx2 = mean(2^(range_data.Ex2 - 1) * abs(x2_d));
sens.Cz1 = mean(2^(range_data.Ez1 - 1) * abs(z1_d));
sens.Cz2 = mean(2^(range_data.Ez2 - 1) * abs(z2_d));
sens.Cz3 = mean(2^(range_data.Ez3 - 1) * abs(z3_d));
sens.Cz4 = mean(2^(range_data.Ez4 - 1) * abs(z4_d));
sens.Ce1 = mean(2^(range_data.Ee1 - 1) * abs(e1_d));
sens.Ce2 = mean(2^(range_data.Ee2 - 1) * abs(e2_d));
sens.Cf1 = mean(2^(range_data.Ef1 - 1) * abs(f1_d));
sens.Cf2 = mean(2^(range_data.Ef2 - 1) * abs(f2_d));
sens.Cg1 = mean(2^(range_data.Eg1 - 1) * abs(g1_d));
sens.Cg2 = mean(2^(range_data.Eg2 - 1) * abs(g2_d));
sens.Ca1 = mean(2^(range_data.Ea1 - 1) * abs(a1_d));
sens.Ca2 = mean(2^(range_data.Ea2 - 1) * abs(a2_d));
sens.Cc1 = 2^(range_data.Ec1 - 1) * abs(c1_d);
sens.Ck1 = 2^(range_data.Ek1 - 1) * abs(k1_d);
end