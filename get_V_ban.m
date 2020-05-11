function [V, S, alpha, beta] = get_V_ban(P)
assert (size(P, 1) == size(P, 2))
n = size(P, 1);
S = NaN(n, n);
for i = 1 : n
    for j = 1 : n
        R = P;
        R(:, i) = []; % ban Bi
        R(j, :) = []; % ban Aj
        S(i, j) = get_V(R);
    end
end
M = S - 0.5;
x = LemkeHowson(M, 1-M);
alpha = x{1};
beta = x{2};
V = alpha'*S*beta;
