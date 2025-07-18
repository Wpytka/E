<script lang="ts">
  import { T } from "@threlte/core";
  import { OrbitControls, interactivity } from "@threlte/extras";
  import { AutoColliders, RigidBody, Collider } from "@threlte/rapier";
  import { DEG2RAD } from "three/src/math/MathUtils.js";

  import fragShader from "/src/lib/assets/shaders/backgroud-fragment.glsl?raw";
  import vertexShader from "/src/lib/assets/shaders/vertex.glsl?raw";

  import { base } from "$app/paths";
  import Ballon from "./Ballon.svelte";

  type ballonProp = {
    color:[number,number,number],
    lightPos:[number,number,number],
    modelPath:string,
    startPos:{x:number,y:number,z:number},
    seed:number
  }

  let uniforms = {
    uTime: { value: 0 },
    u_lineThickness: { value: 2 },
    u_gridSpacing: { value: 0.05 },
    u_gridColor: { value: [0.973, 0.976, 0.98] },
    u_backgroundColor: { value: [0.173, 0.243, 0.314] },
  };

  let ballons = $state([])


  let ballonP:ballonProp = {color:[0.9, 0.1, 0.144], lightPos:[100, 100, 100], modelPath:`${base}/BallonE.glb`, startPos: {x:Math.random(), y:Math.random(), z:Math.random()}, seed:0}

  ballons.push(ballonP)

  function generateBallons(quantity:number){
    for(let i = 0; i < quantity; i++){
      let ballonP:ballonProp = {color:[Math.random(), Math.random(), Math.random()], lightPos:[100, 100, 100], modelPath:`${base}/BallonE.glb`, startPos: {x:(Math.random()*4)-2, y:(Math.random()*4)-2, z:(Math.random()*4)-2}, seed:(Math.random()*10)}
      ballons.push(ballonP)
    }
  }

  generateBallons(20)
</script>

<T.PerspectiveCamera makeDefault position={[0, 3, 250]} fov={65}>
  <OrbitControls />
</T.PerspectiveCamera>

<!-- BOX -->
<T.Group>
  <T.Mesh scale={200}>
    <T.BoxGeometry />
    <T.ShaderMaterial
      {uniforms}
      {vertexShader}
      fragmentShader={fragShader}
      side={1}
    />
  </T.Mesh>

  <T.Group position={[0, 0, 100]}>
    <Collider shape={"cuboid"} args={[100, 100, 1]} />
  </T.Group>

  <T.Group position={[0, 0, -100]}>
    <Collider shape={"cuboid"} args={[100, 100, 1]} />
  </T.Group>

  <T.Group rotation={[0, 90 * DEG2RAD, 0]} position={[100, 0, 0]}>
    <Collider shape={"cuboid"} args={[100, 100, 1]} />
  </T.Group>

  <T.Group rotation={[0, 90 * DEG2RAD, 0]} position={[-100, 0, 0]}>
    <Collider shape={"cuboid"} args={[100, 100, 1]} />
  </T.Group>

  <T.Group rotation={[90 * DEG2RAD, 0, 0]} position={[0, 100, 0]}>
    <Collider shape={"cuboid"} args={[100, 100, 1]} />
  </T.Group>

  <T.Group rotation={[90 * DEG2RAD, 0, 0]} position={[0, -100, 0]}>
    <Collider shape={"cuboid"} args={[100, 100, 1]} />
  </T.Group>
</T.Group>


{#each ballons as prop}
  <Ballon color={prop.color} ligthPos={prop.lightPos} modelPath={prop.modelPath} startPos={prop.startPos} seed={prop.seed}/>
{/each}
