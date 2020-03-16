% HyLands_LS_OpenBoundaries
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
p.TimeSpan=20e6;
p.TimeStep=500;

%% Save and plot
p.ploteach=50;
p.saveeach=inf;
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
% Generate random initial surface of 0m � 50m
dx=15;%m
Lx=1500;
Ly=1500;
x=0:dx:Lx-dx;
y=0:dx:Ly-dx;
Z=zeros(numel(y),numel(x));
DEMIni=GRIDobj(x,y,Z);
[x,y]=getcoordinates(DEMIni);
[X,Y]=meshgrid(x,y);
dist=sqrt(X.^2+Y.^2);
DEMIni.Z=rand(DEMIni.size)*0.0001;
iniSedThickness=0;
iniSed=GRIDobj(DEMIni)+iniSedThickness;
%% Vertical uplift
p.U_type='uniform';
UplRate=1e-3;
T.spatial = GRIDobj(DEMIni)+UplRate;

%% Boundary conditions
p.BC_Type='Bed_Sed_Open';

%% SPACE: river incision paramters
p.FlowDir='single';
p.DrainDir='variable';
p.K_bed=5e-6;
p.K_sed=p.K_bed*2;
p.Ff=0;
p.V=1;
p.H_star=1;
p.m=0.5;
p.n=1;
%% Landsliding
p.FlowDirHill='multi';
p.LS_Bed=true;
p.t_LS=500;
p.Sc_fixed=5;%larsen:long term high ex = 37degr mode, short 39
p.maxLS_Size=1e8;
p.min_HillGrad=0.05;
p.C_eff=1e7;
p.Ff_Hill=0.5;


%% Initialize parameter structure
p   = HYLANDS_set(p);

%% If resultdir does not exist; make it
if  ~exist(p.resultsdir,'dir')
    mkdir(p.resultsdir)
end

%% Model run
output = HYLANDS(DEMIni,T,p,'iniSed',iniSed);

   
