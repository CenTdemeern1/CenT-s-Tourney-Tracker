<script lang="ts">
    export let lap: number;
    export let height: number;
</script>

<!-- <script lang="ts" context="module">
    import { browser } from '$app/environment';

    if (browser) {
        const lapNumbers: HTMLImageElement[] = [];
        for (let lapN = 1; lapN <= 10; lapN++) {
            const image = new Image();
            image.src = `/laps/lap${lapN}.png`;
            lapNumbers.push(image);
        }
    }
</script> -->

<div class="lap" style="height: {(height * 64) - 16}px">
    {#if lap == -1}
        <img src="/lap_flag_finish.gif" alt="Lap flag icon" class="lap-flag" />
    {:else}
        <img src="/lap_flag.png" alt="Lap flag icon" class="lap-flag" />
        <img src="/laps/lap{lap}.png" alt="Lap number {lap}" class="lap-number" />
    {/if}
</div>

<style lang="scss">
    .lap {
        image-rendering: pixelated;
        margin: 0;
        border-left: 2px solid white;
        padding-left: 2px;
        margin-bottom: 16px;
        display: flex;
        flex-direction: row;
        transition: height 0.5s ease-out;
    }

    .lap-flag {
        height: 20px;
        translate: 0px -10px;
    }

    .lap-number {
        height: 16px;
        translate: 0px -8px;
        margin-left: 2px;
    }
</style>
