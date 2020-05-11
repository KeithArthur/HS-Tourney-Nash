% VS winrates:
deck = {'Aggro Shaman' , 'Mid-Jade Shaman' , 'Pirate Warrior' , 'Reno Warlock' , 'Miracle Rogue' , 'Reno Mage' , 'Jade Druid'} ;
PP = [0.50 0.51 0.61 0.53 0.61 0.46 0.66
0.49 0.50 0.49 0.43 0.50 0.52 0.56
0.39 0.51 0.50 0.54 0.63 0.43 0.60
0.47 0.57 0.46 0.50 0.40 0.44 0.40
0.39 0.50 0.37 0.60 0.50 0.52 0.59
0.54 0.48 0.57 0.56 0.48 0.50 0.32
0.34 0.44 0.40 0.60 0.41 0.68 0.50] ;
% Example 1 :
A = {'Pirate Warrior' , 'Reno Mage'};
B = {'Mid-Jade Shaman' , 'Reno Warlock'};
P = PP(ismember(deck ,A) , ismember(deck ,B));
[V,Q, alpha , beta ] = get_V(P);
gain = [1, 0]*Q*[1;0] - V;
% Example 2 :
A = {'Pirate Warrior' , 'Reno Mage'};
B = {'Mid-Jade Shaman' , 'Reno Warlock', 'Jade Druid'};
P = PP(ismember(deck ,A) , ismember(deck ,B));
[V,Q, alpha , beta ] = get_V(P) ;
gain = alpha'*Q*[1/3; 1/3; 1/3] - V;
% Example 3 :
decks = length(deck);
N = nchoosek(decks, 3);
lineups = NaN(N, 3); 
n = 0;
for j1 = 1:decks-2
    for j2 = j1 + 1:decks-1
        for j3 = j2 + 1:decks
            js = [j1, j2, j3];
            n = n + 1;
            lineups(n, :) = js;
        end
    end
end

score = zeros(N, N);g
for j = 1:N
    for k = j:N
        ia = lineups(j, :);
        ib = lineups(k, :);
        P = PP(ia, ib);
        [V, Q, alpha, beta] = get_V(P);
        score(j, k) = V;
    end
end
score  = score + tril(1 - score', -1);

[j, k] = find(score == max(max(score))) ;
deck(lineups(j, :))
deck(lineups(k, :))
% Example 4 :
A = {'Aggro Shaman', 'Pirate Warrior', 'Reno Warlock', 'Miracle Rogue'};
B = {'Mid-Jade Shaman' , 'Reno Warlock', 'Reno Mage', 'Jade Druid'};
P = PP(ismember(deck ,A) , ismember(deck ,B));
[V, S, alpha, beta] = get_V_ban(P) ;
alpha'*S*[0, 1, 0, 0]'; % ban Warrior
alpha'*S*[0, 0, 1, 0]' - V; % ban Warlock