# This file was kinda sloppily thrown together

# from pprint import pprint
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
    # print(f"Update: {ws_data_json}")

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

if "--ignore-catch-up" in __import__("sys").argv:
    log.read()

if "--ignore-catch-up" in __import__("sys").argv:
    log.read()

def await_next_line():
    global read_buffer
    while True:
        read = log.read()
        if read:
            read_buffer += read
        if "\n" in read_buffer:
            line, read_buffer = read_buffer.split("\n", maxsplit=1)
            return line


gp_points = {}

def calculate_gp_points(results: dict):
    print(results)
    # Count players
    all_players = [
        x
        for xs in results.values()
        for x in xs
    ]
    player_count = len(all_players)
    for position in results:
        if position == -1:
            points = 0
        else:
            points = player_count - position

            # The following is sourced from k_grandprix.c:66
            match player_count:
                case 0 | 1 | 2: # 1v1
                    pass # No bonus needed.
                case 3 | 4: # 3-4P
                    if position == 1: points += 1 # 1st gets +1 extra point
                case 5 | 6: # 5-6P
                    if position == 1: points += 3 # 1st gets +3 extra points
                    elif position == 2: points += 1 # 2nd gets +1 extra point
                case _: # Normal matches
                    if position == 1: points += 5 # 1st gets +5 extra points
                    elif position == 2: points += 3 # 2nd gets +3 extra points
                    elif position == 3: points += 1 # 3rd gets +1 extra point
        
        for player in results[position]:
            gp_points[player] = gp_points.get(player, 0) + points
    
    update_ws_data({
        "points": gp_points
    })


exitlevel = False
award_gp_points = False

while True:
    line = await_next_line()
    if line:
        # print(line, end="")
        if line == "$exitlevel":
            print("Exitlevel command issued, awaiting level exit")
            exitlevel = True
        elif exitlevel and line == "You must be in a level to use this.":
            print("Exitlevel aborted, command invalid")
            exitlevel = False
        elif line == "The round has ended.":
            if exitlevel:
                print("The round was ended via exitlevel, no points will be awarded")
                exitlevel = False
                continue
            print("Round has ended! Points will be awarded soon.")
            award_gp_points = True
        elif line == "================BEGIN RESULTS DATA================":
            results = {}
            while True:
                line = await_next_line()
                if line == "================ END RESULTS DATA ================":
                    break
                if not award_gp_points:
                    continue
                try:
                    position, name = line.split(" ", maxsplit=1)
                    position = int(position)
                except Exception as e:
                    print(f"Error while parsing results data: {e}")
                    break
                # No try-except block because this can't fail
                if position not in results:
                    results[position] = []
                results[position].append(name)
            if award_gp_points:
                award_gp_points = False
                calculate_gp_points(results)
        elif line == "================BEGIN PLAYERS DATA================":
            players = []
            while True:
                line = await_next_line()
                if line == "================ END PLAYERS DATA ================":
                    break
                try:
                    position, rings, being_chased_by_spb, exploded, damaged, lap, speed_percentage, ring_delay, name = line.split(" ", maxsplit=8)
                except Exception as e:
                    print(f"Error while parsing players data: {e}")
                    break
                try:
                    players.append({
                        "pos": int(position),
                        "rings": int(rings),
                        "spb": being_chased_by_spb == "true",
                        "expl": exploded == "true",
                        "dmg": damaged == "true",
                        "lap": int(lap),
                        "sp": int(speed_percentage),
                        "rd": int(ring_delay),
                        "name": name
                    })
                except Exception as e:
                    print(f"Error while constructing player: {e}")
                    break
            update_ws_data({
                "players": players
            })
