<script context="module" lang="ts">
    export type KhaosEffectData = {
        icon: string,
        notimer: boolean,
        timer: number,
        duration: number,
        noblink: boolean,
        etype: "bad" | "good" | "neutral" | "bees",
        name: string,
    };
</script>
<script lang="ts">
    export let effect: KhaosEffectData;

    function shouldShake(e: KhaosEffectData) {
        if (e.timer == -1 || e.name == "Roulette" || e.noblink || e.notimer) return false;
        return ((e.duration * 35) - e.timer) <= 105 && e.etype != "bees";
    }

    function getIcon(e: KhaosEffectData) {
        if (e.name == "Roulette") return "roulette.webp";
        return e.icon.replace("KH_", "") + ".png";
    }
</script>

<div class="khaos-effect {effect.name == "Double Items" ? "hide" : ""}" title={effect.name}>
    <img src="/khaos/{getIcon(effect)}" alt={effect.name} class="icon" />
    <img src="/khaos/{effect.etype}{shouldShake(effect) ? "shake.webp" : ".png"}" alt={effect.name} class="border {shouldShake(effect) ? "shaking" : ""}" />
</div>

<style>
    .khaos-effect {
        width: 32px;
        height: 32px;
        margin: 16px 0 16px 16px;
        image-rendering: pixelated;
    }

    .hide {
        display: none;
    }

    .icon {
        width: 32px;
        height: 32px;
        position: absolute;
    }

    .border {
        height: 40px;
        position: absolute;
        transform: translate(-4px, -4px);
    }

    .border.shaking {
        transform: translate(-8px, -4px);
    }
</style>
