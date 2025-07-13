<script>
  import { T, useTask } from "@threlte/core";
  import { HUD, OrbitControls, useGltf} from "@threlte/extras";
  import { base } from '$app/paths';
  import HudScene from "./HudScene.svelte";
  import NightScene from "./NightScene.svelte";
  import LightScene from "./LigthScene.svelte";

  let rotation = $state(0);
  let woble = $state(0);
  let darkMode = $state(true);

  let newGreen = "#8DD8FF";
  let newOrange = "#FF4545";

  let currentColor = $state(newGreen);
  let colorSwapCounter = $state(0);

  let uniforms = {
    uTime: { value: 0 },
    u_lineThickness: { value: 2 },
    u_gridSpacing: { value: 0.05 },
    u_gridColor: { value: [0.173, 0.243, 0.314] },
    u_backgroundColor: { value: [0.973, 0.976, 0.98] },
  };

  useTask((delta) => {
    rotation += delta / 2;
    uniforms.uTime.value += delta;

    woble = Math.sin(rotation) / 6;

    colorSwapCounter += delta;

    if (colorSwapCounter > 2.5) {
      colorSwapCounter = 0;

      if (currentColor == newGreen) {
        currentColor = newOrange;
      } else {
        currentColor = newGreen;
      }
    }
  });

  const gltfArrow = useGltf(`${base}/arrow.glb`);
  const gltfText = useGltf(`${base}/engineered.glb`);

  function changeMode(){
    darkMode = !darkMode
  }
</script>


<T.PerspectiveCamera makeDefault position={[0, 3, 150]} fov={65}>
  <OrbitControls />
</T.PerspectiveCamera>

<T.DirectionalLight intensity={1} position={[100, 100, 100]}/>
<T.AmbientLight intensity={1}/>

<HUD>
  <HudScene darkMode={darkMode} onselect={changeMode}></HudScene>
</HUD>

{#if darkMode}
<NightScene></NightScene>
{:else}
<LightScene></LightScene>
{/if}