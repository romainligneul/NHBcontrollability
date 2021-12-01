%% script used to compute second level group contrasts

clear all;
% rmpath('/home/common/matlab/spm12')

%% set domain name
S.Fname = 'SPM12_R6RETROICOR_2ROI_HP96_prior1'

%% set analysis name
S.Sname = 'all';

%% retrieve first level info
S.Fdir = '/project/3017049.01/SASSS_fMRI1/LEVEL1/';

% import first level structures
load([S.Fdir S.Fname '/infos_FIPRT.mat']);
load([S.Fdir S.Fname '/C.mat']);
load('personality_fmri.mat');
% S.F = F;clear F;

S.S_maindir = [F.secondlevpath S.Sname '/'];

try
rmdir(S.S_maindir)
end
list = C.regressor_list;%     s_ind(s) = strmatch(S.F.subjnames{s},covsubjects);
% end

load('SUBINF.mat');
load('BEHAVIOR/behavior_32s.mat')

BICdiff = [5.38840874611532,6.27317921089878,11.2505326593606,9.36079257737586,10.9934780435593,14.3216276622246,3.12625835912229,11.3819336544988,-0.765509146220893,7.23795171483454,7.16005628083906,2.93899934919148,8.47550619363631,9.27425924178175,6.92988298697350,17.8555606142873,5.12569229654486,6.29540271235982,8.16168230006275,7.47327042957392,-2.99925204834796,8.68204036535008,19.2712014021815,-1.89170062709582,-13.7185142642742,21.9021284333638,1.04042014789658,20.6801478213325,9.14293236672728,12.7610700986934,16.9334979895538,14.5440473382839];
BICratio = [1.02171361806458,1.01043619825312,1.01086589032870,1.00268766702982,1.00326225457924,1.04921413783793,0.999239454337751,1.00742806191668,0.983085936588745,0.995081187915738,0.990866010193725,0.988620787057029,1.01069852479613,1.01823780369136,1.01959707849731,1.03488166915002,1.02539536448477,0.984106759816097,1.01984041486316,1.00429730012398,0.989655842780746,1.06638602972595,1.07028342070977,0.984056997604496,0.995488875993891,1.05839957944840,1.00565615640565,1.01059589065681,1.00012619399251,1.04832537450915,1.01560815430232,1.03839968897720];
AICratio =[1.06025933713762,1.04396608819362,1.04787364233242,1.04078829751159,1.03888861107482,1.10756636725455,1.02118945098784,1.04399331060398,1.00019084312637,1.02234025618910,1.02074023434271,1.01297794318605,1.04001098941433,1.04831602655925,1.06304544150986,1.08327893870201,1.06256221349564,1.01305089364664,1.06581144029793,1.04001762102841,1.00829619156966,1.12972869994338,1.15918268043742,1.00042940466628,1.01669194356750,1.13448070451070,1.04045201099413,1.05832193741896,1.02737126298718,1.10271772025309,1.05958638928179,1.08739316478333];
accuracy=[0.657894736842105,0.642857142857143,0.704819277108434,0.858108108108108,0.792207792207792,0.732558139534884,0.468992248062016,0.737804878048781,0.487288135593220,0.668539325842697,0.765822784810127,0.670329670329670,0.570754716981132,0.495798319327731,0.725609756097561,0.706896551724138,0.552083333333333,0.833333333333333,0.772727272727273,0.790540540540541,0.402439024390244,0.655555555555556,0.900000000000000,0.458646616541353,0.461832061068702,0.815068493150685,0.694444444444444,0.867647058823529,0.616161616161616,0.675531914893617,0.876811594202899,0.672413793103448];
LLratio=[1.10189294828745,1.08397862780305,1.09481132428220,1.09683811101759,1.08972305094893,1.16131318763443,1.04797494798413,1.09249850110402,1.02743917978173,1.06271223407363,1.07046899572767,1.05224924541254,1.07358917902275,1.07896479655426,1.11418183939700,1.13203597114907,1.10096996516513,1.06894911295705,1.12139517828470,1.09101958358434,1.03461994665286,1.18114776136674,1.24298498660157,1.02509461061111,1.04379402845325,1.20684728076231,1.08593153344389,1.12586212635454,1.06360934186929,1.15121049159585,1.11720610003985,1.13533045939062];
%alphaSS alphaSAS alphaOmega
theta_model10 = [0.336676416524546,0.590130661545602,0.380557665327448,0.348731177104983,0.351106644461408,0.516150112290404,0.301648866638098,0.311374030112382,0.212315255936238,0.476146824208769,0.228454287044518,0.319852044445991,0.545865947570148,0.732262413776149,0.279082321526304,0.305961038239138,0.600881401783745,0.263602622899880,0.342023862408434,0.281457120133082,0.530845145531044,0.396442651475726,0.299006499401216,0.234482049943756,0.467210506997752,0.291932491698799,0.148458870526046,0.503015121380571,0.416790669405538,0.595395532296106,0.318981401225163,0.353089514191332;0.558302575925324,0.498771329836788,0.464736024381292,0.512517319116386,0.671817769456284,0.516299882491126,0.400877494398168,0.629720236937528,0.529934546492456,0.606262360884244,0.519583340321491,0.480793562206713,0.635406235665467,0.459556065593871,0.446519702364212,0.468700011524569,0.360899959193034,0.501768593584325,0.759669267365235,0.471800106131723,0.323751590088788,0.403684280574321,0.515361137984383,0.472258629131040,0.470163860847843,0.571400835399614,0.434544066987590,0.638122751231901,0.673591789172431,0.488291034903063,0.444471164733511,0.577879746080298;0.336595457411062,0.381838533054914,0.193689840364653,0.333102999360056,0.163046620049233,0.203334990437636,0.294441428196942,0.196409795088870,0.544531844136041,0.416934524232321,0.356853268907722,0.386759359221429,0.197418586414446,0.323560311155747,0.237038854724041,0.328387305530553,0.239148808621432,0.238042950963410,0.421627523494648,0.335978069175788,0.320928731668127,0.259267203212482,0.216635761955981,0.346240937191729,0.260117682783762,0.196859790230674,0.134351647628234,0.249748242682043,0.196246020194559,0.394563138660751,0.179363509349895,0.346735295754609];
omega_switch_param = [28.3904744480569,77.9295178054134,25.9524024018404,19.6752797653250,18.9568357605700,50.1963389941233,3.68733113960943,12.1745526141820,10.8522091231714,22.4036813204219,15.5911667776472,25.4648365371455,15.9386670676341,4.44739954192145,17.5862056751255,30.8457754654935,16.6638904388115,15.2938774747848,13.1822655474732,17.5627643237262,13.4177137451546,13.6384023248746,21.4396636771926,52.9560104521603,3.13154187373052,19.9674321848762,20.5618529430040,23.6516259721011,14.8136120770606,62.1708378653872,33.6946379801927,21.1850604499984];
logistic_beta = [1.04065990154762,1.29549301786301,1.61125611206024,1.83536419169127,2.27191401912694,1.27988728502982,0.381096399683473,0.961553771360823,0.294994980397128,1.81945181047670,1.57920285085146,0.869421635379359,0.351640342672457,-0.0569321626624233,1.21722624961733,1.08135038733541,1.13305325570423,1.31880851865143,0.723344055895927,0.768411764975146,0.716046448986835,0.331868498195017,2.43076683085891,0.0247383415693870,0.232773955927136,0.895590299062897,0.747875853480969,2.07746915460048,0.952127170920929,1.66184149538159,1.27130456901198,1.03418255665935];
logistic_intercept = [0.531843687591544,0.969086106703886,0.578888613036515,0.200305767519336,0.601496274673883,0.0257391035085782,0.342423366532897,0.0956361607901974,0.0700026149064100,1.07909436887981,-0.212849362114800,0.264952169466265,0.159230494474563,-0.287924550645258,0.324335387812212,0.409075979327536,0.474827865254489,0.204634262652754,0.638681403430298,0.205002002258145,0.623164458035073,-0.415059843649533,0.734311957276040,1.06890794747516,-0.391140914674907,0.519914415312092,0.578536564362453,0.396017951308186,-0.0907120318329327,1.22123580037886,0.437298191672644,0.559374008934593];
bird_overchance = [0.894423679728351,0.00169694203179160,4.77395900588817e-15,4.77395900588817e-15,2.22218154988241e-09,0.533187523225598,4.77395900588817e-15,4.77395900588817e-15,4.77395900588817e-15,0.998303057968213,6.64857058296775e-12,2.22218154988241e-09,0.999999999998147,0.995228359133784,0.0274509362486690,4.72745430579735e-08,0.598653322465136,4.77395900588817e-15,3.97626934400819e-06,4.77395900588817e-15,0.0565154821409610,2.22218154988241e-09,4.77395900588817e-15,0.139307273172116,0.226685849715492,4.77395900588817e-15,2.29066765555785e-11,0.0565154821409610,0.661465102816583,4.77395900588817e-15,4.77395900588817e-15,0.466812476774401];
decision_param_final = [3.72910632688305,3.81767364759902,3.88358932187506,5.12074973895629,4.24916599137858,3.13695419912679,2.06568632865472,4.07826544826600,1.94961243668884,3.36176708020503,4.76799568639377,2.92598618099691,1.58406692648653,1.45485525052413,5.61098006615110,3.64758260478697,1.89304855417509,5.59363551357275,4.70329411159064,3.97383020899404,1.03992538606588,3.39212435746892,6.20854872645549,1.49423312934062,2.13075468581749,7.15909519739712,5.93449671364470,5.71366158644096,3.02520171985349,3.60846129769880,5.55028693723769,3.46082953930561;10.3939267169737,5.83061826575394,31.3755991864733,8.83558622092199,13.2605139271279,107.197095511410,2.08575021842852,6.46161357044427,88.1650976852642,13.4129771404533,6.01804921009353,9.52353346913444,53.0001686845500,5.08600560224082,16.8770281253376,18.7771374288779,58.8504041457347,10.6158421309682,5.17355246470283,10.5676983395692,12.6023179714780,6.09142565592174,6.85625362270841,2.58335027950861,19.7148157425493,5.69962807118794,6.57239783865833,16.0888703758211,7.19183454744851,33.3217459204687,33.3222957458958,12.1920000539621;-0.102726012005071,-0.218551505505650,-0.0264824971919361,-0.0716711469120591,-0.0812772561158859,0.0199239028864993,0.0843824162186579,0.0129940503728316,-0.129298148459911,-0.0884783654731756,-0.177125641440781,-0.0984598496588799,0.0745590578037376,0.325326420990090,-0.0451416329078657,-0.0500320440893625,0.100796288431283,-0.0681581757408963,-0.163766876722884,-0.0719659315151331,0.0396552147599580,0.317753698084736,-0.114653319414617,-0.0819650455724678,0.334232519699780,-0.187135347216298,-0.284527872035235,-0.0616435116399140,-0.0827679856131752,-0.0319328000846509,-0.0632209134000719,-0.0721481608150101];
omega_bias = [-0.102726012005071;-0.218551505455914;-0.0264824976597079;-0.0716711469278014;-0.0812772561629932;0.0199239028864993;0.0843824162186579;0.0129940503728316;-0.129298148459911;-0.0884783654731756;-0.177125641440781;-0.0984598496588799;0.0745590578037376;0.325326420990090;-0.0451416329078657;-0.0500320440893625;0.100796288431283;-0.0681581757408963;-0.163766876722884;-0.0719659315151331;0.0396552147579972;0.317753698159869;-0.114653319412238;-0.0819650455724678;0.334232519699780;-0.187135347216298;-0.284527872018730;-0.0616435116395054;-0.0827679856219936;-0.0319328000846509;-0.0632209134000719;-0.0721481608150101];
SSpeRT = [0.0665723793578992	0.260141111714138	0.0939224000212752	-0.0434048137859246	0.464546179803883	0.232707603121385	0.0141765792204288	0.169691165405443	-0.379469255470889	-0.0787740826476723	-0.123142407008495	0.0874775974641636	-0.0540269903078173	-0.00845114590379251	0.0438963729923490	0.251626672109177	0.254831173949986	0.213847585114877	-0.100172942952853	-0.158033881211439	0.303451044951277	-0.0120862111857104	0.0875490963816641	-0.0717008410010082	0.129702811532492	0.323142422241720	0.357587560856130	-0.284058986926416	0.0278760791957541	0.236924136603856	0.377892478870197	0.0242377948959834];
SASpeRT = [-0.0475197803780578	-0.0286663499978961	0.0712427370776522	0.233323674908676	-0.229021536881617	0.115469110017868	-0.0733305320178345	0.130742636169612	0.334316127074374	0.120628280481106	0.273538537386575	0.270565846742646	0.0463905859125667	0.0731863849006334	0.156685097181104	0.217082360087822	0.00753256573718907	0.153827621038396	0.619004474556133	0.349558680286033	-0.0931440463942141	0.434072557879066	0.195594005314417	0.0654343433902291	-0.122489471162137	0.0975027437380806	0.0537403451519353	0.0919620062550582	0.0344852155582004	-0.175519556071931	0.268940906280853	-0.0641891418698832];
cbias = [0.163265306122449,0.547619047619048,0.142857142857143,0.0571428571428572,0.235294117647059,-0.0666666666666668,0.0869565217391306,0.0243902439024390,0,0.461538461538462,-0.0277777777777778,0.0869565217391306,0.0555555555555555,-0.291666666666667,-0.0425531914893616,0.111111111111111,-0.0344827586206895,0.0571428571428571,0.195121951219512,0,0.0684931506849315,-0.357142857142857,0.125000000000000,0.677966101694915,-0.337500000000000,0.375000000000000,0.473684210526316,0,-0.0600000000000001,0.207547169811321,0.0540540540540539,0.292682926829268];
% get Omega bias
load('/project/3017049.01/SASSS_fMRI1/BEHAVIOR/modeling_seq_final/o_MBtype2_wOM2_bDEC1_max_nobound_e_aSASSSSAS1_aOMIntInf1_nobound_13-Oct-2019_1/fitted_model.mat','muX', 'phiFitted')
omega_ind = 49;
for s=1:length(muX)
    mean_omega(s,1) = mean(VBA_sigmoid(muX{s}(omega_ind,:), 'slope', phiFitted(s,2), 'center', phiFitted(s,3)));
end

ccc=0;
% %
% ccc=ccc+1;
% S.covariates(ccc).name = 'SSpeRT';
% S.covariates(ccc).values = zscore(SSpeRT);
% % %
ccc=ccc+1;
S.covariates(ccc).name = 'cbias';
S.covariates(ccc).values = zscore(cbias');

% ccc=cc
% ccc=ccc+1;
% S.covariates(ccc).name = 'omega_mean';
% S.covariates(ccc).values = zscore(mean_omega);

% % ccc=ccc+1;
% S.covariates(ccc).name = 'alphaSAS';
% S.covariates(ccc).values = zscore(theta_model10(2,:));
% 

% name = 'bird_overchance';
% S.covariates(ccc).values = zscore(bird_overchance<0.05);
% ccc=ccc+1;
% S.covariates(ccc).name = 'beta_interceptLogist';
% S.covariates(ccc).values = zscore(logistic_intercept);

% 
% ccc=ccc+1;
% S.covariates(ccc).name = 'UCovC_acc';
% S.covariates(ccc).values = zscore([0.746676587301587;0.651562500000000;0.755208333333333;0.869419642857143;0.739236111111111;0.796006944444444;0.580009920634921;0.777604166666667;0.597569444444445;0.709375000000000;0.821875000000000;0.747395833333333;0.706026785714286;0.682291666666667;0.809375000000000;0.769791666666667;0.829315476190476;0.845312500000000;0.808482142857143;0.864583333333333;0.631770833333333;0.880208333333333;0.853125000000000;0.447395833333333;0.713169642857143;0.739732142857143;0.664384920634921;0.868750000000000;0.701215277777778;0.738541666666667;0.906250000000000;0.712127976190476]./[0.682465277777778;0.757812500000000;0.779687500000000;0.920833333333333;0.911458333333333;0.776364087301587;0.471875000000000;0.792857142857143;0.556250000000000;0.755208333333333;0.792857142857143;0.700000000000000;0.610937500000000;0.436607142857143;0.731051587301587;0.765625000000000;0.520833333333333;0.873958333333333;0.793229166666667;0.771527777777778;0.350694444444444;0.650000000000000;0.953125000000000;0.583482142857143;0.343750000000000;0.937500000000000;0.813690476190476;0.889583333333333;0.706250000000000;0.698958333333333;0.892187500000000;0.727232142857143]);
% %
% % ccc=ccc+1;
% % S.covariates(ccc).name = 'C_acc';
% % S.covariates(ccc).values = zscore([0.682465277777778;0.757812500000000;0.779687500000000;0.920833333333333;0.911458333333333;0.776364087301587;0.471875000000000;0.792857142857143;0.556250000000000;0.755208333333333;0.792857142857143;0.700000000000000;0.610937500000000;0.436607142857143;0.731051587301587;0.765625000000000;0.520833333333333;0.873958333333333;0.793229166666667;0.771527777777778;0.350694444444444;0.650000000000000;0.953125000000000;0.583482142857143;0.343750000000000;0.937500000000000;0.813690476190476;0.889583333333333;0.706250000000000;0.698958333333333;0.892187500000000;0.727232142857143]);
% ccc=ccc+1;
% S.covariates(ccc).name = 'accuracy';
% S.covariates(ccc).values = zscore(accuracy);


% ccc=ccc+1;
% S.covariates(ccc).name = 'invtemp';
% S.covariates(ccc).values = zscore(log(decision_param_final(1,:)));
% % ccc=ccc+1;
% % S.covariates(ccc).name = 'invtemp_omega';
% % S.covariates(ccc).values = zscore(log(decision_param_final(2,:)));
% ccc=ccc+1;7

% S.covariates(ccc).name = 'bias_omega';
% S.covariates(ccc).values = zscore(decision_param_final(3,:));
% 
    S.covariates = [];

% controlbias(:,1)=CtoUC=frequency of missed C evaluation
% controlbias(:,2)=CtoUC=frequency of missed UC evaluation
% controlbias = [0.204081632653061,0.391304347826087;0.122448979591837,0.482142857142857;0.224489795918367,0.410714285714286;0.142857142857143,0.267857142857143;0.122448979591837,0.339285714285714;0.285714285714286,0.303571428571429;0.362318840579710,0.516666666666667;0.289855072463768,0.300000000000000;0.405797101449275,0.433333333333333;0.202898550724638,0.350000000000000;0.318840579710145,0.183333333333333;0.289855072463768,0.266666666666667;0.420289855072464,0.400000000000000;0.583333333333333,0.400000000000000;0.375000000000000,0.233333333333333;0.375000000000000,0.316666666666667;0.305555555555556,0.233333333333333;0.291666666666667,0.200000000000000;0.277777777777778,0.300000000000000;0.305555555555556,0.200000000000000;0.219178082191781,0.366666666666667;0.424657534246575,0.233333333333333;0.273972602739726,0.250000000000000;0.260273972602740,0.729729729729730;0.562500000000000,0.472972972972973;0.337500000000000,0.540540540540541;0.325000000000000,0.540540540540541;0.325000000000000,0.418918918918919;0.325000000000000,0.364864864864865;0.250000000000000,0.500000000000000;0.200000000000000,0.364864864864865;0.225000000000000,0.445945945945946];
% ccc=ccc+1;
% S.covariates(ccc).name = 'CtoUC_bias';
% S.covariates(ccc).values = zscore(controlbias(:,1));
% ccc=ccc+1;
% S.covariates(ccc).name = 'UCtoC_bias';
% S.covariates(ccc).values = zscore(controlbias(:,2));
% 
% S.covariates(2).name = 'long_learn';
% S.covariates(2).values = xnum(s_ind,4);
% 
% for s=1:size(C.con_id,1)
%     c_ind = 0;
%     for c= 1:size(list,1)
%         if ~isempty(C.con_id{s,c})
%             c_ind = c_ind+1;
%             C.con_id_bis{s,c} = sprintf('con_%0.4d.nii',c_ind);
%         else
%             C.con_id_bis{s,c} = sprintf('con_%0.4d.nii',c_ind);
%         end
%     end
% end
% % 


% ccc=ccc+1;
% S.covariates(ccc).name = 'iLoc';
% S.covariates(ccc).values = fmri_personality(:,5);
% S.covariates(ccc).values(~isnan(S.covariates(ccc).values)) = zscore(S.covariates(ccc).values(~isnan(S.covariates(ccc).values)));

% ccc=ccc+1;
% S.covariates(ccc).name = 'eLoc';
% S.covariates(ccc).values = fmri_personality(:,6);
% S.covariates(ccc).values(~isnan(S.covariates(ccc).values)) = zscore(S.covariates(ccc).values(~isnan(S.covariates(ccc).values)));
% ccc=ccc+1;
% S.covariates(ccc).name = 'iLoc_min_eLoc';
% S.covariates(ccc).values = fmri_personality(:,5)-fmri_personality(:,6);
% S.covariates(ccc).values(~isnan(S.covariates(ccc).values)) = zscore(S.covariates(ccc).values(~isnan(S.covariates(ccc).values)));
% 
% % ccc=ccc+1;
% S.covariates(ccc).name = 'iLoc';
% S.covariates(ccc).values = fmri_personality(:,5);%./fmri_personality(:,5);
% S.covariates(ccc).values(~isnan(S.covariates(ccc).values)) = zscore(S.covariates(ccc).values(~isnan(S.covariates(ccc).values)));
% 

CMI_duringControl = [0.476722449215071,0.535051934669758,0.514100077253977,0.513717697756141,0.411280259950847,0.393589254525135,0.513701586023833,0.493721162413546,0.455064154592054,0.487852986267362,0.392680247568630,0.405251959132822,0.428443673956774,0.544904528108917,0.405541267251713,0.450450088175447,0.494921850365824,0.478333297775626,0.471282111246024,0.358523892714501,0.473645673234098,0.478978840121078,0.408132779395939,0.395922034093873,0.520002590640182,0.523990079511412,0.436470510237760,0.495344444619270,0.436554527023951,0.455123339554882,0.279311931938375,0.417661360829202];

% ccc=ccc+1;
% S.covariates(ccc).name = 'iLoc';
% S.covariates(ccc).values = fmri_personality(:,5);%./fmri_personality(:,5);
% S.covariates(ccc).values(~isnan(S.covariates(ccc).values)) = zscore(S.covariates(ccc).values(~isnan(S.covariates(ccc).values)));


    S.covariates = [];
subset_subjects = 1:32;
%  subset_subjects = find(~ismember(subset_subjects,[7 9 13 14 17 21 22 24 25]));
noOmegaBIC=[7 9 13 14 17 21 22 24];
%  subset_subjects(noOmegaBIC)=[];
% subset_subjects = find(~ismember(subset_subjects,find(isnan(S.covariates(ccc).values))));
% subset_subjects = find(~ismember(subset_subjects,[7 9 16 19 32]));

% subset_subjects = find(accuracy>=0.66);
% 
% subset_subjects = find(~ismember(subset_subjects,[5]));
% for cov=1:length(S.covariates)
%     S.covariates(cov).values=S.covariates(cov).values(subset_subjects);
% end

j=0;
for c = 1:size(list)
        
    cname = list{c};
    bind = strfind(cname, '*bf(1)');
    cname(bind:end) = [];
    
    S.S_subdir{c,1} = [F.secondlevpath  '/' S.Sname '/' cname '/'];
    
    mkdir(S.S_subdir{c,1})
    
    sc = 0;
    keep_ind =[];
    for s = subset_subjects %1:size(C.subj_array,2)
        if ~isempty(C.con_id{s,c})
            sc=sc+1;
            keep_ind(sc,1)=s;
            S.S_subscans{c}{sc,1} = char(strcat([F.firstlevpath F.subjnames{s} '/'],  char(C.con_id{s,c})));
        end
    end
    
    j = j+1;
    matlabbatch{j}.spm.stats.factorial_design.dir = {S.S_subdir{c,1}};
    matlabbatch{j}.spm.stats.factorial_design.des.t1.scans = S.S_subscans{c};
    matlabbatch{j}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    if ~isempty(S.covariates)
        for cov = 1:length(S.covariates)
            matlabbatch{j}.spm.stats.factorial_design.cov(cov).cname = S.covariates(cov).name;
            matlabbatch{j}.spm.stats.factorial_design.cov(cov).iCFI = 1;
            matlabbatch{j}.spm.stats.factorial_design.cov(cov).iCC = 1;
            matlabbatch{j}.spm.stats.factorial_design.cov(cov).c = S.covariates(cov).values(keep_ind);
        end
    end
%     matlabbatch{j}.spm.stats.factorial_design.multi_cov.files = {''};
%     matlabbatch{j}.spm.stats.factorial_design.multi_cov.iCFI = 1;
%     matlabbatch{j}.spm.stats.factorial_design.multi_cov.iCC = 1;
    matlabbatch{j}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{j}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{j}.spm.stats.factorial_design.masking.em = {'/project/3017049.01/SASSS_fMRI1/brainmask_adapted.nii'};
    matlabbatch{j}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{j}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{j}.spm.stats.factorial_design.globalm.glonorm = 1;
    
    j = j+1;
    matlabbatch{j}.spm.stats.fmri_est.spmmat = {[S.S_subdir{c,1} 'SPM.mat']};
    matlabbatch{j}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{j}.spm.stats.fmri_est.method.Classical = 1;
    
    j = j+1;
    contrast_vec = zeros(1,1+length(S.covariates));
    matlabbatch{j}.spm.stats.con.spmmat = {[S.S_subdir{c,1} 'SPM.mat']};
    matlabbatch{j}.spm.stats.con.consess{1}.tcon.name = 'normal';
    matlabbatch{j}.spm.stats.con.consess{1}.tcon.convec = contrast_vec;
    matlabbatch{j}.spm.stats.con.consess{1}.tcon.convec(1) = 1;
    matlabbatch{j}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{j}.spm.stats.con.delete = 1;
    matlabbatch{j}.spm.stats.con.consess{2}.tcon.name = 'inverse';
    matlabbatch{j}.spm.stats.con.consess{2}.tcon.convec = contrast_vec;
    matlabbatch{j}.spm.stats.con.consess{2}.tcon.convec(1) = -1;
    matlabbatch{j}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{j}.spm.stats.con.delete = 1;
    if ~isempty(length(S.covariates))
        for cov = 1:length(S.covariates)
            matlabbatch{j}.spm.stats.con.consess{2+1+(cov-1)*2}.tcon.name = ['pos_' S.covariates(cov).name];
            matlabbatch{j}.spm.stats.con.consess{2+1+(cov-1)*2}.tcon.convec = contrast_vec;
            matlabbatch{j}.spm.stats.con.consess{2+1+(cov-1)*2}.tcon.convec(1+cov) = 1;
            matlabbatch{j}.spm.stats.con.consess{2+1+(cov-1)*2}.tcon.sessrep = 'none';
            matlabbatch{j}.spm.stats.con.consess{2+2+(cov-1)*2}.tcon.name = ['neg_' S.covariates(cov).name];
            matlabbatch{j}.spm.stats.con.consess{2+2+(cov-1)*2}.tcon.convec = contrast_vec;
            matlabbatch{j}.spm.stats.con.consess{2+2+(cov-1)*2}.tcon.convec(1+cov) = -1;
            matlabbatch{j}.spm.stats.con.consess{2+2+(cov-1)*2}.tcon.sessrep = 'none';
        end
    end  
end

mkdir(S.S_maindir)
save([S.S_maindir 'one_sample_' date '.mat'], 'matlabbatch');

% execute batch
spm_jobman('initcfg')
spm_jobman('serial', matlabbatch);
