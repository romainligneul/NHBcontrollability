function [ snext smax ] = make_transition( T, cond, noise, scurrent, subcond)
%TRANSITIONS based on a structure containing the different transition
% matrices as well as the current state and current subcond, determine the
% next state using a probabilistic method and return also the most likely
% next state, even if not realized
% INPUT:
% - T an input structure with substructures containing {M}(N by N} matrices
% with M = number of subconds and N = possible current (row) and future
% (columns) states. Each matrice is under the string form to be evaluated
% based on the "noise" parameter.
% - cond: an index of the condition. Determines with T{cond} substructure
% should be used.
% - noise: the amount of noise in the transition matrices.
% - scurrent: current state.
% - subcond: current subcond.

% eval matrice - noise management
if ~isempty(subcond)
    Ts = eval(T{cond}{subcond});
else
    Ts = eval(T{cond}{subcond});
end
% get state appropriate row.
activeT = Ts(scurrent,:);

% compute the transition;
Tcum = cumsum(activeT);
alea = rand;
if alea<Tcum(1)
    snext = 1;
elseif alea<Tcum(2)
    snext = 2;
else
    snext = 3;
end;

smax = find(activeT==max(activeT));

end

