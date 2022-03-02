function  [A,Y,Var_n] = fun_IonosphericModel_mesh(Elem,Nodes,IPP_geo,svid_id,st_id,Links,S4)
%This functions takes as an input the locations IPPs, the corresponding
%Links ground based station - satellite  and S4 scintillation values

%Outputs: 
%ionospheric projection matrix ( based on linear basis function
%): A, that relates a points on a fixed grid
%with the available observations at the IPPs
%Vector Y: assinge the observed S4 values to the corresponding links (each
%elements of Y correspond to one link
%Var_n: estimated fluctuation/error between S4 values that are in nearby
%IPPs

%this code was created by A.Koulouri 18.8.2018

NumLinks = size(Links,1);

A = sparse(NumLinks,size(Nodes,1)); %projection matrix
i = 1;
j = 1;

Y = zeros(NumLinks,1); %S4 effected values on the ionosphere (observations)
Counts = zeros(size(Y,1),1);
LinkInd=[];
LinkIndVec=[];
% figure
% triplot(Elem,Nodes(:,1),Nodes(:,2));
% hold on

Var_n = [];
 for j = 1:size(Elem,1) 

   %find the IPPs which is located in the triangle defined by Nodes of the
   %elements
   
    xv = [Nodes(Elem(j,:),1);Nodes(Elem(j,1),1)];
    yv = [Nodes(Elem(j,:),2); Nodes(Elem(j,1),2)];
       
    Ind =  find(inpolygon(IPP_geo(:,1),IPP_geo(:,2),[xv;xv(1);],[yv;yv(1)]));
    if ~isempty(Ind) 
               
       Data = S4(Ind);
       Linkstruct = [];
       RemoveInd = [];
       CountN = [];
       if length(Ind) >1 %check how far are the two traces (if close pick one of the two) (like unique(row) but with tolerance
           
            [~,CountN] = consolidator13([IPP_geo(Ind,:)],[],[],1e-4);
            if length(CountN)<length(Ind)
            ii=1;
                while ii<=length(Ind)-1
                    jj = ii+1;
                    while jj>=ii+1 && jj<=length(Ind)
                        R = distance(IPP_geo(Ind(ii),1),IPP_geo(Ind(ii),2),IPP_geo(Ind(jj),1),IPP_geo(Ind(jj),2));
                         wgs84 = wgs84Ellipsoid('meter'); %Earth spheroid
                        % Rad = wgs84.MeanRadius+220000*10^3;
                        
                        if (R<1e-5) %if points too close
%                             [x_st1,y_st1,z_st1] = Geodetic2Geocentric(IPP_geo(Ind(ii),1),IPP_geo(Ind(ii),2),Rad);
%                             [x_st2,y_st2,z_st2] = Geodetic2Geocentric(IPP_geo(Ind(jj),1),IPP_geo(Ind(jj),2),Rad);
%                             ddd = sqrt((x_st1-x_st2).^2+(y_st1-y_st2).^2+(z_st1-z_st2).^2)
                            Var_n = [Data(ii) - Data(jj);Var_n];
                            RemoveInd = [RemoveInd;jj];
                        end
                        jj = jj+1;

                    end
                    Data(ii) = mean(S4(Ind([ii;RemoveInd])));
                    KeepInd = setdiff(1:length(Ind),RemoveInd);
                    Data(RemoveInd)  = [];%S4(Ind(KeepInd));
                    Ind = Ind(KeepInd);
                    KeepInd = [];
                    RemoveInd = [];
                    ii = ii+1;
                end
                
                %Remove IPPs which are very close to each other and
                %estimate also the error
               
%                 disp('different S4 for the same point')
%                 error = [error; ]   
%                 IndKeep = find(Counts>1);
%                 Ind = Ind(Counts);  
%                 Counts =[]; 
                end
            end
          
            
          
       
        for l = 1:length(Ind) 

            LinkInd = find(st_id(Ind(l))== Links(:,1) & svid_id(Ind(l)) == Links(:,2));
            Linkstruct = [LinkInd;Linkstruct];
             if isempty(LinkInd)
               disp('a link was not included! check')
             else
             
%                plot(IPP_geo(Ind(l),1),IPP_geo(Ind(l),2),'or')
%                plot(Nodes(Elem(j,:),1),Nodes(Elem(j,:),2))
                cc = BarycentricCoefficients(IPP_geo(Ind(l),1),IPP_geo(Ind(l),2),Nodes(Elem(j,:),1),Nodes(Elem(j,:),2)); %find the barycentric coordinates for this IPP   
                A(LinkInd,Elem(j,1)) = cc(1) ;%
                A(LinkInd,Elem(j,2)) = cc(2);% 
                A(LinkInd,Elem(j,3)) = 1-cc(1)-cc(2) ;%
            
                Y(LinkInd(1)) = Data(l);%+Y(LinkInd(1));
                Counts(LinkInd(1)) = Counts(LinkInd(1)) +1;
               
             end
       end
  
        
         
        IPP_geo(Ind,:) = []; %remove the used points
        st_id(Ind) = [];      
        svid_id(Ind) =[];
        S4(Ind) = [];
        LinkInd=[];%Ind = [];LinkInd_temp=[];
    end


    xv = []; yv = []; 
 end

%G = G'; 


function R = distance(x,y,x0,y0)

R = (x-x0).*(x-x0) + (y-y0).*(y-y0);
% if R<1e-4
    



