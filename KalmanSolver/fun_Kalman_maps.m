function [S_w,T] = fun_Kalman_maps(Nodes, Elem, alpha, L,  t1_min_begin, t2_min_end, Data_maps,Data_control,time_ref)

 
%Return the weighted Kalman map and the corresponding time instant
%created by A. Koulouri 19.2.2020

%% Initialization for scintillation maps 
S = zeros(size(Nodes,1),length(alpha));
S_w = zeros(size(S,1),1);
S_components_iter=zeros(size(S,1),size(S,2),1);
%Covariance matrix
Gamma_post = zeros(size(Nodes,1),size(Nodes,1),length(alpha));
Gamma_w = zeros(size(Nodes,1),size(Nodes,1));
Gamma_w_num =  zeros(size(Nodes,1),size(Nodes,1));
%w=ones(size(alpha,2),1)/size(alpha,1);
w = zeros(length(alpha),1)+1/length(alpha); %equal weight
var_n =  0.0018;%18; %noise variance for the evolution model
var_e =  0.0018;%19;  %noise variance for the observation model
Mask_iter = zeros(length(S_w),1);
 
 
 %Go minute by minute and use the available data to build the map!
 Iter = 1;
 T = 0;
 t2_min = 0.99+ t1_min_begin;
 t1_min =  t1_min_begin;

 
 while t2_min<= t2_min_end


   DataIntervali = find(Data_maps.S4t>=t1_min & Data_maps.S4t<t2_min); %avaliable data in minute [t2-t1]
       
     
   Ind_SBAS_control = find(Data_control.S4t>=t1_min & Data_control.S4t<=t2_min); %SBAS data used for weighting
    

    if ~isempty(DataIntervali) && ~isempty(Ind_SBAS_control)      %Update the map! 
         [S_w,S,~,Gamma_w,w,~,Gamma_w_num]= fun_weighted_map(Elem,Nodes(:,1:2),Data_maps.IPPLon(DataIntervali),Data_maps.IPPLat(DataIntervali),Data_maps.Svid_ar(DataIntervali),Data_maps.StationId(DataIntervali),Data_maps.Links,Data_maps.S4(DataIntervali),var_n,var_e,L,alpha,Gamma_w,S_w,Data_control.S4(Ind_SBAS_control)',Data_control.IPPLon(Ind_SBAS_control),Data_control.IPPLat(Ind_SBAS_control),w);
        
    
    end

    %S_w_iter(:,Iter) = S_w; %#ok<SAGROW> %WEIGHTED MEAN
    %w_iter(:,Iter) = w; %#ok<SAGROW>
    S_components_iter(:,:,Iter) = S; 
    T(Iter) = 0.5*(t2_min-t1_min)+t1_min;  %#ok<SAGROW>
    % Gamma_w_num_iter(:,:,Iter) = Gamma_w_num;  %#ok<SAGROW>
    %Update the time interval
    t1_min = t2_min;
    t2_min = t2_min+1;

    if t2_min>=t2_min_end 
        break; %stop when reach last minute
    end

% Plot map at a particular instant
   figure (1)
            t1str= datestr( (T(Iter)/1440+time_ref),0,0);               
              t1str = [t1str,' UT'];
             PlotSaveFig_tri_project_v2(Elem,Nodes(:,1),Nodes(:,2),S_w,'test','Ionospheric Scintillation Map',t1str,t1str,1,1,1);


    
    Iter = Iter+1;
    
    
    
end
