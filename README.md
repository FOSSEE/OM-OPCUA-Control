# OM-OPCUA-Control
OpenModelica OPC UA framework for control applications

To invoke the OPC UA server for a model (say `testModel.mo`) in OpenModelica: 
- Launch `OMShell-terminal`. 
- Execute: `loadModel(Modelica)`
- Execute: `loadFile("testModel.mo")`
- Execute: `simulate(testModel, startTime = 0, stopTime = 10, simflags = "-rt=1.0 -embeddedServer=opc-ua")`

Alternatively, one can invoke the OPC UA server from [OMEdit](https://openmodelica.org/doc/OpenModelicaUsersGuide/latest/omedit.html). 
