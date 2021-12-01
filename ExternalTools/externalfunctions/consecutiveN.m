function [ seg_ind seg_length seg_values seg_ahead] = consecutiveN( x )
%CONSECUTIVEN Obtain indices corresponding to a change in value (seg_ind),
% the length of the series of consecutive identical values for these
% indices, the values at each starting indice, and a vector reporting the
% number of consecutive identical values left ahead for each point in x.

  i = find(diff(x));
  n = [i numel(x)] - [0 i];
  c = arrayfun(@(X) X-1:-1:0, n , 'un',0);
  seg_ahead = cat(2,c{:});
  seg_ind = [1 i+1];
  seg_length = cellfun(@numel,c);
  seg_values = x(seg_ind);
end

