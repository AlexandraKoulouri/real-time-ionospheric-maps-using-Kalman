function  [s_hat,coef,NodeInd] = fun_estimate_S4_in_mesh(Elem,Nodes, x,y,S) %,coef,NodeInd]

%find the nodes which are closest (x,y) first
%Estimate S_4 values on a (x,y) give some fixed S values on a mesh defined
%by nodes and elements
%x is the longitude
%y is the latitude
El_c =squeeze(mean(reshape(Nodes(Elem',:)',2,3,size(Elem,1)),2))';

for ii = 1:length(x)
   
   R_temp =  distance(El_c (:,1),El_c (:,2),x(ii),y(ii));
  % indmin = find(R_temp ==min(R_temp)); 
      
   [~,IndE]= sort(R_temp);
   
   indElem = IndE(1:10);
   %find the closest elements
    %indElem = find(Elem(:,1)==indmin | Elem(:,2)==indmin | Elem(:,3)==indmin);
    
  
    Bool = 0;
    %find the closest elements to (x,y) 
    for j = 1:length(indElem)
    
        xv = [Nodes(Elem(indElem(j),:),1);Nodes(Elem(indElem(j),1),1)];
        yv = [Nodes(Elem(indElem(j),:),2); Nodes(Elem(indElem(j),1),2)];
       
    
    %check if x,y is located inside the selected element
   
            if inpolygon(x(ii),y(ii),[xv;xv(1);],[yv;yv(1)])

                        %if it is located then estimate the Barycentric
                        %coordinates
                        
                        cc = BarycentricCoefficients(x(ii),y(ii),Nodes(Elem(indElem(j),:),1),Nodes(Elem(indElem(j),:),2)); %find the barycentric coordinates for this IPP   
                        l1 = cc(1);
                        l2 = cc(2);
                        l3 = 1-cc(1)-cc(2);
                        Sv=S(Elem(indElem(j),:));
                        s_hat(ii) = l1*Sv(1)+l2*Sv(2)+l3*Sv(3);
                        coef(ii,:)=[l1 l2 l3];
                        NodeInd(ii,:) = Elem(indElem(j),:);

                        Bool = 1;
                        
%                         triplot(Elem,Nodes(:,1),Nodes(:,2),'b');
%                         hold on
%                         plot(x,y,'rx')
                     break;     
            end
  
        
         
        
    end
    if Bool ==0
      indmin = find(R_temp ==min(R_temp)); 
      dd= (Nodes(Elem(indmin,:),1)-x(ii)).^2+(Nodes(Elem(indmin,:),2)-y(ii)).^2;
      select_i= find(dd==min(dd));
       s_hat(ii) = S(Elem(indmin,select_i));
       coef(ii)=1;
       NodeInd(ii)=Elem(indmin,select_i);
        
    end

    xv = []; yv = []; 
 end

%G = G'; 


function R = distance(x,y,x0,y0)

R = (x-x0).*(x-x0) + (y-y0).*(y-y0);
% if R<1e-4
