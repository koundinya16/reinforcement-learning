function X_dot =cartPoleDynamics(t,x,m,M,l,F_ext)

X_dot=[x(2); (F_ext+m*sin(x(3))*(l*x(4)^2-9.8*cos(x(3))))/(M+m*sin(x(3))^2) ; x(4) ; -((F_ext*cos(x(3)))+(m*l*x(4).^2*sin(x(3))*cos(x(3)))+((M+m)*9.8*sin(x(3))))/(l*(M+m*sin(x(3))*sin(x(3))))];
end
