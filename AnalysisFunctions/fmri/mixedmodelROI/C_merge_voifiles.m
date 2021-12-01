clear all

folder1 = 'schaeffer_sig_networks/';
rois1 = 1:8;

folder2 = 'p001_std5_all_96_eig/';
rois2 = 4;

output_folder = 'schaeffer_sig_networks_rTPJ/';
mkdir(output_folder)

for s=1:32
    add2 = load([folder1 sprintf('V%0.2i.mat', s)]);   
    load([folder1 sprintf('V%0.2i.mat', s)]);
    
    for ses=1:4
        
        V{ses}.trial_data(:,end+1:end+numel(rois2),:) = add2.V{ses}.trial_data(:,rois2,:);
        V{ses}.concat_brain(:,end+1:end+numel(rois2)) = add2.V{ses}.concat_brain(:,rois2);
        V{ses}.concat_brain(:,end+1:end+numel(rois2)) = add2.V{ses}.concat_brain(:,rois2);
    end
    
    save([output_folder sprintf('V%0.2i.mat', s)], 'V');
    
    
    
end

