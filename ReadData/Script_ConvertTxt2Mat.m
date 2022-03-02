%This is to read the txt data with the IPP details and the locations of the ground stations and convert is to mat files 

%Insert data of particular period of time
%http://is-cigala-calibra.fct.unesp.br/is/ismrtool/map/service_getMapIppPoints.php?date_begin=2014-10-01 22:00:00&date_end=2014-10-01 22:10:00&satellite=GPS,GLONASS&station=5,6,8&filters=elev%3E=20;&field=s4&aggregation=none&ion=350&mode=csv

%station coordinates returns this link (st_list 5 and 6 stations)
%http://is-cigala-calibra.fct.unesp.br/is/stations/getStationCoord.php?st_list=5,6&mode=csv
close all;
clear all;

cd ..
addpath(genpath(cd));

%% Read the stations (locations and idds)
n=2;
S=fileread('data/StationLocations.txt');
L=[1 regexp(S,'\n') length(S)+1]';
nLines=length(L)-n-1;
%T=cell(nLines,1);
%break string of characters into rows and columns
Stations=cell(nLines,4);
for ii=1:nLines
    T=S(L(n+ii):L(n+ii+1)-1);
    Temp=regexp(T,',','Split');
    Temp(cellfun('isempty',Temp))=[];
    Stations(ii,:)=Temp;
    Station_id(ii) = str2num(Temp{1,4});
    Station_Lat(ii) = str2num(Temp{1,2});
    Station_Lon(ii) = str2num(Temp{1,3});
end
save data/StationMAT.mat Station_id Station_Lat Station_Lon


clear Temp T L nLines

%define time intervals and download IPP data 
date_begin = '2014-11-03 22:00:00';
date_end   = '2014-11-03 22:10:00';
% station = AllStations;
% satellite = 'GPS,GLONASS,GALILEO,SBAS',
% filters = 'elev>=20;',
% field= 's4';
% aggregation='none',
% ion='35';
% mode='csv';
% PathIPP = ['http://is-cigala-calibra.fct.unesp.br/is/ismrtool/map/service_getMapIppPoints.php?date_begin=2014-10-01 22:00:00&date_end=2014-10-01 22:10:00&satellite=GPS,GLONASS&station='];
% PathIPP = [PathIPP num2str(AllStations(1))];
% for i = 1:length(AllStations)
%     PathIPP = [PathIPP,',' num2str(AllStations(i))];
%         
% end
% PathIPP = [PathIPP '&filters=elev%3E=20;&field=s4&aggregation=none&ion=350&mode=csv'];
%http://is-cigala-calibra.fct.unesp.br/is/ismrtool/map/service_getMapIppPoints.php?date_begin=2014-10-01 22:00:00&date_end=2014-10-01 22:10:00&satellite=GPS,GLONASS&station=5,6,8&filters=elev%3E=20;&field=s4&aggregation=none&ion=350&mode=csv
 n=2;
S=fileread('data/IPP_Data_2014_11_03_18_to_ 23_55.txt');
%S=fileread('data/IPPData.txt');
L=[1 regexp(S,'\n') length(S)+1]';
nLines=length(L)-n-1;
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
            K = double(Svid{ii}(2))*10;
        case 'E'
            K = double(Svid{ii}(2))*100;
        case 'S'
           K = double(Svid{ii}(2))*1000;
        case 'G'
          K = double(Svid{ii}(2))*10000;
        otherwise
            disp('not specified')
    end
    Svid_ar(ii) =K+str2num(Svid{ii}(3:end));
    IPPLat(ii) = str2num(Temp{1,2});
    IPPLon(ii) = str2num(Temp{1,3});
    S4(ii) =  str2num(Temp{1,4});
    Time(ii) = datenum(Temp{1,5});%Temp{1,5};
    StationId(ii) = str2num(Temp{1,6});
    IPPs(ii,:)=Temp;
end

Time = Time-Time(1);
Time = Time*1440;
TisavenameIPP = ['IPPData'];%%,' ',date_begin,' ',date_begin];
 save data/IPP_long Time StationId IPPLat IPPLon S4 Svid Svid_ar IPPs

% datenum ->convert to a serier of numbers
% datestr(ans)->to convert to a time string formation
% Res = 2;
% 
% [PixVal_x,PixVal_y, Cell_IPP] = IPPinPixels(Res,IPPs,LatLim,LonLim);
% 

% datenum

%assign in pixels

%estimate probabilities

%draw maps