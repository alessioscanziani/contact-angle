function [theta_contact_degree,r_circle]=Contact_angle(segm_ROI,IP,k_line)

% With this function it is possible to compute the contact angle on a set
% of segmented slices saved as matrixes in variable segm_ROI
%
% INPUT:
% segm_ROI = matrix of segmented data: 1 for pixels labelled as oil, 2 for
%               water and 3 for rock phase
% IP = row vector containing the coordinates of the three phase contact
%       point
% k_line = length of the rock/rest contact line
% OUTPUT:
% theta_contact_degree = contact angle computed on the input slice

Segm=segm_ROI;
k_line = k_line/2;

Segm_r=length(Segm(:,1));
Segm_c=length(Segm(1,:));

%% Find the interface pixels between rock and the rest
L=zeros(Segm_r,Segm_c);
for i=2:Segm_r-1
    for j=2:Segm_c-1
        if Segm(i,j)==3
            if Segm(i-1,j)~=3 || Segm(i+1,j)~=3 || Segm(i,j+1)~=3 || Segm(i,j-1)~=3
                L(i,j)=1;
            end
        end
    end
end
% Save the coordinates of the rock/rest interface
n=1;
m=1;
for i=1:length(L(:,1))
    for j=1:length(L(1,:))
        if L(i,j)==1
            Lx(n)=j;
            Ly(m)=i;
            n=n+1;
            m=m+1;
        end
    end
end

%% Find interception point from segm
IPy=IP(2);
IPx=IP(1);

% Use the defined length for the rock/rest contact line
cancel1=find(Lx<IPx-k_line);
Lx(cancel1)=[];
Ly(cancel1)=[];
cancel2=find(Lx>IPx+k_line);
Lx(cancel2)=[];
Ly(cancel2)=[];
cancel3=find(Ly<IPy-k_line);
Lx(cancel3)=[];
Ly(cancel3)=[];
cancel4=find(Ly>IPy+k_line);
Lx(cancel4)=[];
Ly(cancel4)=[];

%% Calculate the interpolating contact line
L_line=polyfit(Lx,Ly,1);
m_line=L_line(1);
q_line=L_line(2);
Ly_fitted=m_line.*Lx+q_line;

% %% Plot the contact line (secant)
% figure()
% imagesc(Segm)
% set(gca,'YDir','normal')
% hold on
% plot(Lx,Ly,'ok')
% hold on
% plot(Lx,Ly_fitted,'y','LineWidth',2);
% hold on

%% Find the interface pixels between the brine and the rest

C=zeros(Segm_r,Segm_c);
for i=2:Segm_r-1
    for j=2:Segm_c-1
        if Segm(i,j)==2
            if Segm(i-1,j)==1 || Segm(i+1,j)==1 || Segm(i,j-1)==1 || Segm(i,j+1)==1 
                C(i,j)=1;
            end
        end
    end
end
n=1;
m=1;
for i=1:length(C(:,1))
    for j=1:length(C(1,:))
        if C(i,j)==1
            Cx(n)=j;
            Cy(m)=i;
            n=n+1;
            m=m+1;
        end
    end
end

%% Fit a circle to brine-oil contact points
Cxy=[Cx',Cy'];
C_circle=CircleFitByPratt(Cxy);
a_circle=C_circle(1);
b_circle=C_circle(2);
r_circle=C_circle(3);

%% Plot the circle
ang=0:0.01:2*pi;
x_circle=a_circle+r_circle.*cos(ang);
y_circle=b_circle+r_circle.*sin(ang);
% plot(Cx,Cy,'r*')
% hold on
% plot(x_circle,y_circle, 'r')
% hold on

%% Find interception point from segm
IPy=IP(2);
IPx=IP(1);

%% Find interception point
Interception=linecirc(L_line(1),L_line(2),a_circle,b_circle,r_circle);
for i=1:2
    if Interception(i)>IPx-k_line && Interception(i)<IPx+k_line
        x_interception=Interception(i);
    end
end
y_interception=L_line(1)*x_interception+L_line(2);
theta_secant=atan(m_line);

%% Compute the contact angle

cos_theta_circle=(x_interception-a_circle)/r_circle;
sin_theta_circle=(y_interception-b_circle)/r_circle;

theta_circle=atan(sin_theta_circle/cos_theta_circle);
theta_tangent=theta_circle+pi/2;
if theta_secant<0
    theta_secant=theta_secant+pi;
end
theta_contact_radiant=abs(theta_tangent-theta_secant);
if theta_contact_radiant>pi/2
    theta_contact_radiant=pi-theta_contact_radiant;
end

%% Check the point on the normal, to see if the angle is acute or obtuse
k=50;
cos_theta_normal=(IPx-a_circle)/r_circle;
sin_theta_normal=(IPy-b_circle)/r_circle;
theta_normal=atan2(sin_theta_normal,cos_theta_normal);

m_normal=tan(theta_normal);
x_normal=IPx-k:IPx+k;
y_normal=IPy+m_normal.*(x_normal-IPx);

x_normal_new=x_normal;
y_normal_new=y_normal;

it=0;
for i=1:length(x_normal)
    if ceil(x_normal(i))<=0 || ceil(y_normal(i))<=0
            x_normal_new(i-it)=[];
            y_normal_new(i-it)=[];
            it=it+1;
    end
end
x_normal_new_new=x_normal_new;
y_normal_new_new=y_normal_new;
it=0;
for i=1:length(x_normal_new)
    if ceil(x_normal_new(i))>size(Segm,2) || ceil(y_normal_new(i))>size(Segm,1)
        x_normal_new_new(i-it)=[];
        y_normal_new_new(i-it)=[];
        it=it+1;
    end
end

if length(x_normal_new_new)<2
    y_normal=IPy-k:IPy+k;
    x_normal=IPx+1/m_normal.*(y_normal-IPy);

    x_normal_new=x_normal;
    y_normal_new=y_normal;

    it=0;
    for i=1:length(x_normal)
        if round(x_normal(i))<=0 || round(y_normal(i))<=0
                x_normal_new(i-it)=[];
                y_normal_new(i-it)=[];
                it=it+1;
        end
    end
    x_normal_new_new=x_normal_new;
    y_normal_new_new=y_normal_new;
    it=0;
    for i=1:length(x_normal_new)
        if round(x_normal_new(i))>size(Segm,2) || round(y_normal_new(i))>size(Segm,1)
            x_normal_new_new(i-it)=[];
            y_normal_new_new(i-it)=[];
            it=it+1;
        end
    end
end

label=0;
if length(x_normal_new_new)>3
    for i=1:length(x_normal_new_new)
        if Segm(ceil(y_normal_new_new(i)),ceil(x_normal_new_new(i)))==1
            label=label+1;
        end
    end
    if label==0
            theta_contact_radiant=pi-theta_contact_radiant;
    end

    theta_contact_degree=rad2deg(theta_contact_radiant);
else
    theta_contact_degree=NaN;
end


