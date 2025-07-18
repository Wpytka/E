<script lang="ts">
    import { T, useTask } from "@threlte/core";
    import { OrbitControls, useGltf, interactivity } from "@threlte/extras";
    import { AutoColliders, RigidBody } from "@threlte/rapier";

    import vertexShader from "/src/lib/assets/shaders/vertex.glsl?raw";
    import ballonFragment from "/src/lib/assets/shaders/ballon-fragment.glsl?raw";

    import { base } from "$app/paths";

    const { color, ligthPos, modelPath, startPos, seed } = $props();

    let rotation = $state(seed);
    let wobble = $state(0);

    let VelocityX = $state(0);
    let VelocityY = $state(0);
    let VelocityZ = $state(0);

    let nudged = $state(false);
    let nudgeDirection = $state({});

    const initialVelocity = 180.0;
    const acceleration = -20;
    const totalNudgeTime = 0.7;

    let velocity = $state(initialVelocity);
    let nudgeTime = $state(totalNudgeTime);

    interactivity();

    const gltfBallon = useGltf(modelPath);

    let ballonUnofrms = {
        u_lightPosition: { value: ligthPos },
        u_color: { value: color },
        u_time: { value: 0.0 },
    };

    function nudge(e) {
        nudged = true;
        nudgeDirection = getCubeFace(e.intersections[0]);

        switch (nudgeDirection.faceAxis) {
            case "y":
                VelocityZ = nudgeDirection.face
                    ? VelocityZ - initialVelocity
                    : VelocityZ + initialVelocity;
                VelocityY = nudgeDirection.quadV
                    ? VelocityY + initialVelocity / 4
                    : VelocityY - initialVelocity / 4;
                VelocityX = nudgeDirection.quadH
                    ? VelocityX + initialVelocity / 4
                    : VelocityX - initialVelocity / 4;
                break;
            case "z":
                VelocityY = nudgeDirection.face
                    ? VelocityY + initialVelocity
                    : VelocityY - initialVelocity;
                break;
            case "x":
                VelocityX = nudgeDirection.face
                    ? VelocityX - initialVelocity
                    : VelocityX + initialVelocity;
                break;
        }
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
            quadV =
                intersection.eventObject.position.y - intersection.point.y > 0;
            quadH =
                intersection.eventObject.position.x - intersection.point.x > 0;
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
            quadH: quadH,
        };
    }

    useTask((delta) => {
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
                        VelocityZ = nudgeDirection.face
                            ? -(initialVelocity * Math.pow( 0.47623, (totalNudgeTime - nudgeTime) * 10))
                            : +(initialVelocity *Math.pow(0.47623, (totalNudgeTime - nudgeTime) * 10));
                        VelocityY = nudgeDirection.quadV 
                            ? (initialVelocity / 4) * Math.pow(0.45258, (totalNudgeTime - nudgeTime) * 10)
                            : -((initialVelocity / 4) *Math.pow(0.45258,(totalNudgeTime - nudgeTime) * 10));
                        VelocityX = nudgeDirection.quadH
                            ? (initialVelocity / 4) * Math.pow(0.45258,(totalNudgeTime - nudgeTime) * 10)
                            : -((initialVelocity / 4) *Math.pow(0.45258,(totalNudgeTime - nudgeTime) * 10));
                        break;
                    case "z":
                        VelocityY = nudgeDirection.face
                            ? (initialVelocity * Math.pow( 0.47623, (totalNudgeTime - nudgeTime) * 10))
                            : -(initialVelocity * Math.pow( 0.47623, (totalNudgeTime - nudgeTime) * 10))
                        break;
                    case "x":
                        VelocityX = nudgeDirection.face
                            ? -(initialVelocity * Math.pow( 0.47623, (totalNudgeTime - nudgeTime) * 10))
                            : (initialVelocity * Math.pow( 0.47623, (totalNudgeTime - nudgeTime) * 10))
                        break;
                }

                nudgeTime -= delta;
            }
        } else {
            VelocityY = bob * 1.44;
            VelocityZ = bob;
            VelocityX = bob;
        }
    });
</script>

{#if $gltfBallon}
    <T.Group
        scale={30}
        rotation.x={Math.PI / 2}
        rotation.y={wobble / 4}
        rotation.z={wobble / 3 + wobble * 0.3}
        position.x={startPos.x}
        position.y={startPos.y}
        position.z={startPos.z}
    >
        <RigidBody
            angularVelocity={[0, wobble / 4, wobble / 30]}
            linearVelocity={[VelocityX, VelocityY, VelocityZ]}
        >
            <AutoColliders shape={"cuboid"} mass={0.0000000001}>
                <T.Mesh
                    onclick={(e) => nudge(e)}
                    geometry={$gltfBallon.nodes.Text.geometry}
                >
                    <T.ShaderMaterial
                        uniforms={ballonUnofrms}
                        {vertexShader}
                        fragmentShader={ballonFragment}
                        side={0}
                    />
                </T.Mesh>
            </AutoColliders>
        </RigidBody>
    </T.Group>
{/if}
