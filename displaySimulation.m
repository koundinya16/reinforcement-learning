function []=displaySimulation(state)
% -----------Initial Coordinates(Dimensions) of the system---------

% Cart Coordinates
origin_x1 = [4 4 -4 -4 ];
origin_y1 = [8 0 0 8];

% Pendulum bob coordinates
r = 1;
v = linspace(0,2*pi);
origin_x2 = r*cos(v);
origin_y2 = -5+r*sin(v);

% Pendulum coordinates
origin_x3 = [0 0 0 0 ];
origin_y3 = [4 -5 -5 4];


%--------- Final Coordinates of system vertices after state update----
destination_x1 = origin_x1 + x;
destination_y1 = origin_y1;

destination_x2 = origin_x2+ 9*sin(theta)+x;
destination_y2 = origin_y2+ 9*(1-cos(theta));

destination_x3 = [x x+9*sin(theta) x+9*sin(theta) x ];
destination_y3 =  [4 4-9*cos(theta) 4-9*cos(theta) 4] ;



drawAnimation(origin_x1,origin_y1,origin_x2,origin_y2,origin_x3,origin_y3,destination_x1,destination_y1,destination_x2,destination_y2,destination_x3,destination_y3);

origin_x1=destination_x1;
origin_y1=destination_y1;

origin_x2=destination_x2;
origin_x2=destination_y2;

origin_x3=destination_x3;
origin_x3=destination_y3;