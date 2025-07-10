<script>
  import { T, useTask } from "@threlte/core";
  import { OrbitControls, useGltf, interactivity } from "@threlte/extras";

  import fragShader from "/src/lib/assets/shaders/backgroud-fragment.glsl?raw";
  import vertexShader from "/src/lib/assets/shaders/vertex.glsl?raw";

  import neonFragment from "/src/lib/assets/shaders/neon-fragment.glsl?raw";

  import ballonFragment from "/src/lib/assets/shaders/ballon-fragment.glsl?raw";

  import { base } from "$app/paths";

  let rotation = $state(0);
  let wobble = $state(0);

  let ePosX = $state(0);
  let ePosY = $state(0);
  let ePosZ = $state(0);

  let nudged = $state(false);

  const initialVelocity = 9.0
  const acceleration = -9.0
  const totalNudgeTime = 1.0

  let velocity = $state(initialVelocity);
  let nudgeTime = $state(totalNudgeTime);

  interactivity();

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
    uniforms.uTime.value += delta;
    neonUniforms.u_time.value += delta;
    ballonUnofrms.u_time.value += delta;

    rotation += delta / 2;
    wobble = Math.sin(rotation) / 6;

    let bob = Math.sin(rotation)

    if (nudged){
      if (nudgeTime <= 0)
      {
        nudgeTime = totalNudgeTime;
        nudged = false;
        velocity = initialVelocity;
        bob = 0;
      }
      else {
        ePosZ -= velocity * delta
        ePosY += velocity * delta * Math.sign(bob)
        
        nudgeTime -= delta
        velocity = velocity + acceleration*delta
      }
    }
    else {
      ePosY += (bob*1.44)/100
      ePosZ += (bob)/100
    }
  });

  const gltfArrow = useGltf(`${base}/arrow.glb`);
  const gltfText = useGltf(`${base}/engineered.glb`);
  const gltfBallonE = useGltf(`${base}/BallonE.glb`)

  function nudge(){
    nudged = true
  }
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
    onclick={() => nudge()}
    scale={30}
    rotation.x={Math.PI / 2}
    rotation.y={wobble/4}
    rotation.z={wobble/3 + wobble*0.3}
    position.x={ePosX}
    position.y={ePosY}
    position.z={ePosZ}
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