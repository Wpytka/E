<script>
  import { T, useTask } from "@threlte/core";
  import { OrbitControls, useGltf } from "@threlte/extras";

  import fragShader from "/src/lib/assets/shaders/backgroud-fragment.glsl?raw";
  import vertexShader from "/src/lib/assets/shaders/vertex.glsl?raw";

  import neonFragment from "/src/lib/assets/shaders/neon-fragment.glsl?raw";

  import ballonFragment from "/src/lib/assets/shaders/ballon-fragment.glsl?raw";

  import { base } from "$app/paths";

  let rotation = $state(0);
  let woble = $state(0);
  let bob = $state(0)

  let newGreen = "#8DD8FF";
  let newOrange = "#FF4545";

  let currentColor = $state(newGreen);
  let colorSwapCounter = $state(0);

  let uniforms = {
    uTime: { value: 0 },
    u_lineThickness: { value: 2 },
    u_gridSpacing: { value: 0.05 },
    u_gridColor: { value: [0.973, 0.976, 0.98] },
    u_backgroundColor: { value: [0.173, 0.243, 0.314] },
  };

  let neonUniforms = {
    u_time: { value: 0.0 },
    u_neon_color: { value: [0.700,0.08,0.314] },
    u_cameraPosition: {value:[0, 3, 150]}
  };

  let ballonUnofrms = {
    u_lightPosition: {value:[300, 3, 150]},
    u_color: {value:[0.9, 0.1, 0.144]},
    u_time:{value: 0.0}
  }

  useTask((delta) => {
    rotation += delta / 2;
    uniforms.uTime.value += delta;
    neonUniforms.u_time.value += delta;
    ballonUnofrms.u_time.value += delta;

    woble = Math.sin(rotation) / 6;

    bob = Math.cos(rotation)

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
  const gltfBallonE = useGltf(`${base}/BallonE.glb`)
</script>

<T.PerspectiveCamera makeDefault position={[0, 3, 150]} fov={65}>
  <OrbitControls />
</T.PerspectiveCamera>

<T.Mesh scale={200}>
  <T.BoxGeometry />
  <T.ShaderMaterial
    {uniforms}
    {vertexShader}
    fragmentShader={fragShader}
    side={1}
  />
</T.Mesh>

{#if $gltfBallonE}
  <T.Mesh
    scale={30}
    rotation.x={Math.PI / 2}
    rotation.y={woble/4}
    rotation.z={woble/3 + woble*0.3}
    position.z={bob}
    position.y={bob*1.44}
    geometry={$gltfBallonE.nodes.Text.geometry}
  >
    <T.ShaderMaterial
      uniforms={ballonUnofrms}
      vertexShader={vertexShader}
      fragmentShader={ballonFragment}
      side={0}
    />
  </T.Mesh>
{/if}