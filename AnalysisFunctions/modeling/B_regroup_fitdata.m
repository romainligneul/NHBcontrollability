%% script used to group individual fits
clear all;

models_folder='/project/3017049.01/github_controllability/AnonymizedData/fmri/MODELS_RERUN/';

dirlist = dir(models_folder)
dirlist(1:2)=[];
dirlist=dirlist([dirlist.isdir])

for m=1:length(dirlist)
    
    slist = dir([models_folder dirlist(m).name '/*.mat']);
    
    try 
    
    clear GoF phiFitted thetaFitted rawphi rawtheta u muX
    
    for s=1:length(slist)
        sdat = load([models_folder dirlist(m).name '/' slist(s).name]);
        GoF(s,:)=sdat.GoF;
        phiFitted(s,:)=sdat.phiFitted;
        thetaFitted(s,:)=sdat.thetaFitted;
        u{s}=sdat.u;
        muX{s}=sdat.muX;        
        options = sdat.options;
        rawphi(s,:)=sdat.rawphi;
        rawtheta(s,:)=sdat.rawtheta;
       
    end
    
    save([models_folder dirlist(m).name '/fitted_model.mat'])
    
    end
    
end
