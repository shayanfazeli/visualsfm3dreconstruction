%%%%%%%%%%%%%%%%%%%%%
%% NVM READER      %%
%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%
%Preparing the script:
clear all;
close all;
clc;

%now reading the nvm file:
fid = fopen('hw3.nvm');
context = textscan(fid,'%s');
number_of_cameras = str2double(context{1}(2));
camera = cell(number_of_cameras,1);
offset = 3;

for cam = 1:number_of_cameras
    %for each camera:
    camera{cam}.name = context{1}(11*(cam-1) + offset);
    %reading the camera:
    disp(['Reading the ', sprintf('%d', cam), 'th camera']);
    camera{cam}.focal_length = str2double(context{1}(11*(cam-1) + offset + 1));
    camera{cam}.quaternion = str2double(context{1}(11*(cam-1) + offset + 2:11*(cam-1) + offset + 5));
    camera{cam}.translation = str2double(context{1}(11*(cam-1) + offset + 6:11*(cam-1) + offset + 8));
    camera{cam}.radial_distortion = str2double(context{1}(11*(cam-1) + offset + 9));
end


%okay, now the cameras are read. time to proceed:

%% Reading the points:
index = number_of_cameras*11 + offset + 1;
counter = 1;
double_data = str2double(context{1});
the_length = length(context{1})-42;
while index < the_length
    % read in initial double_data about point
    disp(['Progress: ',num2str(index/(the_length)*100)]);
    point(counter).coordinates = (double_data(index:index+2));
    point(counter).rgb = (double_data(index+3:index+5));
    point(counter).number_of_viewers = (double_data(index+6));
    index = index + 7;
    % read in image locations of point
    for view = 1:point(counter).number_of_viewers
        point(counter).sight(view).image_index =  (double_data(index));
        point(counter).sight(view).feature_index =  (double_data(index+1));
        point(counter).sight(view).image_coordinates =  (double_data(index+2:index+3));
        index = index + 4;
    end
    % increment counter
    counter = counter + 1;
end



error_pack = cell(number_of_cameras,1);

for cam = 1:number_of_cameras
   %now for each camera:
   errors=[];
   R = give_me_R(camera{cam}.quaternion);
   K = [camera{cam}.focal_length, 0 0; 0 camera{cam}.focal_length 0; 0 0 1];
   T = (-R)*camera{cam}.translation;
   P = K * cat(2,R,T);
  
   for i = 1:length(point)
      disp(['Camera: ', sprintf('%d', cam), ' - ', 'Progress: ', num2str((i/length(point))*100)]);
      %for each point:
      viewers=[];
      for k = 1:point(i).number_of_viewers
          viewers = [viewers; point(i).sight(k).image_index];
      end
      
      index = find(~((viewers+1) - cam));
      if all((viewers+1)-cam) || point(i).number_of_viewers<5
          %our camera doesn't see this point.
      else
          mm = point(i).sight(index).image_coordinates;
          mx = mm(1);
          my = mm(2);
          r2 = (camera{cam}.radial_distortion/(camera{cam}.focal_length^2)) * (mx * mx + my * my);
          projection = P * cat(1, point(i).coordinates, [1]);
          projection = projection ./ projection(3);
          difference = projection(1:2)-(1+r2)*point(i).sight(index).image_coordinates;
          errors = cat(2,errors, difference);
      end
   end
   error_pack{cam,1} = errors;
    
end


%computing the average:
count = 0;
sum = 0;
cam_errors = zeros(1,size(error_pack,1));
for i=1:size(error_pack,1)
    errors = error_pack{i,1};
    for j = 1:size(errors,2)
        sum = sum + norm(errors(:,j));
        count = count + 1;
    end
    cam_errors(1,i) = mean(sqrt((errors(1,:).*errors(1,:)) + (errors(2,:).*errors(2,:))));
end


result = sum / count;
disp(['Result: ', sprintf('%g', result)]);

