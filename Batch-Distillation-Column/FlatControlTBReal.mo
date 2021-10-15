model FlatControlTBReal
parameter Integer C = 3 "No of Components", N('No of Trays') = 40 "No of Trays";
  parameter Real XB0[C] = {0.3, 0.3, 0.4} "Initial Mole Fraction", alpha[C] = {9, 3, 1} "Relative Votality";
  parameter Real HB0 = 300 "Initial Charge to Still", HD = 10 "Reflux Drum Hold Up", HN = 1 "Tray Hold Up", V = 100 / HR "Vapor Boil up rate", XD1SP = 0.95, XD2SP = 0.95, XB3SP = 0.95 "Specified Product Purity", RR = 1.22 "Reflux Ratio", HR = 3600 "TIme Conversion factor", Epsilon = 1e-5, simulationScalingFactor = 1;
  Real HB "Still Hold up", XB[C](each min = 0, each max = 1) "Mole fraction in still", YB[C](each min = 0, each max = 1), L "Liquid Flow Rate", X[N, C](each min = 0, each max = 1) "Comp on Trays", Y[N, C](each min = 0, each max = 1), XD[C](each min = 0, each max = 1) "Composition of Distillate", D "Distillate flow rate";
  //===================================================================================================================*/
  Real flagProduct[C - 1](each start = -1), flagSlop[C - 1](each start = -1) "flagProduct signalling collection of Product 1 and Product 2. flagSlop signalling collection of Slop 1 and Slop 2";
  Real timeProduct[C](each start = 0), timeSlop[C - 1](each start = 0) "Times at which products and slops are withdrawn";
  Real product[C - 1](each start = 3e-5), slop[C - 1](each start = 3e-5) "Holdup tanks for Products and slops";
  Real productComponents[C - 1, C] "Amounts collected in Product tanks";
  Real heavyKeyComponentMoles "Quantity (moles) of h.k. component collected in still pot";
  Real sumProduct[C - 1] "Total number of moles collected in product tanks";
  Real averageProductMoleFraction[C - 1, C] "Average concentrations comp. in product tanks";
  Real slopComponents[C - 1, C] "Amounts of comp collected in slop tanks";
  Real sumSlop[C - 1] "Total number of moles collected in slop tanks";
  Real averageSlopMoleFraction[C - 1, C] "Average concentrations comp in slop tanks";
//  Boolean valveProduct[C - 1](each start = false), valveSlop[C - 1](each start = false) "On/Off valves for the product and slop tanks";
  Real valveProduct[C - 1], valveSlop[C - 1] "On/Off valves for the product and slop tanks";
  //======================================================================================================================*/
initial equation
  for i in 1:C - 1 loop
    for j in 1:C loop
      productComponents[i, j] = Epsilon "Initial amounts(moles) present in product tanks.";
    end for;
  end for;
  for i in 1:C - 1 loop
    for j in 1:C loop
      slopComponents[i, j] = Epsilon "Initial amounts(moles) present in slop tanks.";
    end for;
  end for;
//------------------------------------------------------------------------------------------------------
  HB = HB0 - HD - N*HN - D;
  XB[1] = 0.3;
  XB[2] = 0.3;
  XB[3] = 0.4;
  for n in 2:N - 1 loop
    X[n, 1] = 0.3;
    X[n, 2] = 0.3;
    X[n, 3] = 0.4;
  end for;
  XD[1] = 0.3;
  XD[2] = 0.3;
  XD[3] = 0.4;
  X[N, 1] = 0.3;
  X[N, 2] = 0.3;
  X[N, 3] = 0.4;
  X[1, 1] = 0.3;
  X[1, 2] = 0.3;
  X[1, 3] = 0.4;
//======================================================================================================
equation
/* ====Conditions for getting Time of Products and amount of Heavy Key==== */
  for i in 1:C - 1 loop
    when flagProduct[i] == 1 then
      timeProduct[i] = time;
    end when;
    when flagSlop[i] == 1 then
      timeSlop[i] = time;
    end when;
  end for;
  when valveSlop[C - 1] == 0.0 and timeSlop[C - 1] > 0 then
    timeProduct[C] = time;
  end when;
  when timeProduct[C] > 0 then
    heavyKeyComponentMoles = HB * XB[3] "Amount of H.K. component recovered";
  end when;
//--------------------------------------------------------------------------------------------------------------------
/* ============ "Amounts ofcomp collected in tank product1 at any point in time"========*/
  for i in 1:C - 1 loop
    if valveProduct[i] == 1.0 then
// Product valve is open.
      flagProduct[i] = 1 "Removing product 1";
      flagSlop[i] = -1;
      der(product[i]) = D;
      der(slop[i]) = 0;
      for j in 1:C loop
        der(productComponents[i, j]) = D * XD[j];
        der(slopComponents[i, j]) = 0;
      end for;
    elseif valveSlop[i] == 1.0 then
// Slop Valve is open.
      flagProduct[i] = -1;
      flagSlop[i] = 1 "Removing Slop 1";
      der(product[i]) = 0;
      der(slop[i]) = D;
      for j in 1:C loop
        der(productComponents[i, j]) = 0;
        der(slopComponents[i, j]) = D * XD[j];
      end for;
    else
      flagProduct[i] = -1;
      flagSlop[i] = -1;
      der(product[i]) = 0;
      der(slop[i]) = 0;
      for j in 1:C loop
        der(productComponents[i, j]) = 0;
        der(slopComponents[i, j]) = 0;
      end for;
    end if;
  end for;
//-----------------------------------------------------------------------------------------------------
/*============ Total Amount of Products and Components in Slop and Products Tanks===============*/
  for i in 1:C - 1 loop
    sumProduct[i] = sum(productComponents[i, :]);
    sumSlop[i] = sum(slopComponents[i, :]);
    for j in 1:C loop
      averageProductMoleFraction[i, j] = productComponents[i, j] / sumProduct[i] "Average concentrations inside product tanks";
      averageSlopMoleFraction[i, j] = slopComponents[i, j] / sumSlop[i] "Average concentrations inside slop tanks";
    end for;
  end for;
//--------------------------------------------------------------------------------------------------
/* ============================ Conditions to Open/Close Valves of Slop and Products =================================*/
  if XD[1] >= XD1SP then
    valveProduct[1] = 1.0;
    valveSlop[1] = 0.0;
    valveProduct[2] = 0.0;
    valveSlop[2] = 0.0;
  elseif D > 0 and XD[1] < XD1SP and XD[2] < XD2SP and product[2] <= 3e-5 then
    valveProduct[1] = 0.0;
    valveSlop[1] = 1.0;
    valveProduct[2] = 0.0;
    valveSlop[2] = 0.0;
  elseif D > 0 and XD[2] >= XD2SP then
    valveProduct[1] = 0.0;
    valveSlop[1] = 0.0;
    valveProduct[2] = 1.0;
    valveSlop[2] = 0.0;
  elseif product[2] > 3e-5 and XD[2] < XD2SP and XB[3] < XB3SP then
    valveProduct[1] = 0.0;
    valveSlop[1] = 0.0;
    valveProduct[2] = 0.0;
    valveSlop[2] = 1.0;
  else
    valveProduct[1] = 0.0;
    valveSlop[1] = 0.0;
    valveProduct[2] = 0.0;
    valveSlop[2] = 0.0;
  end if;
/* ==================================================================================================================== */
/* =====================  Material Balance on Column =========================================*/
//Initially operated at Total reflux
  when XD[1] >= XD1SP then
    D = 40/HR;//V / (1 + RR);
  end when;
//------------------------------------------------------------------------------------------------------
/* ============================ STILL POT ============================================================*/
  der(HB) = -D;
  for j in 1:C loop
    der(HB * XB[j]) = L * X[1, j] - V * YB[j];
    YB[j] = alpha[j] * XB[j] / (alpha[1] * XB[1] + alpha[2] * XB[2] + alpha[3] * XB[3]);
  end for;
/* ============================ N TRAY(Excluding Top and Bottom)======================================*/
  for n in 2:N - 1 loop
    for j in 1:C loop
      HN * der(X[n, j]) = L * (X[n + 1, j] - X[n, j]) + V * (Y[n - 1, j] - Y[n, j]);
      Y[n, j] = alpha[j] * X[n, j] / (alpha[1] * X[n, 1] + alpha[2] * X[n, 2] + alpha[3] * X[n, 3]);
    end for;
  end for;
/* ============================ Bottom Tray ==========================================================*/
  for j in 1:C loop
    HN * der(X[1, j]) = L * (X[2, j] - X[1, j]) + V * (YB[j] - Y[1, j]);
    Y[1, j] = alpha[j] * X[1, j] / (alpha[1] * X[1, 1] + alpha[2] * X[1, 2] + alpha[3] * X[1, 3]);
  end for;
/* ============================ Top Tray =============================================================*/
  for j in 1:C loop
    HN * der(X[N, j]) = L * (XD[j] - X[N, j]) + V * (Y[N - 1, j] - Y[N, j]);
    Y[N, j] = alpha[j] * X[N, j] / (alpha[1] * X[N, 1] + alpha[2] * X[N, 2] + alpha[2] * X[N, 3]);
  end for;
/* ============================ REFLUX DRUM ==========================================================*/
  for j in 1:C loop
    HD * der(XD[j]) = V * Y[N, j] - (L + D) * XD[j];
  end for;
  L = V - D;
  
  when XB[3] >= XB3SP then
    terminate("done");     
  end when;

end FlatControlTBReal;