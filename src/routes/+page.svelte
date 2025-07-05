<script>
    import {Canvas} from '@threlte/core'
    import Scene from './Scene.svelte'

    let scene = $state()
    export const prerender = true;
    
</script>


<div class="canvas-container">
<Canvas >
    <Scene bind:this={scene} linear flat/>
</Canvas>
</div>

<style>
    /* Set canvas to cover the whole screen */
    .canvas-container {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100vh; /* Viewport height */
      z-index: -1; /* Ensure canvas is behind other content */
    }
  
</style>