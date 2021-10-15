# XD[1] 129, XD1SP, XD2SP, D, XD[2] 130, product[2] 133, XB[3] 128, XB3SP
# valveProduct[1] 435, valveSlop[1] 437, valveProduct[2] 436, valveSlop[2] 438 

from opcua import Client, ua
import time
import logging
from tclab import clock
import pandas as pd 

# Define the URL on which the server is broadcasting
url = "opc.tcp://192.168.0.171:4841"

if __name__ == "__main__":
    client = Client(url)
    logging.basicConfig(level=logging.WARN)

    try:
        client.connect()
        print("Client Connected")
        
        enableStopTime = client.get_node(ua.NodeId(10003, 0))
        # enableStopTime.set_value(False)
        print("Current state of enableStopTime : {}".format(enableStopTime.get_value()))

        run = client.get_node(ua.NodeId(10001, 0))
        run.set_value(True)
        print("Current state of run : {}".format(run.get_value()))

        objects = client.get_objects_node()

        XB3_ID, XD1_ID, XD2_ID = 129, 130, 131 # readIDs
        D_ID = 440 # readIDs
        product1_ID, product2_ID = 133, 134 # readIDs
        slop1_ID, slop2_ID = 141, 142 # readIDs 
        HB_ID = 6 # readIDs

        valveProduct1_ID, valveProduct2_ID = 436, 437 # writeIDs 
        valveSlop1_ID, valveSlop2_ID = 438, 439 # writeIDs 
        readTime_ID = 5 # time ID 
        
        modelicaId = {}
        modelicaId = objects.get_children()
        # print(modelicaId)
        
        XD1SP, XD2SP, XB3SP = 0.95, 0.95, 0.95 

        tfinal = 16000  
        stepsize = tfinal / 500
        XD_1, XD_2, product_1, product_2, slop_1, slop_2, HB, timeVal = [], [], [], [], [], [], [], [] 
        
        t = 0
        
        while True: 
            
            print("Local time is {}".format(t))
            print("Server time is {}".format(modelicaId[readTime_ID].get_value()))            

            XD_1.append(modelicaId[XD1_ID].get_value())
            XD_2.append(modelicaId[XD2_ID].get_value())

            product_1.append(modelicaId[product1_ID].get_value())
            product_2.append(modelicaId[product2_ID].get_value())

            slop_1.append(modelicaId[slop1_ID].get_value())
            slop_2.append(modelicaId[slop2_ID].get_value())

            HB.append(modelicaId[HB_ID].get_value())

            timeVal.append(t)   

            if(modelicaId[XD1_ID].get_value() >= XD1SP):
                print("I am in first loop")
                modelicaId[valveProduct1_ID].set_value(1.0)
                modelicaId[valveSlop1_ID].set_value(0.0)
                modelicaId[valveProduct2_ID].set_value(0.0)
                modelicaId[valveSlop2_ID].set_value(0.0)

            elif(modelicaId[D_ID].get_value() > 0.0 and modelicaId[XD1_ID].get_value() < XD1SP and \
                modelicaId[XD2_ID].get_value() < XD2SP and modelicaId[product2_ID].get_value() <= 3e-5):
                print("I am in second loop")
                modelicaId[valveProduct1_ID].set_value(0.0)
                modelicaId[valveSlop1_ID].set_value(1.0)
                modelicaId[valveProduct2_ID].set_value(0.0)
                modelicaId[valveSlop2_ID].set_value(0.0)
            
            elif(modelicaId[D_ID].get_value() > 0.0 and modelicaId[XD2_ID].get_value() >= XD2SP):
                print("I am in third loop")
                modelicaId[valveProduct1_ID].set_value(0.0)
                modelicaId[valveSlop1_ID].set_value(0.0)
                modelicaId[valveProduct2_ID].set_value(1.0)
                modelicaId[valveSlop2_ID].set_value(0.0)
            
            elif(modelicaId[product2_ID].get_value() > 3e-5 and modelicaId[XD2_ID].get_value() < XD2SP \
                and modelicaId[XB3_ID].get_value() < XB3SP):
                print("I am in the 4th loop")
                modelicaId[valveProduct1_ID].set_value(0.0)
                modelicaId[valveSlop1_ID].set_value(0.0)
                modelicaId[valveProduct2_ID].set_value(0.0)
                modelicaId[valveSlop2_ID].set_value(1.0)

            else:
                print("I am in the last loop")
                modelicaId[valveProduct1_ID].set_value(0.0)
                modelicaId[valveSlop1_ID].set_value(0.0)
                modelicaId[valveProduct2_ID].set_value(0.0)
                modelicaId[valveSlop2_ID].set_value(0.0)
            
            t = t + stepsize
            time.sleep(stepsize)
            print("="*40)

    except KeyboardInterrupt:
        print("Stopping sequence!")

    finally:
        dict = {'time': timeVal, 'XD[1]': XD_1, 'XD[2]': XD_2, \
            'product[1]': product_1, 'product[2]': product_2, \
            'slop[1]': slop_1, 'slop[2]': slop_2, \
            'HB': HB}  
        df = pd.DataFrame(dict) 
        df.to_csv('batchDistExt.csv', index = False) 
        print("Done!")
        client.disconnect()
