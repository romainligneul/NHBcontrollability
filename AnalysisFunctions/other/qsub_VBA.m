function qsub_VBA(y, u, evof, obsf, dim, options, output_dir)
%QSUB_VBA Summary of this function goes here
%   Detailed explanation goes here

[posterior, out] = VBA_NLStateSpaceModel(y, u, evof, obsf, dim, options);

sss=1;
GoF(sss,1) =  out.F;
GoF(sss,2) =  out.fit.BIC;
GoF(sss,3) =  out.fit.AIC;
%   break
for pp = 1:length(posterior.muTheta);
    thetaFitted(sss,pp) = options.inF.param_transform{pp}(posterior.muTheta(pp));
end;

for pp = 1:length(posterior.muPhi);
    phiFitted(sss,pp) = options.inG.param_transform{pp}(posterior.muPhi(pp));
end;

muX = out.suffStat.muX;
suffStat = out.suffStat;

rawphi=posterior.muPhi;
rawtheta=posterior.muTheta;


u = out.u;

save([output_dir],'options', 'muX', 'phiFitted', 'thetaFitted', 'GoF', 'u', 'options', 'suffStat', 'rawphi', 'rawtheta');

end

