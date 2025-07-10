<script lang="ts">
  import { base } from "$app/paths";
  import { T } from "@threlte/core";
  import { interactivity, useGltf, useViewport } from "@threlte/extras";

  let { darkMode, onselect } = $props();

  const lightColor = "#F8F9FA";
  const darkColor = "#2c3e50";

  interactivity();

  const viewport = useViewport();

  const gltfSun = useGltf(`${base}/sun.glb`);
  const gltfMoon = useGltf(`${base}/moon.glb`);
</script>

<T.OrthographicCamera makeDefault zoom={80} position={[0, 0, 10]} />
<T.AmbientLight intensity={10} />

<T.PointLight decay={1} intensity={Math.PI * 2} />


{#if $gltfSun && $gltfMoon}
<T.Mesh
  position={[($viewport.width / 2) - 1, ($viewport.height / 2) - 1, 0]}
  onclick={() => onselect()}
  scale={0.33}
  rotation.x={Math.PI / 2}
  rotation.y={-Math.PI / 2}

  geometry={darkMode ? $gltfSun.nodes.Circle.geometry: $gltfMoon.nodes.Circle.geometry}
>
  <T.MeshStandardMaterial
    metalness={0.7}
    roughness={0.8}
    depthTest
    depthWrite
    color={darkMode ? lightColor : darkColor}
  />
</T.Mesh>
{/if}
