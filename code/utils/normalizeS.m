function [S,a,t] = normalizeS(S)

t = mean(S,2);%mean vector
S = S - t*ones(1,size(S,2)); % substracting mean vector
a = mean(std(S, 1, 2));
S = S / a;
