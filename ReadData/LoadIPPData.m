function [Begin_interval,End_interval,Time,StationId,IPPLat,IPPLon,S4,Svid_ar,IPPs] = LoadIPPData(filename_path_data,IPPdata)

%data, 'Time', 'StationId', 'IPPLat', 'IPPLon', 'S4', 'Svid', 'Svid_ar', 'IPPs')
load (filename_path_data)


Split_name =  regexp(regexp(IPPdata,'.mat','Split'),'_End_','Split');
Split_begin = regexp(Split_name{1}{1},'IPPdata_Begin_','Split');
End_interval = Split_name{1}{2};
Begin_interval = Split_begin{2};
End_interval(11)= ' ';End_interval(14) =':'; End_interval(17)=':';
Begin_interval(11)=' '; Begin_interval(14) =':'; Begin_interval(17)=':';