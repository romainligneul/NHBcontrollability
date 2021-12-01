function create_sphere_image(SPMmat,VOI,label,diam)
addpath('/autofs/space/plato_002/users/MATLAB_Scripts/spm8')
addpath('/usr/pubsw/common/scripts/fmri/Utilities_DGM/PPPI')

if exist(SPMmat,'file')==2 && ~isempty(strfind(SPMmat,'.mat'))
    load(SPMmat)
    if exist('SPM','var') && isstruct(SPM) && isfield(SPM,'xY') && isfield(SPM.xY,'VY')
        [img XYZmmY]=spm_read_vols(SPM.xY.VY(1));
        clear img
    else
        error('SPMmat is not an SPM.mat file')
    end
elseif exist(SPMmat,'file')==2 && (~isempty(strfind(SPMmat,'.nii')) || ~isempty(strfind(SPMmat,'.img')))
    SPM.xY.VY=spm_vol(SPMmat);
    SPM.xY.P=SPMmat;
    [img XYZmmY]=spm_read_vols(SPM.xY.VY(1));
    clear img
else
    error('SPMmat is not a file or not a valid file type')
end

for ii=1:size(VOI,1)
    clear xY
    if ~isstruct(VOI)
        xY.def='sphere';
        xY.xyz=VOI(ii,:)';
        try
            xY.spec=diam(ii);
        catch
        end
        xY.str=label{ii};
    else
        xY=VOI;
    end
    [xY, XYZmm, j] = spm_ROI(xY, XYZmmY);
    maskdir=pwd;
    spmhdr=create_mask_image(SPM,label{ii},XYZmm,maskdir);
end
end
