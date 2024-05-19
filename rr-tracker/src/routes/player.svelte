<script lang="ts">
    export let position: number;
    export let deduped_position: number;
    export let name: string;
    export let rings: number;
    export let beingChased: boolean;
    export let exploding: boolean;
    let ringFrame = 0;
</script>

<script lang="ts" context="module">
    import { browser } from '$app/environment';

    if (browser) {
        const ringFrames: HTMLImageElement[] = [];
        for (let ringN = 1; ringN <= 10; ringN++) {
            const image = new Image();
            image.src = `/ring/ring${ringN}.png`;
            ringFrames.push(image);
        }
    }
</script>

<div class="player dd-position-{deduped_position} {beingChased ? "being-chased" : "not-being-chased"} {rings > 0 ? "has-rings" : "has-no-rings"} {exploding ? "explode" : ""}">
    <div class="player-transform">
        <img src="/player_backdrop.png" alt="Player background backdrop" class="player-background" />
        <img src="/player_backdrop_intense.png" alt="Player background backdrop with intense colors" class="player-background player-background-intense" />
        <img src="/ring/ring1.png" alt="Spinning ring icon" class="ring" />
        <img src="/spb_rings.gif" alt="Self-Propelled Bomb chasing a player with rings" class="spb spb-rings" />
        <img src="/spb_no_rings.gif" alt="Self-Propelled Bomb chasing a player without rings" class="spb spb-no-rings" />
        <p class="ring-counter">{rings}</p>
        <p class="name">{name}</p>
    </div>
</div>

<style>
    .player {
        image-rendering: pixelated;
        width: 384px;
        height: 64px;
        margin: 0;
    }

    .player-transform {
        width: 100%;
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

    .explode>.player-transform>.player-background-intense {
        animation: explosion-recolor 2.5s;
    }

    .damage>.player-transform {
        animation: shake 0.5s linear;
    }

    .explode>.player-transform {
        animation: explosion 2.5s, shake2 0.5s linear 0.5s;
        transform-origin: 50% 75%;
    }

    .ring {
        position: absolute;
        height: 32px;
        translate: 30px 14px;
    }
    
    .spb {
        position: absolute;
        height: 82px;
        translate: 6px -10px;
    }

    .not-being-chased>.player-transform>.spb {
        display: none;
    }

    .has-no-rings>.player-transform>.spb-rings {
        display: none;
    }

    .has-rings>.player-transform>.spb-no-rings {
        display: none;
    }

    .player>.player-transform>p {
        position: absolute;
    }

    .ring-counter {
        translate: 75px 6px;
    }

    .name {
        translate: 150px 6px;
        color: black;
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
