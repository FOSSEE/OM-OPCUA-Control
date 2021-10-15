from opcua import Client
from opcua import ua
import time
import logging

# Define the URL on which the server is broadcasting
url = "opc.tcp://192.168.0.171:4841"

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
        H_ID = 6 
        U_ID = 8 

        modelicaId = {}
        modelicaId = objects.get_children()

        # Desired setpoint
        SP = 1

        # Controller gain
        Kc = 0.2

        while True:
            # Evaluate the PV and MV 
            PV = modelicaId[H_ID].get_value()
            MV = Kc * (SP - PV)
            time.sleep(0.1)
            modelicaId[U_ID].set_value(MV)

            # print("H value is: ", modelicaId[H_ID].get_value())
            # print("Controller effort is: ", modelicaId[U_ID].get_value())
            # time.sleep(0.1)
            # print("="*40)
    
    except KeyboardInterrupt:
        print("Stopping sequence!")

    finally:
        print("Done!")
        client.disconnect()
