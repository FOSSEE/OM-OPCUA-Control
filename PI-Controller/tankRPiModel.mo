model tankRPiModel
  parameter Real K = 2 "Plant gain";  
  parameter Real tau = 2 "Plant time const"; 
  Real y(start = 0) "Plant output";
  input Real u "Controller effort from the client"; 
equation  
  tau * der(y) + y = K * u;    
end tankRPiModel;
