%This scipt create the http paths to download data from South America
%also it download the IPP data for the specified dates.
%Insert data of particular period of time
%http://is-cigala-calibra.fct.unesp.br/is/ismrtool/map/service_getMapIppPoints.php?date_begin=2014-10-01 22:00:00&date_end=2014-10-01 22:10:00&satellite=GPS,GLONASS&station=5,6,8&filters=elev%3E=20;&field=s4&aggregation=none&ion=350&mode=csv

%station coordinates returns this link (st_list 5 and 6 stations)
%http://is-cigala-calibra.fct.unesp.br/is/stations/getStationCoord.php?st_list=5,6&mode=csv

close all;
clear all;

cd ..\
addpath(genpath(cd));

%% Create Link to download  Ground station data

host_st_list='http://is-cigala-calibra.fct.unesp.br/is/stations/getStationCoord.php';

%Insert stations
cigala_st =  [24,25,11,37,1,15,28,2,3,4,5,6,14,7,8,29,26];
lisn_st   = [46,47,48,49,50,51,52,53,54,55,56,57,58,59,61,62,63,64,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87];
icea_st   = [45,33,44,41,32,30,31,34,43,42];
% Select all stations 
 AllStations = [cigala_st lisn_st icea_st ];
 mode='csv'; 
% %read the path
 PathStations = ['http://is-cigala-calibra.fct.unesp.br/is/stations/getStationCoord.php?st_list='];
 PathStations = [PathStations num2str(AllStations(1))];
for i = 1:length(AllStations)
    PathStations = [PathStations,',' num2str(AllStations(i))];
        
end
PathStations = [ PathStations,'&mode=csv'];

%maybe use urlread() to download the data...otherwise copy and paste the
%PathStations to your browser to dowload the station details



%% Create the link to download data for a particular period of time
host_service='http://is-cigala-calibra.fct.unesp.br/is/ismrtool/map/service_getMapIppPoints.php';
%define time intervals and download IPP data 
date_begin = '2014-11-01 21:00:00';
date_end   = '2014-11-02 04:00:00';
station = AllStations;
satellite = 'GPS,GLONASS,GALILEO,SBAS';
filters = 'elev>=20;';
field= 's4';
aggregation='none';
ion='35';
mode='csv';
 PathIPP = ['http://is-cigala-calibra.fct.unesp.br/is/ismrtool/map/service_getMapIppPoints.php?date_begin=',date_begin,'&date_end=',date_end,'&satellite=',satellite,'&station='];
 PathIPP = [PathIPP num2str(AllStations(1))];
 for i = 1:length(AllStations)
    PathIPP = [PathIPP,',' num2str(AllStations(i))];
        
end
 PathIPP = [PathIPP '&filters=elev%3E=20;&field=s4&aggregation=none&ion=350&mode=csv'];
%http://is-cigala-calibra.fct.unesp.br/is/ismrtool/map/service_getMapIppPoints.php?date_begin=2014-10-01 22:00:00&date_end=2014-10-01 22:10:00&satellite=GPS,GLONASS&station=5,6,8&filters=elev%3E=20;&field=s4&aggregation=none&ion=350&mode=csv

%Download the IPP data from the specified link PathIPP
options = weboptions('RequestMethod','get','timeout',Inf); 
S = webread(PathIPP,options);

n=2;
L=[1 regexp(S,'\n') length(S)+1]';
nLines=length(L)-15-1-n;
%break string of characters into rows and columns
IPPs=cell(nLines,6);
Svid = cell(nLines,1);
Time = zeros(nLines,1);
for ii=1:nLines
    T=S(L(n+ii):L(n+ii+1)-1);
    Temp=regexp(T,', ','Split');
    Temp(cellfun('isempty',Temp))=[];
    Svid{ii} = Temp{1,1};
    switch Svid{ii}(2) 
        case 'R'
            K = double(Svid{ii}(2))*10;%GLONASS
        case 'E'
            K = double(Svid{ii}(2))*100;%GALILEO
        case 'S'
           K = double(Svid{ii}(2))*1000;%SBAS
        case 'G'
          K = double(Svid{ii}(2))*10000;%GPS
        otherwise
            disp('not specified')
    end
    Svid_ar(ii) =K+str2num(Svid{ii}(3:end));
    IPPLat(ii) = str2num(Temp{1,2});
    IPPLon(ii) = str2num(Temp{1,3});
    S4(ii) =  str2num(Temp{1,4});
    Time(ii) = datenum(Temp{1,5});%Temp{1,5}; %convert time to arithmetic
    StationId(ii) = str2num(Temp{1,6});
    IPPs(ii,:)=Temp;
end

Time = Time-Time(1); %set time starting from Time(1);
Time = Time*1440;    %convert to minutes

Split_date_begin = regexp(regexp(date_begin,' ','Split'),':','Split');
Split_date_end = regexp(regexp(date_end,' ','Split'),':','Split');
savename = ['IPPdata_Begin_',Split_date_begin{1}{1},'_',Split_date_begin{2}{1},'_',Split_date_begin{2}{2},'_',Split_date_begin{2}{3},'_End_',Split_date_end{1}{1},'_',Split_date_end{2}{1},'_',Split_date_end{2}{2},'_',Split_date_end{2}{3},'.mat'];
matfile = fullfile('data/', savename);
%Save data in .mat
save(matfile, 'Time', 'StationId', 'IPPLat', 'IPPLon', 'S4', 'Svid', 'Svid_ar', 'IPPs')
%save matfile Time StationId IPPLat IPPLon S4 Svid Svid_ar IPPs



