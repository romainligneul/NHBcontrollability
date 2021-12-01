function sumbycond = sumbycond(data, cond, filter)
% require unidimensionnal data and cond vectors of same length
% and eventually a filter rule:
% - filter alone must be a logical 0/1 array. It will keep only the
% data where filter == 1.
% remark, meanbycond are ordered by ascending order of cond numbers/letters

if ~isempty(filter)
    data = data(filter);
    cond = cond(filter);
end

condtype = unique(cond);
condtype = sort(condtype);
for c = 1:length(condtype)
    sumbycond(1,c) = sum(data(cond == condtype(c)));
end;

end

