function [ tablebycond condtype condind] = buildtable( data, cond0, filter )
%BUILDTABLE Summary of this function goes here
%   Detailed explanation goes here
% require unidimensionnal data and cond vectors of same length
% and eventually a filter rule:
% - filter alone must be a logical 0/1 array. It will keep only the
% data where filter == 1.
% remark, meanbycond are ordered by ascending order of cond numbers/letters

condtype = unique(cond0);

if ~isempty(filter)
    data = data(filter);
    cond0 = cond0(filter);
end

condtype = sort(condtype);
condind = zeros(length(condtype),1);

% build nan table
for d = 1:length(data)
    for c = 1:length(condtype)
        
        if cond0(d) == condtype(c)
            condind(c) = condind(c)+1;
        end;
    end
end
rows = max(condind);
tablebycond = nan(rows, length(condtype));

condind = zeros(length(condtype),1);

for d = 1:length(data)
    
    for c = 1:length(condtype)
        if cond0(d) == condtype(c)
           condind(c) = condind(c)+1;
           tablebycond(condind(c), c) = data(d);
        end;
    end
end

end

