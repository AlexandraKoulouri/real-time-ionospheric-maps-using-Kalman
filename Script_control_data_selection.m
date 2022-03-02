%Define the data that will be held out for control or weighting

%created by A. Koulouri 20.2.2022
filename_path = cd;
filename_path_load_ipps = [filename_path,'\data\'];
LoadData = dir(filename_path_load_ipps);
IPPdata =  LoadData(3).name ;   
filename_path_data = [filename_path_load_ipps,IPPdata]; 

[Begin_interval,End_interval,S4t,StationId,IPPLat,IPPLon,S4,Svid_ar,IPPs] = LoadIPPData(filename_path_data,IPPdata);


%% Time interval to study
%S4t has been estimated with respect to the refernece time instant
time_ref = datenum(IPPs{1,5});


%   epoch_ini   =  '2014-12-01 20:00:00'; 
%   epoch_end   =  '2014-12-02 05:30:00';
 
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

IndSBAS = [find(Svid_ar(IndDataInterval)==83120 & StationId(IndDataInterval)== 54)'];
IndSBAS = [IndSBAS;find(Svid_ar(IndDataInterval)==83120 & StationId(IndDataInterval)== 4)'];
IndSBAS = [IndSBAS;find(Svid_ar(IndDataInterval)==83120 & StationId(IndDataInterval)== 77)'];
IndSBAS = [IndSBAS;find(Svid_ar(IndDataInterval)==83135 & StationId(IndDataInterval)== 6)'];
IndSBAS = [IndSBAS;find(Svid_ar(IndDataInterval)==83120 & StationId(IndDataInterval)== 63)'];
IndSBAS = [IndSBAS;find(Svid_ar(IndDataInterval)==83136 & StationId(IndDataInterval)== 66)'];
IndSBAS = [IndSBAS;find(Svid_ar(IndDataInterval)==83136 & StationId(IndDataInterval)== 83)'];
IndSBAS = [IndSBAS;find(Svid_ar(IndDataInterval)==83120 & StationId(IndDataInterval)== 83)'];
IndSBAS = [IndSBAS;find(Svid_ar(IndDataInterval)==83120 & StationId(IndDataInterval)== 66)'];
IndSBAS = [IndSBAS;find(Svid_ar(IndDataInterval)==83133 & StationId(IndDataInterval)== 25)'];
%IndSBAS = [IndSBAS;find(Svid_ar(IndDataInterval)==83120 & StationId(IndDataInterval)== 74)'];
IndSBAS = [IndSBAS;find(Svid_ar(IndDataInterval)==83120 & StationId(IndDataInterval)== 61)'];
IndSBAS = [IndSBAS;find(Svid_ar(IndDataInterval)==83135 & StationId(IndDataInterval)== 86)'];
IndSBAS = [IndSBAS;find(Svid_ar(IndDataInterval)==83120 & StationId(IndDataInterval)== 53)'];
IndSBAS = [IndSBAS;find(Svid_ar(IndDataInterval)==83133 & StationId(IndDataInterval)== 81)'];
IndSBAS = [IndSBAS;find(Svid_ar(IndDataInterval)==83120 & StationId(IndDataInterval)== 80)'];
IndSBAS = [IndSBAS;find(Svid_ar(IndDataInterval)==83120 & StationId(IndDataInterval)== 11)'];
IndSBAS = [IndSBAS;find(Svid_ar(IndDataInterval)==83120 & StationId(IndDataInterval)== 8)'];
IndSBAS = [IndSBAS;find(Svid_ar(IndDataInterval)==83133 & StationId(IndDataInterval)== 24)'];
IndSBAS = [IndSBAS;find(Svid_ar(IndDataInterval)==83136 & StationId(IndDataInterval)== 24)'];
IndSBAS = [IndSBAS;find(Svid_ar(IndDataInterval)==83120 & StationId(IndDataInterval)== 47)'];
IndSBAS = [IndSBAS;find(Svid_ar(IndDataInterval)==83138 & StationId(IndDataInterval)== 80)'];
IndSBAS = [IndSBAS;find(Svid_ar(IndDataInterval)==83138 & StationId(IndDataInterval)== 83)'];
IndSBAS = [IndSBAS;find(Svid_ar(IndDataInterval)==83138 & StationId(IndDataInterval)== 81)'];
IndSBAS = [IndSBAS;find(Svid_ar(IndDataInterval)==83138 & StationId(IndDataInterval)== 53)'];
save indicesOfControlData IndSBAS