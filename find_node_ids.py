from opcua import Client
from opcua import ua
import time

# Define the URL on which the server is broadcasting
url = "opc.tcp://192.168.0.171:4841"

if __name__ == "__main__":
    client = Client(url)

    try:
        client.connect()
        print("Client connected!")

        enableStopTime = client.get_node(ua.NodeId(10003, 0))
        # enableStopTime.set_value(False)
        print("Current state of enableStopTime : {}".format(enableStopTime.get_value()))

        run = client.get_node(ua.NodeId(10001, 0))
        run.set_value(True)
        print("Current state of run : {}".format(run.get_value()))

        root = client.get_root_node()
        print("Root node is : ", root)

        objects = client.get_objects_node()
        print("Objects\' node is : ", objects)

        while True:
            modelicaId = {}
            modelicaVariables = {}
            tmp = {}

            modelicaId = objects.get_children()

            for i in range(len(modelicaId)):
                modelicaVariables[i] = modelicaId[i].get_display_name().Text
                # modelicaVariables[i] = modelicaId[i].get_browse_name()

                # till index 5, we have values like server, run, step, enableStopTime, etc.
                # So, we begin with 6 to have the actual parameters of the plant.
                if (i > 5):
                    tmp[i] = modelicaId[i].get_value()
                    print(i, modelicaVariables[i], tmp[i], modelicaId[i].get_array_dimensions())

                else:
                    print(i, modelicaVariables[i])
            time.sleep(1)
            print("="*40)


        # print(objects.get_children()[6].get_display_name().Text)

    except KeyboardInterrupt:
        print("Stopping sequence!")

    finally:
        print("Done!")
        client.disconnect()
