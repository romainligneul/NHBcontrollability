function sumbycond = sumbycond(data, cond, filter)
% produces output arranged as [c1(1)c2(1) c1(1)c2(2)  c2(1)c2(1) c2(1)c2(2)]. 
% require unidimensionnal data and cond vectors of same length
% and eventually a filter rule:
% - filter alone must be a logical 0/1 array. It will keep only the
% data where filter == 1.
% remark, meanbycond are ordered by ascending order of cond numbers/letters
% the cond data must be arranged in column vectors of conditions
% note: data is prearrange with cond{1} as first factor in usuals repeated
% measures software

if ~isempty(filter)
    data = data(filter);
    cond = cond(filter,:);
end

condtype{1} = unique(cond(:,1));
condtype{1} = sort(condtype{1});
condtype{2} = unique(cond(:,2));
condtype{2} = sort(condtype{2});
c = 1;

for c1 = 1:length(condtype{1})
    for c2 = 1:length(condtype{2})
        sumbycond(1,c) = sum(data(cond(:,1) == condtype{1}(c1) & cond(:,2) == condtype{2}(c2)));
        c = c +1;
    end;
end;

end

