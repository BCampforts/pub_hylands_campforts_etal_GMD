% HyLands_LS_A_LS simulation with of HyLands Hybrid Landscape evolution model 
%
% Script to run simulation described in:
%
% Campforts B., Shobe M.C., et al. : HyLands 1.0: a Hybrid
% Landscape evolution model to simulate the impact of landslides and
% landslide-derived sediment on landscape evolution. Discussion paper in
% Geoscientific Model Development,
% https://geoscientific-model-development.net
%
% Author:   Benjamin Campforts (benjamin.campforts@gfz-potsdam.de)
%
% See also: HYLANDS, HYLANDS_set
%
% Date:     15. March, 2020

%% Clear environment
clearvars
clc
close all

%% Set path
% Not needed if TopoToolbiox is already on the search path of Matlab.
% addpath(genpath('C:\path\to\wherever\you\installed\this\topotoolbox-v2.4-HyLands-v1.0'))
scriptName= mfilename;

%% Temporal domain
p.TimeSpan=5e5;
p.TimeStep=5;

%% Save and plot
p.ploteach=10;
p.saveeach=1;
p.save_LS_Data=false;
p.save_LS_D=false;
p.fileprefix=scriptName;

%% Check for mass balance
% Check mass balance: for every component and after every iteration
p.checkMB=true;
%% Plotting and output
% verbose
p.verbose=false;
% Kind of plot: For regular TTLEM output (p.plotSed=false;)
p.plotSed=true;

%% Initial Surface
% load output from LS_B model run
load('Data\output_LS_LS.mat');

DEMIni=crop(output.bedrock,output.I_Domain);
iniSed=crop(output.sediment,output.I_Domain);

%% Vertical uplift
p.U_type='uniform';
UplRate=1e-3;
T.spatial = GRIDobj(DEMIni)+UplRate;

%% Boundary conditions
% Define open nodes: Drain towards lower left corner
p.FlowBC='ll_cor';

% Bedrock elevation at open nodes is set to a fixed value, provided by 
% p.BC_BedDirVal, defaulting to 0
% Sediment thickness varies through time as a function of the SPACE
% mathematics. Thus, at open nodes, the sediment thickness is based on the
% sediment thickness of the upstream river cell. 
p.BC_Type='set_VaropenNodes';


%% Make sure flow accumulation honors imposed boundary conditions

if ~isempty(p.FlowBC)
    BORDER = getBORDER(DEMIni,p);
else
    BORDER=[];
end
DEMIni = DEMIni+BORDER;
DEMIni=fillsinks(DEMIni);
DEMIni=DEMIni-BORDER;

%% River incision
p.FlowDir='single';
p.DrainDir='variable';
p.K_bed=5e-5;
p.K_sed=p.K_bed*1.5;
p.Ff=0;
p.V=2;
p.V_Lakes=10;
p.H_star=0.5;
p.m=0.5;
p.n=1;

%% Landsliding
p.LS_Bed=false;



%% Initialize parameter structure
p   = HYLANDS_set(p);

%% If resultdir does not exist; make it
if  ~exist(p.resultsdir,'dir')
    mkdir(p.resultsdir)
end

%% Model run
output = HYLANDS(DEMIni,T,p,'iniSed',iniSed);
output.p = p;
output.UplRate = UplRate;
output.DEMIni = DEMIni;
output.T = T;
output.iniSed = iniSed;
save('Data\output_LS_A_LS.mat','output');
