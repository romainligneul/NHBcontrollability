clear all

load('schaeffer17_allregressors_quin.mat');

for e=1:length(gheader)
    
    for r=1:length(groinames)
        
        roi_mat(:,r,e) = gdata{r}{1}(:,e);

    end
    
    [h p ci stats] = ttest(squeeze(roi_mat(:,:,e)));
    pFDR = mafdr(p');
    disp('')     
    disp(['%%%% ' num2str(gheader{e}) '%%%'])
    disp(strcat(groinames', {' ' },'t=', num2str(stats.tstat'),'pFDR=', num2str(p')))
    
end

y=roi_mat;
color= repmat(groinames,size(y,1),1,size(y,3));
dum(1,1,:) = gheader;
col= repmat(dum,size(y,1),size(y,2),1);

x= repmat([1:17]/4,size(y,1),1,size(y,3));

g = gramm('x', x(:), 'color', color(:), 'y', y(:));
g.stat_summary('type', 'sem', 'geom', 'bar', 'setylim', 'true', 'dodge', 0.7, 'width', 10);
g.stat_summary('type', 'sem', 'geom', 'black_errorbar', 'setylim', 'true', 'dodge', 0.7, 'width', 10);
g.set_names('column', '', 'x', '', 'y', '', 'color', '')
g.facet_wrap( col(:),'ncols', 3, 'scale', 'independent');
g.set_text_options('base_size', 8)
g.draw();


