<head>
    <title>CenT's Tourney Tracker{showKhaos ? " (Khaos Edition)" : ""}</title>
</head>

<body>
    <h1>CenT's Tourney Tracker{showKhaos ? " (Khaos Edition)" : ""}</h1>

    <div class="all-stats">
        <div class="live-stats" style="height: {72 + 64 * displayedPlayers.length}px">
            <h2 class="stats-header">Live stats</h2>
            {#if displayedPlayers.length == 0}
                <p class="data-placeholder">Waiting to receive data...</p>
            {/if}
            <div class="lap-indicators">
            </div>
            <div class="players">
            </div>
        </div>

        <div class="tourney-stats">
            <h2 class="stats-header">Tourney stats</h2>
            {#if Object.keys(displayedTourneyPlayers).length == 0}
                <p class="data-placeholder">Nothing to display (yet)!</p>
            {/if}
            <div class="players">
            </div>
        </div>
        <!-- <ol>
            {#each displayedPlayers as item}
                <li>{item}</li>
            {/each}
        </ol> -->
    </div>

    {#if showKhaos}
        <div class="khaos-kontraption">
            <div class="khaos-kontraption-hud">
                <p class="khaos-kontraption-universal-effect-header">Last Universal Effect:</p>
                <p class="khaos-kontraption-universal-effect-name">{previousData.khaos?.univ.name || "None"}</p>
                <div class="khaos-kontraption-universal-effect-progress-bar">
                    <div class="khaos-kontraption-universal-effect-progress" style="width: {(previousData.khaos?.univ.timer ?? 0) / (previousData.khaos?.univ.waittime ?? 1) * 100}%">
                        <!-- Empty -->
                    </div>
                </div>
            </div>
        </div>
    {/if}

    <br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>
</body>

<script lang="ts">
    import { browser } from '$app/environment';
    import Player from './player.svelte';
    import TourneyPlayer from './tourney_player.svelte';
    import LapIndicator from './lap_indicator.svelte';
    import type { KhaosEffectData } from './khaos_effect.svelte';

    let showKhaos = false;

    const displayedPlayers: Player[] = [];
    const lapIndicators: LapIndicator[] = [];
    let displayedTourneyPlayers: {[key: string]: TourneyPlayer} = {};

    let previousData: Data = {
        players: [],
        points: {},
        khaos: undefined,
    };

    type PlayerData = {
        pos: number,
        rings: number,
        spb: boolean,
        expl: boolean,
        dmg: boolean,
        lap: number,
        sp: number,
        rd: 0 | 1 | 2 | 3 | 4 | 5 | 6,
        name: string
    };
    type PointsData = {[key: string]: number};
    type KhaosData = {
        players: {
            [key: string]: {
                timer: number,
                waittime: number,
                effects: KhaosEffectData[]
            }
        },
        univ: {
            name: string,
            timer: number,
            waittime: number,
        }
    };
    type Data = {
        players: PlayerData[] | undefined,
        points: PointsData | undefined,
        khaos: KhaosData | undefined
    };

    if (browser) {
        const ws = new WebSocket(`ws${window.location.protocol == "https:" ? "s" : ""}://${window.location.hostname}:8081`);
        ws.onopen = () => {
            setInterval(() => {
                ws.send("p");
            }, 500);
        };
        ws.onmessage = m => {
            const liveLapStats = document.querySelector(".live-stats>.lap-indicators")!;
            const livePlayerStats = document.querySelector(".live-stats>.players")!;
            const tourneyPlayers = document.querySelector(".tourney-stats>.players")!;

            let data: Data = JSON.parse(m.data);

            if (data.players !== undefined) {
                // Deduplicate positions
                // const sortedPlayers = data.players.toSorted((a, b) => a.pos - b.pos); // Not supported in the JS version that OBS uses
                const sortedPlayers = [...data.players];
                sortedPlayers.sort((a, b) => a.pos - b.pos);
                let deduped_pos_by_name: {[key: string]: number} = {};
                // Also use this as an opportunity to track everyone's laps
                const laps: {lap: number, count: number}[] = [];
                for (let position = 0; position < sortedPlayers.length; position++) {
                    const sortedPlayer = sortedPlayers[position];
                    deduped_pos_by_name[sortedPlayer.name] = position + 1;
                    if (laps.length != 0 && laps[laps.length - 1].lap == sortedPlayer.lap) {
                        laps[laps.length - 1].count++;
                    } else {
                        laps.push({
                            lap: sortedPlayer.lap,
                            count: 1,
                        });
                    }
                }

                // Set lap info
                let lapI = 0;
                while (laps.length > lapIndicators.length) {
                    const lapSet = laps[lapI];
                    let newLapIndicator = new LapIndicator({
                        target: liveLapStats,
                        props: {
                            lap: lapSet.lap,
                            height: lapSet.count
                        }
                    });
                    lapIndicators.unshift(newLapIndicator);
                    lapI++;
                }
                for (lapI = 0; lapI < laps.length; lapI++) {
                    const lapSet = laps[lapI];
                    lapIndicators[lapI].$set({
                        lap: lapSet.lap,
                        height: lapSet.count
                    });
                }
                while (laps.length < lapIndicators.length) {
                    lapIndicators.pop()?.$destroy();
                }
                
                // Set player info
                if (data.players.length != displayedPlayers.length) {
                    displayedPlayers.length = 0;
                    while (livePlayerStats.firstChild) {
                        livePlayerStats.removeChild(livePlayerStats.firstChild);
                    }
                    for (const player of data.players) {
                        let newPlayer = new Player({
                            target: livePlayerStats,
                            props: {
                                position: player.pos,
                                dedupedPosition: deduped_pos_by_name[player.name],
                                name: player.name,
                                rings: player.rings,
                                beingChased: player.spb,
                                exploding: player.expl,
                                damaged: player.dmg,
                                speedPercentage: player.sp,
                                ringDelay: player.rd,
                                effects: data.khaos?.players[player.name]?.effects ?? [],
                                khaosTimer: data.khaos?.players[player.name]?.timer ?? 0,
                                khaosWaittime: data.khaos?.players[player.name]?.waittime ?? 1
                            }
                        });
                        displayedPlayers.push(newPlayer);
                    }
                    displayedPlayers.length = data.players.length; // Bodge to update Svelte stuff
                }
                for (let playerN = 0; playerN < data.players.length; playerN++) {
                    const player = displayedPlayers[playerN];
                    const playerData = data.players[playerN];
                    let previousPlayerData: PlayerData | null;
                    if (previousData.players === undefined) {
                        previousPlayerData = null;
                    } else {
                        previousPlayerData = previousData.players[playerN];
                    }
                    
                    let newPlayerData: any = {
                        position: playerData.pos,
                        dedupedPosition: deduped_pos_by_name[playerData.name],
                        name: playerData.name,
                        rings: playerData.rings,
                        beingChased: playerData.spb,
                        speedPercentage: playerData.sp,
                        ringDelay: playerData.rd,
                        effects: data.khaos?.players[player.name]?.effects ?? [],
                        khaosTimer: data.khaos?.players[player.name]?.timer ?? 0,
                        khaosWaittime: data.khaos?.players[player.name]?.waittime ?? 1
                    };
                    if (playerData.expl && !previousPlayerData?.expl) {
                        newPlayerData.exploding = playerData.expl;
                        setTimeout(() => {
                            player.$set({
                                exploding: false
                            });
                        }, 2500); // Explosion animation takes 2500 ms
                    }
                    if (playerData.dmg && !previousPlayerData?.dmg) {
                        newPlayerData.damaged = playerData.dmg;
                        setTimeout(() => {
                            player.$set({
                                damaged: false
                            });
                        }, 500); // Damage animation takes 500 ms
                    }
                    player.$set(newPlayerData);
                }
            }

            if (data.points !== undefined) {
                // Tourney stats
                const numberOfPlayersWithPoints = Object.keys(data.points).length;
                const sortedPlayersWithPoints = Object.keys(data.points);
                sortedPlayersWithPoints.sort((a, b) => data.points![b] - data.points![a]);
                if (numberOfPlayersWithPoints != Object.keys(displayedTourneyPlayers).length) {
                    displayedTourneyPlayers = {};
                    while (tourneyPlayers.firstChild) {
                        tourneyPlayers.removeChild(tourneyPlayers.firstChild);
                    }
                    for (const playerName in data.points) {
                        const points = data.points[playerName];
                        
                        let newPlayer = new TourneyPlayer({
                            target: tourneyPlayers,
                            props: {
                                dedupedPosition: sortedPlayersWithPoints.indexOf(playerName) + 1,
                                name: playerName,
                                points: points
                            }
                        });
                        displayedTourneyPlayers[playerName] = newPlayer;
                    }
                }
                for (const playerName in data.points) {
                    const points = data.points[playerName];
                    displayedTourneyPlayers[playerName].$set({
                        dedupedPosition: sortedPlayersWithPoints.indexOf(playerName) + 1,
                        points: points
                    });
                }
            }

            if (data.khaos !== undefined) {
                showKhaos = true;
            }

            // Remember the previous data
            previousData = data;
        };
    }

</script>

<style lang="scss">
    body {
        background-color: black;
        color: white;
    }

    .all-stats {
        display: flex;
        flex-direction: column;
    }

    .stats-header {
        height: 32px;
        margin: 16px 0px 16px 0px;
    }

    .tourney-stats>.stats-header {
        margin-bottom: 8px;
    }

    .lap-indicators {
        position: absolute;
        display: flex;
        flex-direction: column-reverse;
    }

    .players {
        position: absolute;
    }
    
    :global(.players>div) {
	    transition: transform 0.5s cubic-bezier(0.34, 1.56, 0.64, 1);
        position: absolute;
    }

    @mixin gen-pos($pos) {
        :global(.dd-position-#{$pos}) {
            transform: translateY(#{($pos - 1) * 64}px);
            z-index: $pos;
        }
    }

    @include gen-pos(1);
    @include gen-pos(2);
    @include gen-pos(3);
    @include gen-pos(4);
    @include gen-pos(5);
    @include gen-pos(6);
    @include gen-pos(7);
    @include gen-pos(8);
    @include gen-pos(9);
    @include gen-pos(10);
    @include gen-pos(11);
    @include gen-pos(12);
    @include gen-pos(13);
    @include gen-pos(14);
    @include gen-pos(15);
    @include gen-pos(16);

    .khaos-kontraption {
        width: 100vw;
        height: 100vh;
        position: fixed;
        top: 0;
        bottom: 0;
        left: 0;
        right: 0;
        z-index: 100;
    }

    .khaos-kontraption-hud {
        position: absolute;
        bottom: 0px;
        left: 20px;
        color: #ff9e4b;
        font-family: "Nixdorf 8810 M15";
        font-smooth: never;
        -webkit-font-smoothing : none;
    }

    .khaos-kontraption-universal-effect-name {
        font-size: 44px;
        text-shadow:
            -4px -4px 0 #000,
             0px -4px 0 #000,
             4px -4px 0 #000,
            -4px  0px 0 #000,
             0px  0px 0 #000,
             4px  0px 0 #000,
            -4px  4px 0 #000,
             0px  4px 0 #000,
             4px  4px 0 #000;
        margin-top: 0;
        margin-bottom: 14px;
    }

    .khaos-kontraption-universal-effect-header {
        font-size: 22px;
        text-shadow:
            -2px -2px 0 #000,
             0px -2px 0 #000,
             2px -2px 0 #000,
            -2px  0px 0 #000,
             0px  0px 0 #000,
             2px  0px 0 #000,
            -2px  2px 0 #000,
             0px  2px 0 #000,
             2px  2px 0 #000;
        margin-bottom: 0;
    }

    .khaos-kontraption-universal-effect-progress-bar {
        transform: translateX(-20px);
        width: 100vw;
        height: 8px;
        margin: 0;
        background-color: black;
    }

    .khaos-kontraption-universal-effect-progress {
        // width: 10%;
        transition: width 1s linear; // should be 0.5s but compensating for round trip
        height: 100%;
        margin: 0;
        background-color: #ff7b18;
        box-shadow: 8px 0 #bc4600;
    }

    @font-face {
        font-family: "Nixdorf 8810 M15";
        src:
            local("Nixdorf 8810 M15"),
            url("Web437_Nix8810_M15.woff") format("woff");
    }
</style>
