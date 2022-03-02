function[S_w,S,Gamma_post,Gamma_post_w_temp,w,max_alpha,Gamma_post_w_num]= fun_weighted_map(Elem,Nodes,Lon_ob,Lat_ob,Svid_ob,StationId_ob,Links,S4_ob,var_n,var_e,L,alpha,Gamma_post_w,s_w,S4_SBAS,Lon_SBAS,Lat_SBAS,w);

%This function is the implementation of the algorithm presented in 
%doi: 10.1109/TGRS.2022.3140600.
%Created by A. Koulouri 18.2.2019

N = length(Nodes);
Reg = length(alpha);
S = zeros(N,length(alpha));

%Estimate linear basis function matrix A and create observation vector y using observed S_4 
[A,y] = fun_IonosphericModel_mesh(Elem,Nodes,[Lon_ob(:) Lat_ob(:)],Svid_ob,StationId_ob,Links,S4_ob);

%remove empty columns
y(sum(A,2)==0) =[];
A(sum(A,2)==0,:)=[];
At = A';
Lt = L';


invGamma_pred = inv(var_n*eye(N)+Gamma_post_w);
stemp = s_w; %#ok<*MINV>

for iterReg = 1:Reg  %Estimate a map for each alpha regularization at time t


   Gamma_post(:,:,iterReg) = inv(At*A/var_e+alpha(iterReg)*(Lt*L)+invGamma_pred);  %#ok<AGROW>
   
   S_temp =Gamma_post(:,:,iterReg)*(At/var_e*y+invGamma_pred*stemp);
   S_temp(S_temp>1) = 1;
   
  S_temp(S_temp<0) = 0;
  S(:,iterReg)=S_temp;
end

%w = [];
%Estimate the weighted solution!
if ~isempty(S4_SBAS)
    %for each map (corresponding to a single regularization
   %parameter estimate a) estimate y_hat

   y_hat=[];    y_true=[];    y_true_rep =[];    
   y_true = S4_SBAS;

   %run this paralle
   for iterReg = 1:length(alpha)
        y_hat(:,iterReg) = fun_estimate_S4_in_mesh(Elem,Nodes, Lon_SBAS, Lat_SBAS,S(:,iterReg))'; 

   end
   y_true_rep =  repmat(y_true,1,length(alpha));

    residual_t =  y_true_rep - y_hat;
   % var_residual = var(residual_t(:));
    C_t = cov(residual_t');
    DiagCov=diag(C_t);

       %Gaussian
     % sigma_t = var_residual;
      % sigma_t = max(2*1e-2,min(mean(sqrt(DiagCov))^2,1));%(prod(DiagCov))^(1/size(C_t,1));%%
      % w =  exp(-1/sigma_t*diag((residual_t')*(residual_t)));
      % w =  exp(-diag(residual_t'*diag(DiagCov.^(-1))*residual_t));

      %Laplace
       kappa=repmat(1./sqrt(2*DiagCov),1,length(alpha));
     %kappa=repmat(1./sqrt(2*DiagCov)',length(alpha),1);
     %kappa = repmat(1./sqrt(2*DiagCov)',size(residual_t,1),1);
     w = exp(-sum(kappa.*abs(residual_t),1))';


end


if max(w)<1e-26 
          w = zeros(length(alpha),1)+1/length(alpha); %equalize

 else
     
    w = w./sum(w);  

end

%% ESTIMATED WEIGHTED MEAN AND COVARIANCE!  
  S_w = S*w(:);
  V2 = sum(w.^2);
 
 Gamma_post_w_temp = zeros(N,N);
  Gamma_post_w_temp_num =  Gamma_post_w_temp;
 for iterReg = 1:length(alpha)
     Gamma_post_w_temp =  Gamma_post_w_temp+w(iterReg)* Gamma_post(:,:,iterReg)+ w(iterReg)*(S(:,iterReg)-S_w)*(S(:,iterReg)-S_w )'; %#ok<SAGROW>
     Gamma_post_w_temp_num =  Gamma_post_w_temp_num+ w(iterReg)*(S(:,iterReg)-S_w)*(S(:,iterReg)-S_w )'; %#ok<SAGROW>
 end
Gamma_post_w_temp(abs(Gamma_post_w_temp)<1e-8)=0;
%Gamma_post_w_temp_num(abs(Gamma_post_w_temp_num)<1e-8)=0;
Gamma_post_w = (Gamma_post_w_temp); %#ok<NASGU>
Gamma_post_w_num = Gamma_post_w_temp_num/(1-V2); 

 %Var_w = diag(Gamma_post_w); 
 ind_max = find(w==max(w));
 max_alpha=alpha(ind_max(1));
