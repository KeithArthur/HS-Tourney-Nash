function [V, Q, alpha, beta] = get_V(P)
[m, n] = size(P);
if m == 1
    V = 1 - prod(1-P);
    alpha = 1 ;
    beta = ones(1, n)/n ;
    Q = [];
elseif n == 1
    V = prod(P) ;
    alpha = ones(m, 1)/m;
    beta = 1;
    Q = [];
else
    Q = NaN(m, n) ;
    for i = 1:m
        for j = 1:n
            [Pw, Pl] = deal(P);
            Pw(i, :) = [];
            Pl (:, j) = [];
            Q(i, j) = P(i, j)*get_V(Pw) + (1-P(i, j))*get_V(Pl) ;
        end
    end
    M = Q - .5;
    x = LemkeHowson(M,1 - M) ;
    alpha = x{1};
    beta = x{2};
    V = alpha'*Q*beta;
end