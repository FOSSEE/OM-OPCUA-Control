from opcua import Client
from opcua import ua
import time
import logging
import pandas as pd 

# Define the URL on which the server is broadcasting
url = "opc.tcp://192.168.0.171:4841"


def PI(Kp, Ki, MV_bar = 0):

    # Initialize stored data 
    I = 0
    MV = MV_bar

    while True:
        # yield MV, wait for new t, PV, SP
        PV, SP = yield MV

        # Error calculation 
        error = SP - PV
		
        P = Kp * error
        I = I + Ki * error * 1

        MV = MV_bar + P + I

if __name__ == "__main__":
    client = Client(url)
    logging.basicConfig(level=logging.WARN)

    try:
        client.connect()
        print("Client connected!")

        run = client.get_node(ua.NodeId(10001, 0))
        run.set_value(True)
        # print("Current state of run : {}".format(run.get_value()))

        root = client.get_root_node()
        # print("Root node is : ", root)

        objects = client.get_objects_node()
        # print("Objects\' node is : ", objects)

        # Find the IDs for MV, PV
        y_ID = 6 
        u_ID = 8 

        modelicaId = {}
        modelicaId = objects.get_children()

        # Desired setpoint
        SP = 1

        # Initialize the controller 
        controller = PI(0.2, 0.2/5) 
        controller.send(None)
        
        timeEla, sleeptime = [], []

        while True:
            # Evaluate the PV and MV 
            # prev_time = time.time()
            PV = modelicaId[y_ID].get_value()
            MV = controller.send([PV, SP])

            # Evaluate the PV and MV 
            # prev_time = time.time()
            time.sleep(1)

            modelicaId[u_ID].set_value(MV)
            # curr_time = time.time()

            # print("H value is: ", modelicaId[H_ID].get_value())
            # print("Controller effort is: ", modelicaId[U_ID].get_value())
            
            # dt = curr_time - prev_time
            # sleep_time = 1 - dt
            # timeEla.append(dt)
            # sleeptime.append(sleep_time)
            # if (sleep_time < 0):
            #     time.sleep(1)
            # else:
            #     time.sleep(sleep_time)
            # time.sleep(0.1)
            # print("="*40)
    
    except KeyboardInterrupt:
        print("Stopping sequence!")

    finally:
        # dict = {'ElapsedTime' : timeEla, 'sleepTime' : sleeptime}
        # df = pd.DataFrame(dict)
        # df.to_csv('ElapsedSameMachine.csv', index = False)
        
        print("Done!")
        client.disconnect()
