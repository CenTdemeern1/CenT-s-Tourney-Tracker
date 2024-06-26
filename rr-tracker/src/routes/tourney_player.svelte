<script lang="ts">
    export let points: number;
    export let dedupedPosition: number;
    export let name: string;
</script>

<div class="player dd-position-{dedupedPosition}">
    <img src="/tourney_player_backdrop.png" alt="Player background backdrop" class="player-background" />
    <p class="name">{name}</p>
    <p class="points">{points}</p>
</div>

<style>
    .player {
        image-rendering: pixelated;
        width: 320px;
        height: 64px;
        margin: 0;
        display: flex;
        flex-direction: row;
    }

    .player-background {
        position: absolute;
        background-repeat: no-repeat;
        height: 64px;
    }

    .player>p {
        position: absolute;
    }

    .name {
        transform: translate(58px, 6px);
        color: black;
    }

    .points {
        transform: translate(296px, 6px);
    }
</style>
