function [ output_args ] = execute_contrasts(F)
%This function compute the contrast of interest at the first level.
%
full_reg_array = [];
base_str = 'spm_spm:beta (0000) - Sn(0) ';
C.hrf_str = '*bf(1)';
for s = 1:length(F.subjnames)
    load(strcat(F.firstlevpath, F.subjnames{s}, '/SPM.mat'));
    C.subj_array{s} = [];
    for b = 1:length(SPM.Vbeta)
        full_reg_array = [full_reg_array;{SPM.Vbeta(b).descrip(length(base_str)+1:end)}];
        C.subj_array{s} = [C.subj_array{s};{SPM.Vbeta(b).descrip(1:end)}];
    end
end
C.regressor_list = cellstr(unique(full_reg_array));
keep = [];
for c = 1:length(C.regressor_list)
    if ~isempty(strfind(C.regressor_list{c}, C.hrf_str))
        keep(end+1) = c;
    end
end
C.regressor_list = C.regressor_list(keep);

for s = 1:length(F.subjnames)
    load(strcat(F.firstlevpath, F.subjnames{s}, '/SPM.mat'));
 
    cc = 0;
    
    for c = 1:length(C.regressor_list) 
        C.beta_id{s}{c} = [];
        C.beta_files{s}{c} = [];
        C.beta_run{s}{c} = [];
        for b = 1:length(C.subj_array{s})
            if ~isempty(strfind(C.subj_array{s}{b}, C.regressor_list{c}));
                C.beta_id{s}{c} = [C.beta_id{s}{c}; b];
                C.beta_files{s}{c} = [C.beta_files{s}{c}; {[F.firstlevpath F.subjnames{s} '/beta_' sprintf('%04i',b) '.nii']}];
                C.beta_run{s}{c} = [C.beta_run{s}{c}; str2num(C.subj_array{s}{b}(26))];
            end
        end
        
        if ~isempty(C.beta_id{s}{c})
            cc = cc +1;
            matlabbatch{s}.spm.stats.con.consess{cc}.tcon.name = C.regressor_list{c};
            matlabbatch{s}.spm.stats.con.consess{cc}.tcon.convec = zeros(1,length(SPM.Vbeta));
            matlabbatch{s}.spm.stats.con.consess{cc}.tcon.convec(C.beta_id{s}{c}) = 1;
            matlabbatch{s}.spm.stats.con.consess{cc}.tcon.sessrep = 'none';
            C.con_id{s,c} = sprintf('con_%0.4d.nii',cc);
            C.con_name{s,c} = C.regressor_list{c};
        else
            C.con_id{s,c} = [];
            C.con_name{s,c} = C.regressor_list{c};            
        end    
    end
    
    matlabbatch{s}.spm.stats.con.spmmat = {strcat(F.firstlevpath, F.subjnames{s}, '/SPM.mat')};
    matlabbatch{s}.spm.stats.con.delete = 1;
    
end

% matlabbatch{1} = matlabbatch{4}
% matlabbatch(2:end) = [];
save([F.firstlevpath 'C.mat'], 'C');

% launch_job
spm('defaults', 'FMRI');
spm_jobman('serial',matlabbatch);


