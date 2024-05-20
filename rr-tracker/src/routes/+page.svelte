<head>
    <title>CenT's Tourney Tracker</title>
</head>

<body>
    <h1>CenT's Tourney Tracker</h1>

    <div class="live-stats">
        <div class="lap-indicators">
        </div>
        <div class="players">
        </div>
    </div>

    {#if displayedPlayers.length == 0}
        <p>Waiting to receive data...</p>
    {/if}
    <!-- <ol>
        {#each displayedPlayers as item}
            <li>{item}</li>
        {/each}
    </ol> -->

    <br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>
</body>

<script lang="ts">
    import { browser } from '$app/environment';
    import Player from './player.svelte';
    import LapIndicator from './lap_indicator.svelte';

    const displayedPlayers: Player[] = [];
    const lapIndicators: LapIndicator[] = [];
    let previousData: Data = {
        players: []
    };

    type PlayerData = {
        pos: number,
        rings: number,
        spb: boolean,
        expl: boolean,
        dmg: boolean,
        lap: number,
        sp: number,
        rd: number,
        name: string
    };
    type Data = {
        players: PlayerData[]
    };

    if (browser) {
        const ws = new WebSocket(`ws://${window.location.hostname}:8081`);
        ws.onopen = () => {
            setInterval(() => {
                ws.send("p");
            }, 500);
        };
        ws.onmessage = m => {
            const liveLapStats = document.querySelector(".live-stats>.lap-indicators")!;
            const livePlayerStats = document.querySelector(".live-stats>.players")!;

            let data: Data = JSON.parse(m.data);

            // Deduplicate positions
            const sortedPlayers = data.players.toSorted((a, b) => a.pos - b.pos);
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
                            deduped_position: deduped_pos_by_name[player.name],
                            name: player.name,
                            rings: player.rings,
                            beingChased: player.spb,
                            exploding: player.expl,
                            damaged: player.dmg,
                            speedPercentage: player.sp
                        }
                    });
                    displayedPlayers.push(newPlayer);
                }
                displayedPlayers.length = data.players.length; // Bodge to update Svelte stuff
            }
            for (let playerN = 0; playerN < data.players.length; playerN++) {
                const player = displayedPlayers[playerN];
                const playerData = data.players[playerN];
                const previousPlayerData = previousData.players[playerN];
                let newPlayerData: any = {
                    position: playerData.pos,
                    deduped_position: deduped_pos_by_name[playerData.name],
                    name: playerData.name,
                    rings: playerData.rings,
                    beingChased: playerData.spb,
                    speedPercentage: playerData.sp
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
            previousData = data;
        };
    }

</script>

<style lang="scss">
    body {
        background-color: black;
        color: white;
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
</style>
