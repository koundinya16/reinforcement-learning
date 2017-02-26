%---------------------- Simulation of Cart-pole System-------------------
% 
% All units are in S.I 

% Koundinya
% AE13B010

% MATLAB R2014a

%                 |        @
%                 |-Theta-/
%                 |      /
%                 |     /
%                 |    /
%                 |   /
%                 |  /
%                 | /
%                 |/
%                  -----------> X
%                 
%        State : [x x_dot theta theta_dot]          {-pi <= theta <= pi}


%-----------Animation Initialization-------

% Cart Coordinates
x_cart_vertices = [4 4 -4 -4 ];
y_cart_vertices = [8 0 0 8];

% Pendulum bob coordinates
r = 1;
v = linspace(0,2*pi);
x_pendulum = r*cos(v);
y_pendulum = -5+r*sin(v);

% Pendulum Rod coordinates
x_rod = [0 0 0 0 ];
y_rod = [4 -5 -5 4];

% Draw Objects
cart = fill(x_cart_vertices, y_cart_vertices, 'r');
hold on
pendulum = fill(x_pendulum, y_pendulum, 'b');
hold on
rod = fill(x_rod, y_rod, 'g');

% Setting Axis limits
axis([-20 30 -10 20])
axis equal
axis manual % disable auto scaling

%---------System Parameters-----------------


m=0.1; % Pendulum+Pole mass
l=0.5; % Pendulum length
M=1;   % Mass of cart

F=0;   % Control Input-Force
action=F;

%-----------Control Conditions------------
x_setpoint=1;
x_dot_setpoint=1;
theta_setpoint=1;
theta_dot_setpoint=1;

state_setpoint=[x_setpoint x_dot_setpoint theta_setpoint theta_dot_setpoint];

%-----------Initial Conditions-------------  
x_0          =   0;
x_dot_0      =   0;
theta_0      =   pi-1;
theta_dot_0  =   0;

state_initial=[x_0 x_dot_0 theta_0 theta_dot_0];


%------------------------------------------------------------

% time step
dt=0.005;
t=0:dt:2*dt;

% initialize state variables
state(2,:)=state_initial;
 
  fprintf('\n\t\t Started Simulation \n');
  
  while(1)   
  %----------------------Solving Cart-pole Dynamics-----------
 [tspan,state]=ode45(@(t,x) cartPoleDynamics(t,x,m,M,l,action),t,state_initial);
 
 if state(2,3)>2*pi
     state(2,3)=state(2,3)-2*pi;
 elseif state(2,3)<0
     state(2,3)=state(2,3)+2*pi;
 end
 
  x=state(2,1);
  x_dot=state(2,2);
  theta=state(2,3);
  theta_dot=state(2,4);
  
  state_initial=state(2,:);
  
  %----------------Control code------------------------
  

   
  %------------------------Animation---------------------------
% // Revision needed-clumsy code

    x1 = x_cart_vertices + state(2,1);   % Move cart to new location (x1,y1) after state update
    y1 = y_cart_vertices;
    set(cart,'Vertices',[x1(:) y1(:)])

    x2 = x_pendulum+ 9*sin(state(2,3))+state(2,1);  % Move pendulum bob to new location after state update
    y2 = y_pendulum+ 9*(1-cos(state(2,3)));
    set(pendulum, 'Vertices', [x2(:) y2(:)])
    
    % Move pendulum Rod to new location after state update
    x3 = [state(2,1) state(2,1)+9*sin(state(2,3)) state(2,1)+9*sin(state(2,3)) state(2,1)];
    y3 = [4 4-9*cos(state(2,3)) 4-9*cos(state(2,3)) 4] ;
    set(rod,'Vertices',[x3(:) y3(:)])
    
    %pause(0.0010);
    drawnow
end

%---------------------------------------------------------------

 fprintf('\n\t Done \n');


 
 
