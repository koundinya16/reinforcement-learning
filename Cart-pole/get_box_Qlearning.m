function [ box ] = get_box_Qlearning( x, x_dot, theta_dash, theta_dot, action)
    
    theta=pi-theta_dash;
    % NOT MUCH CHANGE WITH ADDITIONAL CONSTRAINTS
    if (x < -20 || x > 20 || theta < -(70*pi)/180 || theta > (70*pi)/180  )          
    %if (x < -2.4 || x > 2.4 || x_dot < -3 || x_dot > 3 || theta < -(12*pi)/180 || theta > (12*pi)/180 || theta_dot < -1.22 || theta_dot > +1.22 )          
        box = -1;
        return  
    end

    if (x < -0.8)            
        box = 0;
    elseif (x < 0.8)              
        box = 1;
    else                         
        box = 2;
    end
    
    if (x_dot < -0.5);
    elseif (x_dot < 0.5)                
        box = box + 3;
    else                     
        box = box + 6;
    end

    if (theta < -(6*pi)/180);
    elseif (theta < -(pi)/180)        
        box = box + 9;
    elseif (theta < 0)            
        box = box + 18;
    elseif (theta < (pi)/180)         
        box = box + 27;
    elseif (theta < (6*pi)/180)        
        box = box + 36;
    else                   
        box = box + 45;
    end

    if (theta_dot < -(50*pi)/180);
    elseif (theta_dot < (50*pi)/180)  
        box = box + 54;
    else                         
        box = box + 108;
    end
    
    if(action==10)
        box = box + 162;
    end
end
