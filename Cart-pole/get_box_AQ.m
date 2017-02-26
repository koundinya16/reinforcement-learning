function [ box ] = get_box_AQ( x, x_dot, theta_dash, theta_dot)
    
    theta=pi-theta_dash;
    
        % Controller maintains angle between -12 to 12 degrees 
    if (x < -5 || x > 5 || theta < -(12*pi)/180 || theta > (12*pi)/180  )                    
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
    
    if(box==0)
        box = 325;
    end
end
