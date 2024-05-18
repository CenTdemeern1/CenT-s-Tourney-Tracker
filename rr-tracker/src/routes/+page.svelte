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
            // data.players.sort((a, b) => a.pos - b.pos);
            if (data.players.length != displayedPlayers.length) {
                displayedPlayers.length = 0;
                while (liveStats.firstChild) {
                    liveStats.removeChild(liveStats.firstChild);
                }
                for (const player of data.players) {
                    let newPlayer = new Player({
                        target: liveStats,
                        props: {
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
            // for (const player of data.players) {
            //     let x = new Player({
            //         target: document.querySelector("#tests")!,
            //         props: {
            //             name: "Test2",
            //             rings: 3,
            //         }
            //     });
            //     items.push(x);
            //     //items.push(`${player.rings.toString().padStart(2, "0")}* ${player.name} ${player.rd} ${player.spb ? "!!!!!" : ""} ${player.expl ? "💥💥💥💥💥" : ""}`)
            // }
        };
    }

</script>

<style>
    body {
        background-color: black;
        color: white;
    }

    .players {
        display: flex;
        flex-direction: column;
    }
</style>
