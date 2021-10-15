model tankSysOMP
  parameter Real K = 1 "Plant gain";  
  parameter Real Kc = 0.2 "Controller gain"; 
  parameter Real r = 1 "Setpoint";  
  parameter Real tau = 2 "Plant time const"; 
  Real y(start = 0) "Plant output";
  Real error "Deviation from the setpoint"; 
  Real u "Controller effort"; 
equation
  error = r - y; 	
  Kc * error = u;  
  tau * der(y) + y = K * u;   
end tankSysOMP;
