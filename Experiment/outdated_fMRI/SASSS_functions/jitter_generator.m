function total_jit = jitter_generator(ntrials, ncond, target_mean, jitrange)
% this script generates exponentially distributed jitters

%ntrials = 1600;
smallest_jit = jitrange(1);
discrete_values = jitrange-jitrange(1);

tmp_dist = exppdf(discrete_values, target_mean-smallest_jit);
dist = tmp_dist;
total_jit = [];

for c = 1:ncond%length(cond);
    t = 1;
    %fid = fopen(['jit2_' cond{c} '_' num2str(s) '.txt'], 'w', 'n', 'UTF-8');
    while t <= ntrials
        tir = rand();
        for i = 1:length(dist)-1;
            if tir < dist(end-i)
                jit(t) = discrete_values(end-i) + smallest_jit;
                %fprintf(fid, '%3.1f\n', jit(t));
                t = t+1;
                break
            end;
        end;
    end;
    jit = jit-(mean(jit)-target_mean);
    total_jit = [total_jit; jit];
    % fclose(fid);
end;

%hist(total_jit'/2);