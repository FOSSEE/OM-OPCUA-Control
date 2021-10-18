# OM-OPCUA-Control
OpenModelica OPC UA framework for control applications

To invoke the OPC UA server for a model (say `testModel.mo`) in OpenModelice: 
- Launch `OMShell-terminal`. 
- Execute: `loadModel(Modelica)`
- Execute: `loadFile("testModel.mo")`
- Execute: `simulate(testModel, startTime = 0, stopTime = 10, simflags = "-rt=1.0 -embeddedServer=opc-ua")`
