%---------------------- Simulation of Cart-pole System-------------------
% 
% All units are in S.I 

% Koundinya
% AE13B010

% MATLAB R2014a

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
axis([-50 50 -10 20])
axis equal
axis manual % disable auto scaling

%---------System Parameters-----------------


m=0.1; % Pendulum+Pole mass
l=0.5; % Pendulum length
M=1;   % Mass of cart

F=10;   % Control Input-Force


%-----------Control Conditions------------
theta_setpoint=pi/2;

%-----------Initial Conditions-------------  
x_0=0;
v_0=0;
theta_0=pi;
w_0=0;

initial_state=[x_0 v_0 theta_0 w_0];

%------------Q-learning Initialization-------------------

MAX_FALLS  = 500;
falls = 0;
steps=0;
max_steps=0;

e     = 0.09;    % Exploration parameter
alpha = 1.5;      % Learning parameter
gamma = 0.4;    % discount parameter
SEED  = 50000;

total_boxes=325;

for i=1:total_boxes
  Q_value(i) = 0;
end

% Selecting an initial action randomly
rng(SEED,'twister');
action = -F;                                    
if (randi(10) >= 5)
    action = F;                                  
end

%Initial State
box=get_box(x_0,v_0,theta_0,w_0,F);  

%------------------------------------------------------------

% time step
dt=0.005;
t=0:dt:2*dt;

% initialize state variables
state(2,:)=initial_state;
 
  fprintf('\n\t\t Started Simulation \n');
  
  while(falls<=MAX_FALLS)   
  %----------------------Solving Cart-pole Dynamics-----------
 [tspan,state]=ode45(@(t,x) cartPoleDynamics(t,x,m,M,l,action),t,initial_state);
 
 if state(2,3)>2*pi
     state(2,3)=state(2,3)-2*pi;
 elseif state(2,3)<0
     state(2,3)=state(2,3)+2*pi;
 end
 
  initial_state=state(2,:);
  
  %---------------- Q-learning Control------------------------
  

    new_box = get_box_Qlearning(state(2,1),state(2,2),state(2,3),state(2,4),action);
    if(new_box<0)
        p      = 0;
        reward = -1;
        falls  = falls + 1;
        
        % Q-learning Off-policy Control Algorithm
        rhat         = reward + gamma*(p) - Q_value(box); 
        Q_value(box) = Q_value(box) + alpha*(rhat);

        %Reset cart-pole to initial state
        initial_state=[x_0 v_0 theta_0 w_0];
        state(2,:)=initial_state;
        if(steps>max_steps)
            max_steps=steps;
        end
        steps     = 0;
        
    else
        if(new_box==0)
            new_box=325;
        end
        % Q-learning off-policy control algorithm
        reward       = 1;
        rhat         = reward + gamma*(Q_value(new_box)) - Q_value(box);
        Q_value(box) = Q_value(box) + alpha*(rhat);
        box          = new_box;    %s <-- s' 
    end
    %           e-Greedy action selection rule
%           ------------------------------
%       -> random action for exploration with probability           : e
%       -> greedy action(one with highest Q-value) with probability : 1-e

     if(randi(100)>=100*e)
         a=get_box_Qlearning(state(2,1),state(2,2),state(2,3),state(2,4),F);
         b=get_box_Qlearning(state(2,1),state(2,2),state(2,3),state(2,4),-F);
         if(a==0)
             a=325;
         end
         if(b==0)
             b=325;
         end
         if(Q_value(a)>Q_value(b))
             action=F;
         else
             action=-F;
         end
     else
         action = -F;                                    
            if (randi(10) >= 5)
                action = F;                                  
            end
     end
      if(falls>490) 
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
    
   
    xlabel({'Trial ';falls})
    %pause(0.0010);
    drawnow
      end

%---------------------------------------------------------------
steps=steps+1;
 
  end
 
 fprintf('\n\t Done \n');
 fprintf('\n\t Pole was balanced for a maximum of : %ld time steps',max_steps);
 

 
 
