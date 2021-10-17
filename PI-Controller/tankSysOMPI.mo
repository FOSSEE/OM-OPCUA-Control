model tankSysOMPI
  parameter Real K = 2 "Plant gain";  
  parameter Real Kc = 0.2 "Controller gain"; 
  parameter Real r = 1 "Setpoint";  
  parameter Real tau = 2 "Plant time const"; 
  parameter Real Ti = 5 "Integral time const"; 
  Real y(start = 0) "Plant output";
  Real error "Deviation from the setpoint"; 
  Real u "Controller effort"; 
  Real x "State variable for controller"; 
equation
  error = r - y; 
  der(x) = error / Ti; 
  Kc * (error + x) = u;  
  tau * der(y) + y = K * u;  
end tankSysOMPI;
