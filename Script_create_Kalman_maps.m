%clear all;

%Run code to produce instant ionospheric scintillation maps in South
%America
%Please cite my work: https://ieeexplore.ieee.org/document/9672195
%Created by A. Koulouri 2.3.2022

addpath(genpath(cd));

 clear all;
 close all;


%% Load S4 Data give the data path of the  observations (S4) in Southe America
filename_path = cd;
filename_path_load_ipps = [filename_path,'\data\'];
LoadData = dir(filename_path_load_ipps);
IPPdata =  LoadData(3).name ;   
filename_path_data = [filename_path_load_ipps,IPPdata]; 


[Begin_interval,End_interval,S4t,StationId,IPPLat,IPPLon,S4,Svid_ar,IPPs] = LoadIPPData(filename_path_data,IPPdata);
%Begin_interval: time instant of the first downloaded S4 observation
%End_interval : instant of the last S4 observation
% S4t: time of each measurement S4
% S4: s4 scintillation measurements
% (IPPLat, IPPLon) ionospheric pierce point of S4 at time S4t
% (StationID,Svid_ar) : link between a ground station and satellite at each time S4t 

%% Time interval to study
%time S4t (that each S4 has been estimated) has been calculated with respect to the refernece time instant
time_ref = datenum(IPPs{1,5});


  epoch_ini   = '2014-11-02 22:30:00'; 
  epoch_end   = '2014-11-03 03:30:00';
 
 t1 =  datenum(epoch_ini); 
 t2 = datenum(epoch_end);
 t1_min_begin = (t1-time_ref)*1440; %estimate time elapsed from the starting point of data collection and convert into minutes
 t2_min_end   = (t2-time_ref)*1440;
 
%indices of the first and the last measurement (this is different than the 1st and last element if the epoch_ini,end are different than the total interval  
begin_ind = find(abs(S4t-t1_min_begin) == min(abs(S4t-t1_min_begin)));
end_ind = find(abs(S4t-t2_min_end) == min(abs(S4t-t2_min_end )));
IndDataInterval = [begin_ind(1):end_ind(end)];


%% load the domain of interest (ionosphere in triangularion)
load TriMesh_southAmerica.mat

  
%% Laplacian prior and Ensemble of regularization parameters

%Estimate the Laplace smoothness prior
L = fun_DiscreteLaplace(Nodes,Elem,3);
%alpha = [1e-3 1e-2 1e-1 1 10 20 50 80 100 200 300 400 500]; 
alpha=logspace(-3,log10(500), 5);%13);
 
 
%% Held out SBAS satellites data used for weighting
load indicesOfControlData.mat % go to Script_control_data_selection.m if you want to modify for another time interval

Data_control.IPPLon = IPPLon(IndDataInterval(IndSBAS));
Data_control.IPPLat  = IPPLat(IndDataInterval(IndSBAS));
Data_control.Svid_ar = Svid_ar(IndDataInterval(IndSBAS));
Data_control.StationId =  StationId(IndDataInterval(IndSBAS));
Data_control.S4t = S4t(IndDataInterval(IndSBAS));
Data_control.S4 = S4(IndDataInterval(IndSBAS));


%% define the available data of this particular DataInterval to be used for the maps estimation

IndDataInterval(IndSBAS(:)) =[]; %remove the control data since it will not be used for the maps construction

 
Data_for_maps.IPPLon = IPPLon(IndDataInterval);
Data_for_maps.IPPLat = IPPLat(IndDataInterval);
Data_for_maps.Svid_ar = Svid_ar(IndDataInterval);
Data_for_maps.StationId = StationId(IndDataInterval);
Data_for_maps.S4t = S4t(IndDataInterval);
Data_for_maps.S4 = S4(IndDataInterval);
Data_for_maps.Links  = [Data_for_maps.StationId(:),Data_for_maps.Svid_ar(:)];
Data_for_maps.Links = unique(Data_for_maps.Links,'rows');

 
 %% Run the Ensemble of Kalman filters

 %estimate weighted scintillation maps S4_w and their corresponded created
 %instant T

[S4_w,T] = fun_Kalman_maps(Nodes, Elem, alpha, L,  t1_min_begin, t2_min_end, Data_for_maps,Data_control,time_ref);

% Note: To find the actualt time instant in UT use: t= datestr( (T(1)/1440+time_ref),0,0);               
 
 