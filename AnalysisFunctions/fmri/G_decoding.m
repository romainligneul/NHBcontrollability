function decoding_binarycontrollability(subjnum)
% function used to run the decoding analysis, largely based on the template
% provided by the authors of the TDT toolbox
% https://sites.google.com/site/tdtdecodingtoolbox/

%% First, set the defaults and define the analysis you want to perform

% Add path of where this toolbox is (if you are in it just type pwd in the
% command line and copy and paste between ' ')
% If this script is in same path as the toolbox, simply run
% decoding_defaults below (then the path will be set automatically).
addpath('/project/3017049.01/Tools/decoding_toolbox_v3.997/')

% Did you add your software (SPM or AFNI) to the Matlab path?
% If not use addpath to do so (for AFNI, you need afni_matlab, see:
% http://afni.nimh.nih.gov/afni/matlab/

% Clear cfg (otherwise if you re-run this script, previous parameters may still be present)
clear cfg

% To set the path and add subdirectories to the path, run
decoding_defaults; % use cfg = decoding_defaults to set the defaults, too

% Since SPM is our default software, if you use AFNI set
% cfg.software = 'afni';

% Enter which analysis method you like
% The standard decoding method is searchlight, but we should still enter
% it to be on the safe side.
cfg.analysis = 'searchlight';

% Specify where the results should be saved, e.g. 'c:\exp\results\buttonpress'
cfg.results.dir = ['/project/3017049.01/SASSS_fMRI1/DECODING/DEC_hp96_subj_future/' sprintf('%0.3d', subjnum)];
mkdir(cfg.results.dir)

%% Second, get the file names, labels and run number of each brain image
%% file to use for decoding.

% For example, you might have 6 runs and two categories. That should give
% you 12 images, one per run and category. Each image has an associated
% filename, run number and label (= category). With that information, you
% can for example do a leave-one-run-out cross validation.

% There are two ways to get the information we need, depending on what you
% have done previously. The first way is easier.

% === Automatic Preparation ===
% a) If you generated all parameter estimates (beta images) in SPM and were
% using only one model for all runs (i.e. have only one SPM.mat file), use
% the following block.
% If you ran your deconvolutions in AFNI and have one file per run, use the
% following block.
% If not, go to "Manual Preparation".

% SPM USERS: Specify the directory to your SPM.mat and all related beta
%    images, e.g. 'c:\exp\glm\model_buttonpress'
% AFNI USERS: Specify all BRIK files corresponding to your estimated models
%    in a cell array, e.g.
%    {'/misc/data/mystudy/results1+orig.BRIK','/misc/data/mystudy/results2+orig.BRIK',...}
beta_loc = ['/project/3017049.01/SASSS_fMRI1/LEVEL1/SPM12_GLM30_R6_2ROI_HP96_MVPA/' sprintf('%0.3d', subjnum)];
% Specify the label names that you gave your regressors of interest in the
% SPM or AFNI analysis (e.g.'button left' and 'button right'). If you
% don't remember, then run:
regnames = display_regressor_names(beta_loc)';
% You may also use the wildcard * (but use with care!). Label names are
% case sensitive!
Cbeta = regnames(strmatch('stdC',regnames));
Ubeta = regnames(strmatch('stdU',regnames));

labelname1 = '*stdU*'; %Cbeta(1:2:end)';
labelname2 = '*stdC*';% Ubeta(1:2:end)';

% Next you need to specify a mask file for which voxels to use in your
% analysis. This would either one or multiple ROI masks or a whole brain
% mask. SPM typically creates a whole brain mask for you (mask.img). For
% AFNI, you can use 3dAutomask or simply run the following line of code
% decoding_create_maskfile(cfg,beta_loc);

% For searchlight or wholebrain pass one mask as a string e.g.
% 'c:\exp\glm\model_button\mask.img'
% For ROI analyses, you can specify one or multiple ROI masks as a cell or
% string matrix, e.g.
% {'c:\exp\roi\roimaskleft.img', 'c:\exp\roi\roimaskright.img'}
% You can also pass one file with multiple integer values that correspond
% to different (non-overlapping) masks, but 4D files for masks are
% currently not supported.
cfg.files.mask = [beta_loc '/mask.nii'];

% The following function extracts all beta names and corresponding run
% numbers from the SPM.mat. The function appends ' bin 1' to ' bin m' to
% the beta names if multiple regressors have been used for each condition
% within a run, e.g. when using time derivatives or an FIR design.
regressor_names = design_from_spm(beta_loc);
% For AFNI, the following function will do the same.
% regressor_names = design_from_afni(beta_loc);

% Now with the names of the labels, we can extract the file names and the
% run numbers of each label. The labels will be 1 and -1.
% Important: You have to make sure to get the label names correct and that
% they have been uniquely assigned, so please check them in regressor_names
% or with display_regressor_names(beta_loc)
cfg = decoding_describe_data(cfg,{labelname1 labelname2},[1 -1],regressor_names,beta_loc);
% update config manually to remove parametric regressors
% cfg.files.chunk(2:2:end)=[];
% cfg.files.name(2:2:end)=[];
% cfg.files.label(2:2:end)=[];
% cfg.files.descr'(2:2:end)=[];
% exclude chunks which miss a condition
ll=1;
for l=[-1 1]
    labind=find(cfg.files.label==l);
    nolabel{ll}=find(~ismember(1:4,unique(cfg.files.chunk(labind))));
    ll=ll+1;
end
for l=1:2
    if ~isempty(nolabel{l})
        remind{l}=find(ismember(cfg.files.chunk,nolabel{l}));
    end
end
try
    remind=cell2mat(remind);
    cfg.files.name(remind)=[];
    cfg.files.chunk(remind)=[];
    cfg.files.label(remind)=[];
    cfg.files.descr(remind)=[];
end
% do a pure leave one out
% cfg.files.chunk = [1:length(cfg.files.chunk)]';

%
% Other examples:
% For a cross classification, it would look something like this:
% cfg = decoding_describe_data(cfg,{labelname1classA labelname1classB labelname2classA labelname2classB},[1 -1 1 -1],regressor_names,beta_loc,[1 1 2 2]);
%
% Or for SVR with a linear relationship like this:
% cfg = decoding_describe_data(cfg,{labelname1 labelname2 labelname3 labelname4},[-1.5 -0.5 0.5 1.5],regressor_names,beta_loc);

% === Manual Preparation ===
% If you have used "Automatic Preparation", you can skip this step.
% Alternatively to the automatic extraction of relevant information for
% your decoding, you can also manually prepare the "files" field.
% For this, you have to load all image names and labels you want to use
% separately, e.g. with spm_select. This is not part of this example, but
% if you do it later, you should end up with the following fields:
%   cfg.files.name: a 1xn cell array of file names
%   cfg.files.chunk: a nx1 vector to indicate what data you want to keep
%       together for cross-validation (typically runs, so enter run numbers)
%   cfg.files.label: a nx1 vector of labels (for decoding, you can choose
%       any two numbers as class labels, but normally we use 1 and -1)

%% Third, create your design for the decoding analysis

% In a design, there are several matrices, one for training, one for test,
% and one for the labels that are used (there is also a set vector which we
% don't need right now). In each matrix, a column represents one decoding
% step (i.e. train-test-cycle, e.g. cross-validation run) while a row
% represents one sample (i.e. brain image). The decoding analysis will
% later iterate over the columns (i.e. "steps") of this design matrix. For
% example, you might start off with training on the first 5 runs and
% leaving out the 6th run. Then the columns of the design matrix will
% look as follows (we also add the run numbers and file names to make it
% clearer):
% cfg.design.train cfg.design.test cfg.design.label cfg.files.chunk cfg.files.name
%        1                0              -1               1         ..\beta_0001.img
%        1                0               1               1         ..\beta_0002.img
%        1                0              -1               2         ..\beta_0009.img
%        1                0               1               2         ..\beta_0010.img
%        1                0              -1               3         ..\beta_0017.img
%        1                0               1               3         ..\beta_0018.img
%        1                0              -1               4         ..\beta_0025.img
%        1                0               1               4         ..\beta_0026.img
%        1                0              -1               5         ..\beta_0033.img
%        1                0               1               5         ..\beta_0034.img
%        0                1              -1               6         ..\beta_0041.img
%        0                1               1               6         ..\beta_0042.img

% Again, a design can be created automatically (with a design function) or
% manually. If you use a design more often, then it makes sense to create
% your own design function.
%
% If you are a bit confused what the three matrices mean (train, test & label),
% have a look at them in cfg.design after you executed the next step.
% This should make it easier to understand.

% === Automatic Creation ===
% This creates the leave-one-run-out cross validation design:
% cfg.design = make_design_cv(cfg);
cfg.design=make_design_boot_cv(cfg,50);
% === Automatic Creation - alternative ===
% Alternatively, you can create the design during runtime of the decoding
% function, by specifying the following parameter:
% cfg.design.function.name = 'make_design_cv';
% For the current example this is not helpful, because you can already
% create the design at this point. However, you might run into cases in
% which you cannot prespecify the design (e.g. if your design depends on
% the outcome of some previous runs), and then this function will become
% useful.
cfg.scale.method = 'z';
cfg.scale.estimation = 'all';
cfg.scale.cutoff = [-3 3]; %
cfg.scale.check_datatrans_ok = true;
% === Manual Creation ===
% After having explained the structure of the design file above, it should
% be easy to create the structure yourself. You can then check it by visual
% inspection. Dependencies between training and test set will be checked
% automatically in the main function.

% Another remark: Check out combine_designs.m if you like to combine
% multiple designs in one cfg.

% cfg.feature_transformation.method = 'PCA';
% cfg.feature_transformation.estimation = 'all';
% cfg.feature_transformation.critical_value = 0.05;

%% Fourth, set additional parameters manually

% This is an optional step. For example, you want to set the searchlight
% radius and you have non-isotropic voxels (e.g. 3x3x3.75mm), but want the
% searchlight to be spherical in real space.

% Searchlight-specific parameters
cfg.searchlight.unit = 'mm'; % comment or set to 'voxels' if you want normal voxels
cfg.searchlight.radius = 8; % this will yield a searchlight radius of 12 units (here: mm).
cfg.searchlight.spherical = 0;

% Other parameters of interest:
% The verbose level allows you to determine how much output you want to see
% on the console while the program is running (0: no output, 1: normal
% output [default], 2: high output).
cfg.verbose = 0;

% Choose the method you want to perform (classification or regression). If
% your classifier supports the kernel method (currently only libsvm), then
% you can also choose classification_kernel (our default).
cfg.decoding.method = 'classification_kernel'; % this is our default anyway.
% cfg.decoding.method = 'classification'; % this is slower, but sometimes necessary
% cfg.decoding.method = 'regression'; % choose this for regression

% Define which measures/transformations you like to get as ouput
% You have the option to get different measures of the decoding. For
% example, you can get the accuracy for each voxel, the accuracy minus
% chance, sensitivity and specifitiy values, AUC, and quite some more.
% For a full list, see "help decoding_transform_results", the transres_*
% functions in transform_results, or checkout how you can add your own
% measure/transformation in README.txt (or copy one of the transres_*
% functions).

cfg.results.output = {'balanced_accuracy_minus_chance', 'AUC_minus_chance'};
% This value is already the default, i.e. you could remove it if you only
% want this value. % For a regression analysis, you would like to 'corr' or
% better 'zcorr'. For multiple outputs, use cell arrays, e.g.
% cfg.results.output = {'accuracy_minus_chance', 'AUC_minus_chance'};
% For more options, again check "help decoding_transform_results" or look
% at the transres_* functions in the transform_results folder.

% parameters for libsvm (linear SV classification, cost = 1, no screen output)
% cfg.decoding.train.classification.model_parameters = '-s 0 -t 0 -c 1 -b 0 -q';
% parameters for libsvm (linear SV regression, cost = 1, no screen output)
% cfg.decoding.train.classification.model_parameters = '-s 4 -t 0 -c 1 -b 0 -q';

%% Not necessary, but nice: Decide what you want to plot

% It's really fascinating and informative to look at what a searchlight
% (or your ROIs/etc.) look like. However, 3d plotting is very slow.
% Thus, you have different options to look at your searchlight:
%   0: Don't draw it at all (default)
%   1: Draw the searchlight/ROI/... every step
%   2: Every second step
%    ...
% 100: Every 100th step
% You got it.
% Just try different values and observe the run time you get.

cfg.plot_selected_voxels = 0;

% Or switch online plotting off completely:
%   cfg.plot_selected_voxels = 0;

% This is by default set to 1, but if you repeat the same design again and again, it can get annoying...
cfg.plot_design = 0; % this will call display_design(cfg);

% The following calls allow you to look at your design. The design will
% also be shown when you perform the decoding.

% If you want to display the design in a text format in the Matlab command window
% display_design(cfg);

%% Fifth, run the decoding analysis

% Fingers crossed it will not generate any error messages ;)
% cfg.design.unbalanced_data = 'ok';
results = decoding(cfg);

% This will generate results that are written, some of which are used
% only for sanity checks:
% (a) your decoding results as res_XX.nii, res_XX.img or res_XX.BRIK files
% (b) a res_XX.mat file containing all information in the images and more
% (c) a cfg.mat file containing the settings
% (d) the decoding design as an image in multiple formats
% (e) res_filedetails.txt and res_warnings.mat as sanity checks
%
% If your output contains more than one value per voxel, then (a) is not
% written. If you did a ROI or wholebrain analysis and want to extract the
% exact numerical results, you can do so by loading the result from (b)
% and navigating to the field results.accuracy_minus_chance.output or
% whatever your output is. For searchlight analyses the voxel locations are
% currently only provided as indices.

%% Sixth, inspect the results visually or do statistics

% Visual inspection of searchlight results can be done e.g. using software
% such as MRIcron: Open a background image, select your decoding results
% (typically res_accuracy_minus_chance.img) as overlay and set the range
% between 5 and e.g. 20. Increase the lower value until you can see blobs
% that may look meaningful. These regions may contain information, but may
% not. For statistical analysis at the group-level, normalize and smooth
% your images if not done previously and run a classical second-level
% t-test against 0 (we may change this suggestion in the future)
%
% ROI or wholebrain analysis:
% Many results are written as images and can be visually inspected using
% MRIcron or similar software. For statistical analysis at the group-level,
% extract all decoding results from the written .mat files and do a t-test
% either with Matlab, SPSS or the software of your choice.
%
% For subject-level statistics, run help decoding_statistics.

%% Some more hints for potentially useful features

% All of these need to be specified BEFORE calling decoding(cfg), of
% course.

% cfg.searchlight.subset = [5, 100, 1000, 1001]';
%   only decode some searchlights are executed. This makes sense if you
%   have coordinates and want results at these searchlight ROIs only. It
%   can also be used to parallelize the toolbox, i.e. running the first
%   10000 searchlights on one computer, the second on another, etc. Takes
%   either single values or 3d coordinates.
% (call "help decoding" and search for "subset" for more infos)

save([cfg.results.dir '/results.mat'], 'results', 'cfg');

end
