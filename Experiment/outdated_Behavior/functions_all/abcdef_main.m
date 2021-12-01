function [ output_args ] = abcdef_main( w, flow1  )
%ABCDEF_MAIN Summary of this function goes here
% INPUTS:
% - w is the screenID where psychtoolbox should flip the stimulus
% - flow1: corresponds to the stimulus displayed in flow 1
% - next_img: corresponds to the (3) possible next states (reordered outside)
% - specs is a structure accepting the following arguments
% if specs is empty or incomplete, then the default parameters below are
% used:
% 'next_xpos' def = [0.3 0.5 0.7]
% 'next_ypos' def = 0.4
% 'next_radius' def = 0.05
% 'txtstr' def = 'next?'
% 'txtcol' def = [180 180 180]
% 'txtsize' def = 30
% 'txtcol' def = [180 180 180]
% 'respindcol' def = [180 180 180]
% 'postchoicedur' def = 0.3
% 'fwidth' def = 4
% 'respbuttons' def = {'left', 'down', 'right'}
% ''bgcolor', [180 180 180];

% assign defaults and manually specified parameters
defaults = struct('next_xpos', [0.3 0.5 0.7],...
    'next_ypos', 0.4, ...
    'next_radius', 0.05,...
    'txtstr', 'next?',...
    'txtsize', 45,...
    'txtcol', [255 255 255],...
    'respindcol', [255 255 255],...
    'bgcolor', [0 0 0],...
    'postchoicedur', 0.3,...
    'fwidth', 4,...
    'st_rect', [0.4 0.58 0.6 0.78],...
    'respleft', 'left',...
    'respmid', 'down',...
    'respright', 'right');
for f = fieldnames(defaults)',
    if ~isfield(specs, f{1}),
        specs.(f{1}) = defaults.(f{1});
    end
end

end

