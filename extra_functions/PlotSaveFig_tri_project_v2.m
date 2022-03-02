function PlotSaveFig_tri_project_v2(h,x,y,c,figureName,figtitle,begin_ep,end_ep,caxlim,optionLat,optionLon,M_rec)
MagEqu = shaperead('extra_figures/equador-brasil.shp');
load coastlines.mat
% coastlon=tmp(:,1);
% coastlat=tmp(:,2);
cmap = colormap(jet);
%set(gcf, 'Units','centimeters', 'Position',[5 5 9 8])
%cmap(1,:) = [229 227 224]./255;
c(c<=0) = eps;
% figure
% set(gcf, 'Units','centimeters', 'Position',[5 5 9 7])
 ux = linspace(min(x(:)),max(x(:)),400);
 uy = linspace(min(y(:)),max(y(:)),400);
[xc, yc] = meshgrid(ux,uy);
 xr = xc(:);
 yr = yc(:);

% M_rec = InterpolateMatrix2d(h,[x(:) y(:)],[xr(:) yr(:)]);
load Project_matrix_TriMesh
%save Project_matrix_TriMesh  M_rec
Ind_notMesh= find(sum(M_rec,1)==0);%points not inside the mesh
c_es_grid = full(M_rec*c(:));
c_es_grid(Ind_notMesh)= 0;
Img = reshape(c_es_grid,length(ux),length(uy));
h = fspecial('gaussian', 2, 1.4);
%h = fspecial('disk',1)
Img = imfilter(Img,h);



  %ineg =find(Img<0);
  % Img(ineg) = 0.001;
   izero = find(Img<=0);
   Img(izero) = NaN;
%Img = reshape(Img,length(ux),length(uy));
Img=Img(:);
%Img(Ind_notMesh)=NaN;
Img = reshape(Img,length(ux),length(uy));
%imagesc(Img)

pcolor(xc,yc,Img)
hold on;
plot(coastlon,coastlat,'k','markersize',4.5);
if optionLon ==1
xlabel('Lon','FontSize',10)
end
if optionLat ==1
ylabel('Lat','FontSize',10)
end
shading interp
plot([MagEqu(1:end).X],[MagEqu(1:end).Y],'color',[.1 0.3 0.5],'linewidth',1.1)
%text(-90,-52,begin_ep,'fontsize',12);
text(-70,13,end_ep,'fontsize',8);
%text(-80,13,end_ep,'fontsize',8);
caxis([0, caxlim(1)])
axis square
axis xy
%axis([0.3000    0.7000    0.4500    0.7000].*length(u))
%h_axis= [0.3000    0.7000    0.4500    0.7000].*length(u);
%xt(-80,-45,end_ep,'fontsize',12);

set(gca,'fontsize',7)
%  set(gca,'Xtick',[h_axis(1),h_axis(2)],'XTickLabel',{'0','1'})
%  set(gca,'Ytick',[h_axis(3),h_axis(4)],'YTickLabel',{'0','1'})
%title(figtitle,'fontsize',9)
colormap(cmap)
% 
hcb=colorbar('FontSize',9);%%,'Direction','reverse');
%colorTitleHandle = get(hcb,'Title');
%titleString = 'S_4';
hcb.Label.String  = 'S_4';
pos = get(hcb,'Position');
hcb.Label.Position = [2.35 0.5]; % to change its position
hcb.Label.Rotation = 0; % to rotate the text
%set(colorTitleHandle ,'Label',titleString,'FontSize',9);





%save results
% set(gcf,'PaperUnits','centimeters')
% psize = get(gcf,'PaperSize');
% wd = 9;
% hg =8; 
% lf = (psize(1)-wd)/2;bt = (psize(2)-hg)/2;
% set(gcf,'PaperPosition',[lf bt wd hg]);
% print('-dpng','-r600',[figureName])
%print('-depsc2','-r700',['Tub_Sources_Pos_NoNoise_SuperResImg'])
