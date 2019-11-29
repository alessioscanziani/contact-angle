function [IPx,IPy]=Contact_point(segm)

% This function is able to find the three phase interception points present
% in the segmented slice given as input. Oil phase must be labelled as 1, 
% brine phase as 2 and rock phase as 3
%
% INPUT:
% segm = matrix with values 1,2 or 3 depending on phase on its pixels
% OUTPUT:
% IPx, IPy = coordinates of the three phase contact points

IPx=NaN;
IPy=NaN;

Segm=segm;
Segm_r=length(Segm(:,1)); % number of rows
Segm_c=length(Segm(1,:)); % number of columns

Oil=zeros(Segm_r,Segm_c);
Brine=zeros(Segm_r,Segm_c);

% Find points of rock confining with oil
for i=2:Segm_r-1
    for j=2:Segm_c-1
        if Segm(i,j)==3
            if Segm(i-1,j)==1 || Segm(i-1,j-1)==1 || Segm(i-1,j+1)==1 ...
                    || Segm(i+1,j)==1 || Segm(i+1,j+1)==1 ...
                    || Segm(i+1,j-1)==1 || Segm(i,j-1)==1 || Segm(i,j+1)==1
                Oil(i,j)=1;
            end
        end
    end
end

% Find points of rock confining with water
for i=2:Segm_r-1
    for j=2:Segm_c-1
        if Segm(i,j)==3
            if Segm(i-1,j)==2 || Segm(i-1,j-1)==2 || Segm(i-1,j+1)==2 ...
                    || Segm(i+1,j)==2 || Segm(i+1,j-1)==2 ...
                    || Segm(i+1,j+1)==2 || Segm(i,j-1)==2 || Segm(i,j+1)==2
                Brine(i,j)=1;
            end
        end
    end
end

% Save in IPx and IPy the coordinates of rock/rest interface (points where
% IP=2)
n=1;
m=1;
IP=Oil+Brine; % Sum in order to find points confining with both o and w
for i=1:length(IP(:,1))
    for j=1:length(IP(1,:))
        if IP(i,j)==2
            IPx(n)=j;
            IPy(m)=i;
            n=n+1;
            m=m+1;
        end
    end
end

% Keep only one coordinate couple per each three phase point
cancel=0;
it=1;
for i=2:length(IPx)
    if sqrt((IPx(i)-IPx(i-1))^2+(IPy(i)-IPy(i-1))^2)==1
        cancel(it)=i;
        it=it+1;
    end
end
if cancel~=0
    IPx(cancel)=[];
    IPy(cancel)=[];
end