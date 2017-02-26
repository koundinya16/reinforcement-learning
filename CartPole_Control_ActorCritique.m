%---------------------- Control of Cart-pole System-------------------
%                      Using Actor-Critique Method of RL
% 
% All units are in S.I 


% MATLAB R2014a

%               |----|
%               | M  | ------> X
%_______________|____|________________   
%                 |\        
%                 | \
%                 |  \     
%                 |   \   
%                 |    \  
%                 |     \
%                 |      \    
%                 |<Theta>\
%                 |        @
%                  
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
axis([-30 30 -10 20])

axis equal
axis manual % disable auto scaling

%---------System Parameters-----------------


m=0.1; % Pendulum+Pole mass
l=0.5; % Pendulum length
M=1;   % Mass of cart

F=10;   % Control Input-Force


%-----------Control Conditions------------
% x_setpoint=pi;
% x_dot_setpoint=0;
% theta_setpoint=0;
% theta_dot_setpoint=0;
% 
% state_setpoint=[x_setpoint x_dot_setpoint theta_setpoint theta_dot_setpoint];

%-----------Initial Conditions-------------  

%/*********** SET INITIAL STATE**********
x_0          =   0;
x_dot_0      =   0;
theta_0      =   pi;
theta_dot_0  =   0;
%/****************************************

state_initial=[x_0 x_dot_0 theta_0 theta_dot_0];

%------------- Actor-Critique Learning Initialization-------
total_boxes=325;
p=0;
olp=0;
rhat=0;
max_steps=20,000;
% /**************LEARNING PARAMETERS***********/
                ALPHA   = 1000;
                BETA    = 0.5;
                GAMMA   = 0.95;
                LAMBDAw  = 0.9;  
                LAMBDAv = 0.8;
% /********************************************/

failed=0;
falls=0;

% /************* SET THE NUMBER OF TRIALS FOR LEARNING********/
                       max_trials=100;
% /***********************************************************/

trial=1;

steps=zeros(1,max_trials);
for i=1:max_trials
    steps(i)=0;
end


e=zeros(1,325);
w=zeros(1,325);
v=zeros(1,325);
xbar=zeros(1,325);

for i=1:total_boxes
  w(i) = 0;
  v(i) = 0;
  e(i) = 0;
  xbar(i) = 0;
end
%------------------------------------------------------------

% time step
dt=0.005;
t=0:dt:2*dt;

% initialize state variables
state(2,:)=state_initial;

% Get box for initial state
  box = get_box_AQ(state(2,1),state(2,2),state(2,3),state(2,4));
  
  fprintf('\n\t\t Started Simulation \n');
  
  while(trial<=max_trials)
      
   steps(trial)=steps(trial)+1;
    if steps(trial)>max_steps
        max_steps=steps(trial);
    end   
 %----------------Control code : Action Selection------------------------
  
       if randi(100)/100 < (1.0 / (1.0 + exp(-max(-50.0, min(w(box), 50.0)))))
           action = F;
       else 
           action= -F;
       end

      % Update trace
      e(box)=e(box)+ (1-LAMBDAw) * (action/F-0.5);
      xbar(box)=xbar(box)+(1.0-LAMBDAv);

      % Remember prediction of failure for current state 
      oldp = v(box);
      
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
  
 %----------------Control code : Learning ----------------------
 
      box = get_box_AQ(x,x_dot,theta,theta_dot);

      if (box < 0)
          failed = 1;
	      falls=falls+1;
          c=clock;
          fprintf('\nTrial: %d-->%f seconds | %d hr %d min %d s \n',trial,steps(trial)*0.005,c(4),c(5),c(6));
          trial=trial+1;
	      

	  	 %Reset cart-pole to initial state
          state_initial=[x_0 x_dot_0 theta_0 theta_dot_0];
          state(2,:)=state_initial;
	      
          box = get_box_AQ(x_0, x_dot_0, theta_0, theta_dot_0);

	  	  r = -1.0;
	      p = 0.;
      else
          failed = 0;
	      r = 0;
	      p= v(box);
      end

      rhat = r + GAMMA * p - oldp;

      for i = 1:total_boxes
        % Update all weights
        w(i) = w(i)+ ALPHA * rhat * e(i);
        v(i) = v(i)+ BETA * rhat * xbar(i);
	  
        if (v(i) < -1.0)
            v(i) = v(i);
        end
      
        if (failed)
            %/*--- If failure, zero all traces. ---*/
            e(i)    = 0;
            xbar(i) = 0;
        else
            %/*--- Otherwise, update (decay) the traces. ---*/	      
	      e(i)    = e(i)* LAMBDAw;
	      xbar(i) = xbar(i)*LAMBDAv;
      end
      end
  
  %------------------------Animation------------------------------
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
    
    xlabel({'--Trial--';trial})
    title('Cart-pole System control with Reinforcement Learning');
    %pause(0.0010);
    
    drawnow
   
 %---------------------------------------------------------------
    
end
hold off
 fprintf('\n\t\t  Simulation Stopped\n')
 fprintf('\nPole was balanced for a maximum of: %f seconds[%d time steps]\n',max_steps*0.005,max_steps);
 
 i=1:1:max_trials;
 
 plot(i,steps*0.05.'--r')
 xlabel('Trial')
 ylabel('Time')
 


 
 
