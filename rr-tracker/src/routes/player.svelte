<svelte:options accessors={true} />

<script lang="ts">
    import KhaosEffect, { type KhaosEffectData } from './khaos_effect.svelte';

    export let position: number;
    export let dedupedPosition: number;
    export let name: string;
    export let rings: number;
    export let beingChased: boolean;
    export let damaged: boolean;
    export let exploding: boolean;
    export let speedPercentage: number;
    export let ringDelay: 0 | 1 | 2 | 3 | 4 | 5 | 6;
    export let effects: KhaosEffectData[];
    export let khaosTimer: number;
    export let khaosWaittime: number;

    $: {
        if (effectsDiv !== undefined) onEffectsChange(effects);
    }

    let effectsDiv: HTMLDivElement | undefined;
    const effectDisplays: KhaosEffect[] = [];

    function onEffectsChange(e: KhaosEffectData[]) {
        if (effectsDiv === undefined) return;
        if (e.length != effectDisplays.length) {
            effectDisplays.length = 0;
            while (effectsDiv.firstChild) {
                effectsDiv.removeChild(effectsDiv.firstChild);
            }
            for (const effect of e) {
                let newEffect = new KhaosEffect({
                    target: effectsDiv,
                    props: {
                        effect: effect
                    }
                });
                effectDisplays.push(newEffect);
            }
            effectDisplays.length = effectDisplays.length; // Bodge to update Svelte stuff
        }
        for (let effectN = 0; effectN < effectDisplays.length; effectN++) {
            const effect = effectDisplays[effectN];
            const effectData = e[effectN];
            effect.$set({
                effect: effectData
            });
        }
    }

    function getSpeedDigit(from: number, digit: 0|1|2): string {
        return Math.min(from, 999).toString().padStart(3, "0")[digit];
    }
</script>

<!-- <script lang="ts" context="module">
    import { browser } from '$app/environment';

    if (browser) {
        const ringFrames: HTMLImageElement[] = [];
        for (let ringN = 1; ringN <= 10; ringN++) {
            const image = new Image();
            image.src = `/ring/ring${ringN}.png`;
            ringFrames.push(image);
        }
    }
</script> -->

<div class="player dd-position-{dedupedPosition} {beingChased ? "being-chased" : "not-being-chased"} {rings > 0 ? "has-rings" : "has-no-rings"} {exploding ? "explode" : ""} {damaged ? "damage" : ""}">
    <div class="player-transform player-scale">
        <div class="player-transform player-translate">
            <img src="/player_backdrop.png" alt="Player background backdrop" class="player-background" />
            <img src="/player_backdrop_intense.png" alt="Player background backdrop with intense colors" class="player-background player-background-intense" />
            <img src="/ring/ring{ringDelay}.webp" alt="Spinning ring icon" class="ring" />
            <img src="/spb_rings.gif" alt="Self-Propelled Bomb chasing a player with rings" class="spb spb-rings" />
            <img src="/spb_no_rings.gif" alt="Self-Propelled Bomb chasing a player without rings" class="spb spb-no-rings" />
            <p class="ring-counter">{rings}</p>
            <p class="name">{name}</p>
            <div class="khaos-progress-bar">
                <div class="khaos-progress" style="width: {khaosTimer / khaosWaittime * 100}%;">
                    <!-- Empty -->
                </div>
            </div>
        </div>
    </div>
    <div class="player-speed">
        <img src="/speedometer.png" alt="Speedometer icon" class="speedometer-icon" />
        <div class="speedometer-digits">
            <img src="/digits/digit{getSpeedDigit(speedPercentage, 0)}.png" alt="Speedometer digit 1" class="speedometer-digit speedometer-digit-left" />
            <img src="/digits/digit{getSpeedDigit(speedPercentage, 1)}.png" alt="Speedometer digit 2" class="speedometer-digit speedometer-digit-middle" />
            <img src="/digits/digit{getSpeedDigit(speedPercentage, 2)}.png" alt="Speedometer digit 3" class="speedometer-digit speedometer-digit-right" />
        </div>
        <img src="/percent.png" alt="Percent sign" class="speedometer-percent" />
    </div>
    <div class="khaos-effects" bind:this={effectsDiv}>
        <!-- Empty -->
    </div>
</div>

<style>
    .player {
        image-rendering: pixelated;
        /* width: 384px; */
        height: 64px;
        margin: 0;
        display: flex;
        flex-direction: row;
    }

    .player-transform {
        width: 384px;
        height: 100%;
    }

    .player-background {
        position: absolute;
        background-repeat: no-repeat;
        height: 64px;
    }

    .player-background-intense {
        opacity: 0;
    }

    .explode>.player-scale>.player-translate>.player-background-intense {
        animation: explosion-recolor 2.5s;
    }

    .damage>.player-scale>.player-translate {
        animation: shake 0.5s linear;
    }

    .explode>.player-scale>.player-translate {
        animation: shake2 0.5s linear 0.5s;
    }

    .explode>.player-scale {
        animation: explosion 2.5s;
        transform-origin: 50% 75%;
    }

    .ring {
        position: absolute;
        height: 32px;
        transform: translate(30px, 14px);
    }
    
    .spb {
        position: absolute;
        height: 82px;
        transform: translate(6px, -10px);
    }

    .not-being-chased>.player-scale>.player-translate>.spb {
        display: none;
    }

    .has-no-rings>.player-scale>.player-translate>.spb-rings {
        display: none;
    }

    .has-rings>.player-scale>.player-translate>.spb-no-rings {
        display: none;
    }

    .player>.player-scale>.player-translate>p {
        position: absolute;
    }

    .ring-counter {
        transform: translate(75px, 6px);
    }

    .name {
        transform: translate(150px, 6px);
        color: black;
    }

    .player-speed {
        display: flex;
        flex-direction: row;
        align-items: center;
        /* width: 32px; */
        height: 100%;
    }

    .speedometer-icon {
        height: 32px;
    }

    .speedometer-digits {
        display: flex;
        flex-direction: row;
    }

    .speedometer-digit {
        height: 16px;
    }

    .speedometer-digit-left {
        transform: translateX(2px);
        padding-left: 4px;
    }

    .speedometer-digit-right {
        transform: translateX(-2px);
    }

    .speedometer-percent {
        height: 16px;
    }

    .khaos-effects {
        height: 64px;
        display: flex;
        flex-direction: row;
    }

    .khaos-progress-bar {
        transform: translate(10px, 46px);
        width: 352px;
        height: 2px;
        margin: 0;
    }

    .khaos-progress {
        transition: width 1s linear;
        height: 100%;
        margin: 0;
        background-color: #ffffff;
    }

    @keyframes shake {
        0% {
            transform: translateX(32.27px); /*rotate(32.27deg);*/
        }

        16% {
            transform: translateX(-32.27px); /*rotate(-32.27deg);*/
        }

        28% {
            transform: translateX(13.12px); /*rotate(13.12deg);*/
        }

        44% {
            transform: translateX(-4.63px); /*rotate(-4.63deg);*/
        }

        59% {
            transform: translateX(1.64px); /*rotate(1.64deg);*/
        }

        73% {
            transform: translateX(-0.58px); /*rotate(-0.58deg);*/
        }

        88% {
            transform: translateX(0.2px); /*rotate(0.2deg);*/
        }

        100% {
            transform: translateX(0px); /*rotate(0deg);*/
        }
    }

    @keyframes shake2 {
        0% {
            transform: translateX(1312px);
        }

        16% {
            transform: translateX(-1312px);
        }

        28% {
            transform: translateX(1312px);
        }

        44% {
            transform: translateX(-463px);
        }

        59% {
            transform: translateX(164px);
        }

        73% {
            transform: translateX(-58px);
        }

        88% {
            transform: translateX(20px);
        }

        100% {
            transform: translateX(0px);
        }
    }

    @keyframes explosion {
        0% {
            scale: 100% 100%;
        }

        5% {
            scale: 200% 10%;
        }

        20% {
            scale: 200% 10%;
        }

        25% {
            scale: 10% 400%;
        }

        100% {
            scale: 100% 100%;
        }
    }

    @keyframes explosion-recolor {
        0% {
            opacity: 1;
        }
        
        50% {
            opacity: 0.75;
        }

        100% {
            opacity: 0;
        }
    }
</style>
