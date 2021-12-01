E.noise = [0.05 0.1 0.2]
ss= 0;
for streak = 1:1000
    ss = ss+1;
    state(1) = randi(3);
    for t=1:5
        
        [state(t+1) expected] = make_transition(E.T, 1, E.noise, state(t), randi(3));
        
        viol(t) = double(state(t+1)~=expected);
    end;
    
    violmean(ss,1) =  sum(viol)>=1;
    
end
mean(violmean)