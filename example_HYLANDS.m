% Example run of HyLands Hybrid Landscape evolution model to simulate the
% impact of landslides and landslide-derived sediment
%
% =========================================================================
% Papers to cite when using HyLands:
%
% * HyLands: Campforts B., Shobe M.C., et al. : HyLands 1.0: a Hybrid
% Landscape evolution model to simulate the impact of landslides and
% landslide-derived sediment on landscape evolution. Discussion paper in
% Geoscientific Model Development,
% https://geoscientific-model-development.net
%
% * SPACE: Shobe, C. M., Tucker, G. E., & Barnhart, K. R. (2017). The SPACE 1.0
% model: a Landlab component for 2-D calculation of sediment transport,
% bedrock erosion, and landscape evolution. Geoscientific Model
% Development, 10(12), 4577–4604. https://doi.org/10.5194/gmd-10-4577-2017
%
% * TTLEM: Campforts, B., Schwanghart, W., & Govers, G. (2017). 
% Accurate simulation of transient landscape evolution
% by eliminating numerical diffusion: the TTLEM 1.0 model. Earth Surface
% Dynamics, 5(1), 47–66. https://doi.org/10.5194/esurf-5-47-2017
%
% Other relevant references:
%
% * Carretier, S., Martinod, P., Reich, M., & Godderis, Y. (2016).
% Modelling sediment clasts transport during landscape evolution. Earth
% Surface Dynamics, 4(1), 237–251. https://doi.org/10.5194/esurf-4-237-2016
%
% * Densmore, A. L., Ellis, M. A., & Anderson, R. S. (1998). Landsliding
% and the evolution of normal-fault-bounded mountains. Journal of
% Geophysical Research: Solid Earth, 103(B7), 15203–15219.
% https://doi.org/10.1029/98JB00510
%
% =========================================================================
%
% Author:   Benjamin Campforts (benjamin.campforts@gfz-potsdam.de)
%
% Date:     15. March, 2020

%% Clear environment
clearvars
clc
close all

%% Run mode from existing DEM
load('DEMs\DEM_Yarlung_Mini.mat','DEM');
iniSed=GRIDobj(DEM);
T.spatial  = GRIDobj(DEM);
p.TimeSpan = 100;
p.TimeStep = 10;
p.ploteach = 1;
p.FlowBC='open';
p.BC_Type='Bed_Sed_Open';
p.LS_Bed   = true;
p.t_LS=5e2;
p.Sc_fixed = .8;
p   = HYLANDS_set(p);
HYLANDS_Out = HYLANDS(DEM,T,p,'iniSed',iniSed);

%% Plot Landslide characterstics
dx2=DEM.cellsize*DEM.cellsize;
bins=logspace(1,5,15);
figure; histogram([HYLANDS_Out.LS_prop_bed_store.Size]*dx2,bins);
set(gca,'YScale','log')
set(gca,'XScale','log')
xlabel('\bfArea of landslides, m^2')
ylabel('\bfNumber of landslides (#)')