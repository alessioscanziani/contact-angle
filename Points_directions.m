clc
clear all
close all

% Assignments
zdimension = input('Number of .tif images? ');
% Subvolume is the region in which 3D data will be cut around three-phase
% contact point
subvolume = input('Dimension of subvolume? ');
subvolume = subvolume/2;
mydata = cell(1, zdimension);
% Import .tif images in MATLAB
% !!If different number of figures, change %03d!!
for k = 1:zdimension
  myfilename = sprintf('CPline%03d.tif', k);
  mydata{k} = importdata(myfilename);
end

xdimension = length(mydata{1}.cdata(1,:));
ydimension = length(mydata{1}.cdata(:,1));
% Automatic search of interface points
interfaces=zeros(ydimension,xdimension,zdimension);
for k=1:zdimension
interfaces(:,:,k)=mydata{k}.cdata;
end
% Save interface points in variable IP
n=1;
for x=1:length(interfaces(1,:,1))
    for y=1:length(interfaces(:,1,1))
        for z=1:length(interfaces(1,1,:))
            if interfaces(y,x,z)==1
                IP(n,1)=x;
                IP(n,2)=y;
                IP(n,3)=z;
                n=n+1;
            end
        end
    end
end
% Compute the normal directions WITHOUT moving average
for k = 1:length(IP)-1
    dir_IP(:,k) = [IP(k+1,1)-IP(k,1)
        IP(k+1,2)-IP(k,2)
        IP(k+1,3)-IP(k,3)];
    IP_norm_dir(k)=norm(dir_IP(:,k));
    IP_dir_normalized(:,k)=dir_IP(:,k)./IP_norm_dir(k);
end
IP_dir_normalized=IP_dir_normalized';
% Save interface points, along with coordinates of subvolume
points_directions_subvolume = [IP(1:end-1,:), IP_dir_normalized, IP(1:end-1,:)-subvolume];
dlmwrite('points_directions_subvolume.txt',points_directions_subvolume,'delimiter','\t','precision',5)

% Compute moving average of interface line
IP_movavg_4 = tsmovavg(IP,'s',4,1);
% Compute normal directions from moving average
for k = 4:length(IP_movavg_4)-1
    dir_IP_movavg(:,k) = [IP_movavg_4(k+1,1)-IP_movavg_4(k,1)
        IP_movavg_4(k+1,2)-IP_movavg_4(k,2)
        IP_movavg_4(k+1,3)-IP_movavg_4(k,3)];
    IP_norm_dir_movavg(k)=norm(dir_IP_movavg(:,k));
    IP_dir_normalized_movavg(:,k)=dir_IP_movavg(:,k)./IP_norm_dir_movavg(k);
end
IP_dir_normalized_movavg=IP_dir_normalized_movavg';
% Plot interface points (without moving average)
scatter3(IP(:,1),IP(:,2),IP(:,3),'*b')
xlabel('x')
ylabel('y')
zlabel('z')
hold on
% Set the dimension of the region where to extract portions of contact
% line, where to compute the moving average
k_ROI=10;

point_direction_subvolume_ROI=zeros(length(IP(:,1)),9);
for n=1:length(IP(:,1))

    x_E=IP(n,1)-k_ROI;
    x_W=IP(n,1)+k_ROI;
    y_S=IP(n,2)-k_ROI;
    y_N=IP(n,2)+k_ROI;
    z_L=IP(n,3)-k_ROI;
    z_U=IP(n,3)+k_ROI;
    if x_E<=0
        x_E=1;
    end
    if y_S<=0
        y_S=1;
    end
    
    threep_line_ROI=zeros('like',interfaces);
    threep_line_ROI(y_S:y_N,x_E:x_W,z_L:z_U)=interfaces(y_S:y_N,x_E:x_W,z_L:z_U);
    % Find points of three phase contact line in the subregion

    [y_ROI{n},x_ROI{n},z_ROI{n}]=ind2sub(size(threep_line_ROI),find(threep_line_ROI));

    
    ROI{n}=[x_ROI{n},y_ROI{n},z_ROI{n}]';
    % Compute moving average between points in the subregion
    movavg_4{n}=tsmovavg(ROI{n},'s',4,2);
    % Compute triangolar moving average
    movavg_4tr{n}=tsmovavg(ROI{n},'t',4,2);
    
    for k=4:length(movavg_4{n})-1
        dir{n}(:,k-3)=[movavg_4{n}(1,k+1)-movavg_4{n}(1,k);movavg_4{n}(2,k+1)-movavg_4{n}(2,k);movavg_4{n}(3,k+1)-movavg_4{n}(3,k)];
        norm_dir{n}(k-3)=norm(dir{n}(:,k-3));
        dir_normalized{n}(:,k-3)=dir{n}(:,k-3)./norm_dir{n}(k-3);
    end
    
    point_direction_subvolume_ROI(n,:)=[movavg_4{n}(:,4)', dir_normalized{n}(:,1)', movavg_4{n}(:,4)'-subvolume];

end
% Save new coordinates in .txt file
dlmwrite('points_directions_subvolume_movavg.txt',point_direction_subvolume_ROI,'delimiter','\t','precision',5)

scatter3(IP(:,1),IP(:,2),IP(:,3),'*b')
xlabel('x')
ylabel('y')
zlabel('z')
% Save the coordinates of interface points
IPcoordinates = IP;
save('IPcoordinates','IPcoordinates')