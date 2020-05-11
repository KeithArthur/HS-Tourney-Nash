%This code will find the equilibrium strategy for conquest lineups. Credit 
%to svangen#2391 for his code finding the optimal queueing strategy, and 
%Richard M. Katzwer for his Lemke Howson function. 

deck = {'I Aggro DH ', 'D Spell Druid ', 'H Face Hunter ', 'M Highlander Mage ' ...
    'P Murloc Paladin ', 'A Galakrond Priest ', 'W Zoo Warlock ', 'G Enrage Warrior '... 
    'H Dragon Hunter ', 'H Highlander Hunter ', 'A Highlander Priest ', 'R Galakrond Rogue '...
    'S Totem Shaman '};
%VS Winrates
PP = [
.5  .579 .502 .589 .627 .538 .567 .375 .509 .554 .520 .512 .702
0   .500 .563 .481 .338 .405 .453 .444 .557 .509 .406 .565 .324
0   0    .5   .641 .378 .386 .533 .334 .412 .512 .356 .534 .365
0   0    0    .5   .635 .543 .494 .529 .398 .409 .546 .481 .544
0   0    0    0    .5   .535 .500 .226 .683 .522 .457 .481 .603
0   0    0    0    0    .5   .448 .631 .410 .307 .492 .345 .359
0   0    0    0    0    0    .5   .409 .529 .604 .543 .585 .617
0   0    0    0    0    0    0    .5   .574 .500 .355 .563 .691
0   0    0    0    0    0    0    0    .5   .528 .493 .489 .455
0   0    0    0    0    0    0    0    0    .5   .626 .507 .614
0   0    0    0    0    0    0    0    0    0    .5   .355 .407
0   0    0    0    0    0    0    0    0    0    0    .5   .625
0   0    0    0    0    0    0    0    0    0    0    0    .5];

PP = PP + tril(1 - PP', -1);

decks = length(deck);
N = nchoosek(decks, 3);
lineups = NaN(N, 3); 
n = 0;

%All valid lineups, with max one of each class
for j1 = 1:decks-2
    for j2 = j1 + 1:decks-1
        for j3 = j2 + 1:decks
            js = [j1, j2, j3];
            d1 = deck{j1};
            d2 = deck{j2};
            d3 = deck{j3};
            if and(and(d1(1) ~= d2(1), d1(1) ~= d3(1)), d2(1) ~= d3(1))
                n = n + 1;
                lineups(n, :) = js;
            end
        end
    end
end
lineups = lineups(1:n, :);

N = n;
score = zeros(N, N);
%Find the winrate of each matchup
for j = 1:N
    disp(strcat('Progress: ', num2str(j/N)))
    for k = j:N
        ia = lineups(j, :);
        ib = lineups(k, :);
        P = PP(ia, ib);
        [V, Q, alpha, beta] = get_V_ban(P);
        score(j, k) = V;
    end
end
score  = score + tril(1 - score', -1);

%Use the matchup matrix to fine the Nash Equilibrium for lineups
x = LemkeHowson(score, 1 - score);
strat = x{1};
disp('Nash Equilibrium:')

while sum(strat) > 0
    top = find(max(strat) == strat);
    disp(strcat(deck(lineups(top, 1)), ' ', deck(lineups(top, 2)), ' ', deck(lineups(top, 3)), ' with playrate: ', num2str(strat(top))))
    strat(top) = 0;
end

strat = x{2};
%Find exploitative strats for single decks
while sum(strat) > 0
    top = find(max(strat) == strat);
    rate = strat(top);
    strat(top) = 0;
    ex_score = min(score(top, :));
    exploit = find(ex_score == score(top, :));
    disp('Next: ')
    for i = 1:length(exploit)
        pick = exploit(i);
        ia = lineups(top, :);
        ib = lineups(pick, :);
        P = PP(ia, ib);
        [V, Q, alpha, beta] = get_V_ban(P);
        disp(strcat(deck(ia(1)), ' ', deck(ia(2)), ' ', deck(ia(3)), 'is exploited by: '))
        disp(strcat(deck(ib(1)), ' ', deck(ib(2)), ' ', deck(ib(3)), 'with winrate: ', num2str(1-ex_score)))
        disp(strcat('Ban his: ', deck(ia(find(beta>.5))), 'he should ban: ', deck(ib(find(alpha>.5)))))
    end
end