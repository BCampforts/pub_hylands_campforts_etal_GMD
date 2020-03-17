% HyLands_NoLS_Mixed simulation with of HyLands Hybrid Landscape evolution
%   model
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
% addpath(genpath('C:\path\to\wherever\you\installed\this\topotoolbox-v2.4-HyLands-v1.0'))

%% Temporal domain
p.TimeSpan=200e3;
p.TimeStep=10;
p.ploteach=100;
p.saveeach=100;

%% Check for mass balance
% Check overall mass balance
p.checkMB=true;

%% Plotting and output
% verbose
p.verbose=false;
% Kind of plot: For regular TTLEM output (p.plotSed=false;)
p.plotSed=true;

%% Initial Surface
% Generate random initial surface of 0m � 50m
dx=100;%m
Lx=2e3;
Ly=2e3;
x=0:dx:Lx-dx;
y=0:dx:Ly-dx;
Z=zeros(numel(y),numel(x));
DEMIni=GRIDobj(x,y,Z);
[x,y]=getcoordinates(DEMIni);
[X,Y]=meshgrid(x,y);
dist=sqrt(X.^2+Y.^2);
DEMIni.Z=X/1e5+Y/1e5+rand(size(X))/100000;
DEMIni.Z(end,1)=0;
iniSedThickness=0;
iniSed=GRIDobj(DEMIni)+iniSedThickness;

%% Vertical uplift
p.U_type='uniform';
UplRate=1e-4;
T.spatial = GRIDobj(DEMIni)+UplRate;

%% Boundary conditions
% Drain towards lower left corner
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

%% SPACE: river incision paramters
p.FlowDir='single';
p.DrainDir='variable';
p.K_bed=0.005;
p.K_sed=0.01;
p.Ff=0;
p.V=5;
p.H_star=1;
p.m=0.5;
p.n=1;

%% Initialize parameter structure
p   = HYLANDS_set(p);

%% If resultdir does not exist; make it
if  ~exist(p.resultsdir,'dir')
    mkdir(p.resultsdir)
end

%% Model run
output = HYLANDS(DEMIni,T,p,'iniSed',iniSed);

