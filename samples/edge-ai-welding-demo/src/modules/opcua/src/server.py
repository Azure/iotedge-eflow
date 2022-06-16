# Copyright (C) 2021 scalers.ai

import asyncio
from asyncua import Server

async def start_opcua_server():
    """Start OPCUA server using the python package asyncua:
    https://github.com/FreeOpcUa/FreeOpcUa.github.io
    """
    url = "opc.tcp://0.0.0.0:4840"

    server = Server()
    await server.init()

    server.set_endpoint(url)
    server.set_server_name("Weld Porocity OPCUA Server")

    # register namespace
    name = "OPCUA_SIMULATION_SERVER"
    addspace = await server.register_namespace(name)
    
    node = await server.nodes.objects.add_object(addspace, 'Parameters')

    # add parameters to the namespaces
    WeldClass = await node.add_variable(addspace, "WeldClass", 0)
    Probability = await node.add_variable(addspace, "Probability", 0.0)
    FPS = await node.add_variable(addspace, "FPS", 0.0)

    # set parameters to writable
    await WeldClass.set_writable()
    await Probability.set_writable()
    await FPS.set_writable()

    print("Server started at {}".format(url))
    async with server:
        while True:
            await asyncio.sleep(1)

if __name__ == "__main__": 
    # start the opcua server
    asyncio.run(start_opcua_server())