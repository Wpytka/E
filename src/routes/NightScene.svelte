<script lang="ts">
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
  let nudgeDirection = $state({});

  const initialVelocity = 9.0;
  const acceleration = -9.0;
  const totalNudgeTime = 1.0;

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
    u_neon_color: { value: [0.7, 0.08, 0.314] },
    u_cameraPosition: { value: [0, 3, 150] },
  };

  let ballonUnofrms = {
    u_lightPosition: { value: [100, 100, 100] },
    u_color: { value: [0.9, 0.1, 0.144] },
    u_time: { value: 0.0 },
  };

  useTask((delta) => {
    uniforms.uTime.value += delta;
    neonUniforms.u_time.value += delta;
    ballonUnofrms.u_time.value += delta;

    rotation += delta / 2;
    wobble = Math.sin(rotation) / 6;

    let bob = Math.sin(rotation);

    if (nudged) {
      if (nudgeTime <= 0) {
        nudgeTime = totalNudgeTime;
        nudged = false;
        velocity = initialVelocity;
        bob = 0;
        nudgeDirection = {};
      } else {
        switch (nudgeDirection.faceAxis) {
          case "y":
              ePosZ = nudgeDirection.face ? (ePosZ - velocity * delta) : (ePosZ + velocity * delta)
              ePosY = nudgeDirection.quadV ? (ePosY + (velocity/2) * delta) : (ePosY - (velocity/2) * delta)
              ePosX = nudgeDirection.quadH ? (ePosX + (velocity/2) * delta) : (ePosX - (velocity/2) * delta)
            break;
          case "z":
            ePosY = nudgeDirection.face ? (ePosY + velocity * delta) : (ePosY - velocity * delta)
            break;
          case "x":
            ePosX = nudgeDirection.face ? (ePosX - velocity * delta) : (ePosX + velocity * delta)
            break;
        }
        nudgeTime -= delta;
        
        let adjustedAcceleration = acceleration + (nudgeTime - totalNudgeTime)
        velocity = velocity + adjustedAcceleration * delta;
      }
    } else {
      ePosY += (bob * 1.44) / 100;
      ePosZ += bob / 100;
    }
  });

  const gltfArrow = useGltf(`${base}/arrow.glb`);
  const gltfText = useGltf(`${base}/engineered.glb`);
  const gltfBallonE = useGltf(`${base}/BallonE.glb`);

  function nudge(e) {
    nudged = true;

    nudgeDirection = getCubeFace(e.intersections[0]);
  }

  function getCubeFace(intersection) {
    const normal = intersection.normal;
    
    let faceName;
    let faceAxis;
    let quadV;
    let quadH;

    // Find the dominant axis of the normal
    const absNormal = {
      x: Math.abs(normal.x),
      y: Math.abs(normal.y),
      z: Math.abs(normal.z),
    };

    if (absNormal.x > absNormal.y && absNormal.x > absNormal.z) {
      // X-axis dominant
      faceName = normal.x > 0;
      faceAxis = "x";
      quadV = false;
      quadH = false;
    } else if (absNormal.y > absNormal.x && absNormal.y > absNormal.z) {
      // Y-axis dominant
      faceName = normal.y > 0;
      faceAxis = "y";
      quadV = intersection.eventObject.position.y - intersection.point.y > 0;
      quadH = intersection.eventObject.position.x - intersection.point.x > 0;;
    } else {
      // Z-axis dominant
      faceName = normal.z > 0;
      faceAxis = "z";
      quadV = false;
      quadH = false;
    }

    return {
      face: faceName,
      faceAxis: faceAxis,
      quadV: quadV,
      quadH:quadH
    };
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
    onclick={(e) => nudge(e)}
    scale={30}
    rotation.x={Math.PI / 2}
    rotation.y={wobble / 4}
    rotation.z={wobble / 3 + wobble * 0.3}
    position.x={ePosX}
    position.y={ePosY}
    position.z={ePosZ}
    geometry={$gltfBallonE.nodes.Text.geometry}
  >
    <T.ShaderMaterial
      uniforms={ballonUnofrms}
      {vertexShader}
      fragmentShader={ballonFragment}
      side={0}
    />
  </T.Mesh>
{/if}
