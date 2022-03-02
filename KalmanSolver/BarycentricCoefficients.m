function  [l] = BarycentricCoefficients(x,y,xtri,ytri)

% BoolInd = 0;
b= [x - xtri(3);y- ytri(3)];
A = [xtri(1) - xtri(3) xtri(2) - xtri(3);ytri(1) - ytri(3) ytri(2) - ytri(3);];

l = A\b;

% if l(1)>=0 && l(2)>=0 && l(1)+l(2)<=1
%     BoolInd = 1;
% end