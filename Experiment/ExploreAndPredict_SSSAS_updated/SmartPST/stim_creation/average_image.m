clear all;
listdir = {'stimuli'};
inputsuffix = 'jpg';
forcemode = 180; % -1 to not execute
 
nmasks = 2;

ii = 1;
for l=1:length(listdir)
    
    imglist = dir([listdir{l} '/*jpg']);
    
    for i = 1:length(imglist)
    img(i,:,:) = double(imread([listdir{l} '/' imglist(i).name]));
    end
    
    mean_img = squeeze(mean(img,1));
    
    imwrite(uint8(mean_img), 'mean_mask.jpg');
    
    subind = find(mean_img~=180);
    mask = mean_img;
    for m=1:nmasks
        
        mask(subind) = mean_img(Shuffle(subind));
        
       imwrite(uint8(mask), ['masks\mean_mask' num2str(m) '.jpg']);
        
    end
end