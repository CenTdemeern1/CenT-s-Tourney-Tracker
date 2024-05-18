<head>
    <title>ADB Ring Racers Tourney Tracker</title>
</head>

<body>
    <h1>ADB Ring Racers Tourney Tracker</h1>

    <div class="live-stats players">
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

    const displayedPlayers: Player[] = [];
    type PlayerData = {
        pos: number,
        rings: number,
        spb: boolean,
        expl: boolean,
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
            const liveStats = document.querySelector(".live-stats")!;

            let data: Data = JSON.parse(m.data);

            // Deduplicate positions
            const sorted_players = data.players.toSorted((a, b) => a.pos - b.pos).map(e => e.name);
            let deduped_pos_by_name: {[key: string]: number} = {};
            for (let position = 0; position < sorted_players.length; position++) {
                const name = sorted_players[position];
                deduped_pos_by_name[name] = position + 1;
            }
            
            if (data.players.length != displayedPlayers.length) {
                displayedPlayers.length = 0;
                while (liveStats.firstChild) {
                    liveStats.removeChild(liveStats.firstChild);
                }
                for (const player of data.players) {
                    let newPlayer = new Player({
                        target: liveStats,
                        props: {
                            position: player.pos,
                            deduped_position: deduped_pos_by_name[player.name],
                            name: player.name,
                            rings: player.rings,
                            beingChased: player.spb,
                            exploding: player.expl,
                        }
                    });
                    displayedPlayers.push(newPlayer);
                }
                displayedPlayers.length = data.players.length; // Bodge to update Svelte stuff
            }
            for (let playerN = 0; playerN < data.players.length; playerN++) {
                const player = displayedPlayers[playerN];
                const playerData = data.players[playerN];
                let newPlayerData: any = {
                    position: playerData.pos,
                    deduped_position: deduped_pos_by_name[playerData.name],
                    name: playerData.name,
                    rings: playerData.rings,
                    beingChased: playerData.spb,
                };
                if (playerData.expl) {
                    newPlayerData.exploding = playerData.expl;
                    setTimeout(() => {
                        player.$set({
                            exploding: false
                        });
                    }, 2500); // Explosion animation takes 2500 ms
                }
                player.$set(newPlayerData);
            }
        };
    }

</script>

<style lang="scss">
    body {
        background-color: black;
        color: white;
    }

    /* .players {
        display: flex;
        flex-direction: column;
    } */
    
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
