% HyLands_LS_NB simulation with of HyLands Hybrid Landscape evolution model 
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
%% Set path;
% Not needed if TopoToolbiox is already on the search path of Matlab.
addpath(genpath('C:\Users\Benjamin\Box Sync\GitHub_UI\TopoToolbox'))

scriptName= mfilename;
%% Temporal domain
p.TimeSpan=10;
p.TimeStep=5;

%% Save and plot
p.ploteach=5;
p.saveeach=1;
p.save_LS_Data=true;
p.save_LS_D=true;
p.fileprefix=scriptName;

%% Check for mass balance
% Check mass balance: for every component and after every iteration
p.checkMB=true;

%% Plotting and output
% verbose
p.verbose=false;
% Kind of plot: For regular TTLEM output (p.plotSed=false;)
p.plotSed=true;

%% Initial Surface; Load DEM; resample to 20m
% Full DEM
load('DEMs\DEM_Yarlung_C.mat','DEM');
% Smaller subsample
% load('DEMs\DEM_Yarlung_Mini.mat','DEM');
DEM.Z=double(DEM.Z);

iniSedThickness=0;
iniSed=GRIDobj(DEM)+iniSedThickness;

%% Vertical uplift
p.U_type='uniform';
UplRate=0;
T.spatial = GRIDobj(DEM)+UplRate;

%% Boundary conditions
p.FlowBC='open';
p.BC_Type='Bed_Sed_Open';

%% Make sure flow accumulation honors imposed boundary conditions
if ~isempty(p.FlowBC)
    BORDER = getBORDER(DEM,p);
else
    BORDER=[];
end
DEM = DEM+BORDER;
DEM=fillsinks(DEM);
DEM=DEM-BORDER;

figure('units','normalized','outerposition',[0.1 0.1 .5 .5],'color','white');
imagesc(DEM);colorbar
%% SPACE: river incision paramters
p.FlowDir='single';
p.DrainDir='variable';
p.K_bed=5e-4;
p.K_sed=p.K_bed*2;
p.Ff=0;
p.V=2;
p.V_Lakes=10;
p.H_star=2;
p.m=0.5;
p.n=1;

%% Landsliding
p.FlowDirHill='multi';
p.LS_Bed=true;
p.t_LS=2e4;
p.Sc_fixed=.78;%larsen:long term high ex = 37degr mode, short 39
p.maxLS_Size=1e9;
p.min_HillGrad=tand(0.01);
p.C_eff=15e3;%Pa
p.Ff_Hill=0.25;
%% Initialize parameter structure
p   = HYLANDS_set(p);

%% If resultdir does not exist; make it
if  ~exist(p.resultsdir,'dir')
    mkdir(p.resultsdir)
end

%% Model run
output = HYLANDS(DEM,T,p,'iniSed',iniSed);


