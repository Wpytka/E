<script>
  import { T, useTask } from "@threlte/core";
  import { OrbitControls, useGltf } from "@threlte/extras";
  import fragShader from "/src/lib/assets/shaders/backgroud-fragment.glsl?raw";
  import vertexShader from "/src/lib/assets/shaders/vertex.glsl?raw";

  let rotation = $state(0);
  let woble = $state(0);

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

  const gltfArrow = useGltf("/arrow.glb");
  const gltfText = useGltf("/engineered.glb");
</script>


<T.PerspectiveCamera makeDefault position={[0, 3, 150]} fov={65}>
  <OrbitControls />
</T.PerspectiveCamera>

<T.DirectionalLight intensity={1} position={[20, 60, 10]}/>
<T.AmbientLight intensity={1}/>

<T.Mesh scale={200}>
  <T.BoxGeometry />
  <T.ShaderMaterial
    {uniforms}
    {vertexShader}
    fragmentShader={fragShader}
    side={1}
  />
</T.Mesh>

{#if $gltfArrow}
  <T.Mesh
    scale={4}
    rotation.x={woble}
    rotation.z={-rotation}
    geometry={$gltfArrow.nodes.Cone.geometry}
  >
    <T.MeshPhysicalMaterial
      color={newGreen}
      vertexColors= {false}
      transmission= {1.0}
      thickness= {0.70}
      roughness= {0.0}
      metalness= {0.0}
      transparent= {true}
      opacity = {0.9}
      side={T.DoubleSide}
    />
  </T.Mesh>
  <T.Mesh
    scale={4}
    rotation.x={Math.PI / 2 + woble}
    rotation.z={-rotation+0.1}
    rotation.y={0.1}
    geometry={$gltfArrow.nodes.Cone.geometry}
  >
    <T.MeshPhysicalMaterial
      color={newOrange}
      vertexColors= {false}
      transmission= {1.0}
      thickness= {0.70}
      roughness= {0.0}
      metalness= {0.0}
      transparent={true}
      opacity = {0.9}
      side={T.DoubleSide}
    />
  </T.Mesh>
{/if}

{#if $gltfText}
  <T.Mesh
    scale={20}
    rotation.x = {Math.PI / 2}
    geometry={$gltfText.nodes.Text.geometry}
    position.y={-37}
    position.z ={30}
  >
    <T.MeshStandardMaterial
      metalness={0.7}
      roughness={0.8}
      depthTest
      depthWrite
      color={[0.173, 0.243, 0.314]}
    />
  </T.Mesh>
{/if}

