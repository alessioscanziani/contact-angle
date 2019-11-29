clc
clear all
close all

load IPcoordinates
numfiles = input('Number of slices? ');
k_line = input('Dimension region for line? ');
mydata = cell(1, numfiles);
h = waitbar(0,'Initializing waitbar...');
theta_contact = zeros(numfiles,1);
r_curvature = zeros(numfiles,1);
for k = start:numfiles
    try
        % Load slices saved in Avizo as .tif files
        myfilename = sprintf('%d.tif',k);
        mydata{k} = importdata(myfilename);
        % Identify three phase contact points
        [IP(1),IP(2)]=Contact_point(mydata{k});
        % Compute the contact angle
        [theta_contact(k), r_curvature(k)]=Contact_angle(mydata{k},IP,k_line);
    catch
        % If there is some error in the calculation, the slice is not
        % considered
        r_curvature(k) = NaN;
        theta_contact(k)=NaN;
    end
    disp(k)
    perc = (k-start)/(numfiles-start);
    waitbar(perc,h,sprintf('%d%% along...',round(perc*100)))
end

theta_contact_all=theta_contact;
theta_contact(find(isnan(theta_contact)))=[];

average=mean(theta_contact);
std_dev=std(theta_contact);
positions=find(isnan(theta_contact_all)==0);

% Histogram of contact angles
figure(1)
hist(theta_contact)

% Map of contact angles along the three phase contact line
figure(2)
scatter3(IPcoordinates(:,1),IPcoordinates(:,2),IPcoordinates(:,3),theta_contact_all,theta_contact_all);

%% Curvature
% In order to compute the curvature, I have to check the dimension of
% images: in fact, some images are saved as 1048x1048 and others as 40x40.
% Values of curvature are expressed in (approximated) micrometres.
for i = 1:numfiles
    if length(mydata{i}(:))==1600
       conversion(i) = 80/40;
    elseif length(mydata{i}(:))==1048576
       conversion(i) = 80/1024;
    end
end
conversion = conversion';
r_curv_micron = r_curvature.*conversion;
k_c_micron = 1./r_curv_micron;
k_c_micron(isnan(theta_contact_all))=[];

% Correlation between contact angle and curvature
figure()
plot(theta_contact,k_c_micron,'b.')
ylabel('Curvature [1/\mu m]')
xlabel('Contact angle [°]')

% Clear the waitbar, not to save it with the results
h=[];

save -v7.3 final_results.mat