from pprint import pprint
import asyncio
from websockets.server import serve
import threading
import json

_ws_data = {}
ws_data_json = "{}"
def update_ws_data(x: dict):
    global ws_data_json
    _ws_data.update(x)
    ws_data_json = json.dumps(_ws_data)
    print(f"Update: {ws_data_json}")

def ws_task():
    async def echo(websocket):
        async for message in websocket:
            if message == "p": # poll
                await websocket.send(ws_data_json)

    async def main():
        async with serve(echo, "0.0.0.0", 8081):
            await asyncio.Future()  # run forever

    asyncio.run(main())

ws_thread = threading.Thread(target=ws_task)
ws_thread.start()

log = open("/Users/centdemeern1/ringracers/latest-log.txt")

read_buffer = ""

def await_next_line():
    global read_buffer
    while True:
        read = log.read()
        if read:
            read_buffer += read
        if "\n" in read_buffer:
            line, read_buffer = read_buffer.split("\n", maxsplit=1)
            return line

while True:
    line = await_next_line()
    if line:
        # print(line, end="")
        if line == "================BEGIN PLAYERS DATA================":
            players = []
            while True:
                line = await_next_line()
                if line == "================ END PLAYERS DATA ================":
                    break
                try:
                    position, rings, being_chased_by_spb, exploded, ring_delay, name = line.split(" ", maxsplit=5)
                except Exception as e:
                    print(f"Error while parsing players data: {e}")
                try:
                    players.append({
                        "pos": int(position),
                        "rings": int(rings),
                        "spb": being_chased_by_spb == "true",
                        "expl": exploded == "true",
                        "rd": int(ring_delay),
                        "name": name
                    })
                except Exception as e:
                    print(f"Error while constructing player: {e}")
                    break
            update_ws_data({
                "players": players
            })
