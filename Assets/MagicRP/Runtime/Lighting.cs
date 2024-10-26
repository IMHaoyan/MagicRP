using UnityEngine;
using UnityEngine.Rendering;
using Unity.Collections;

public class Lighting
{
    private const string cmdName = "Lighting";
    private static int dirLightCountId = Shader.PropertyToID("_DirectionalLightCount");
    private static int dirLightColorsId = Shader.PropertyToID("_DirectionalLightColors");
    private static int dirLightDirectionsId = Shader.PropertyToID("_DirectionalLightDirections");
    private static int dirLightShadowDataId = Shader.PropertyToID("_DirectionalLightShadowData");
    
    const int maxDirLightCount = 4;
    private static Vector4[] dirLightColors = new Vector4[maxDirLightCount];
    private static Vector4[] dirLightDirections = new Vector4[maxDirLightCount];
    private static Vector4[] dirLightShadowData = new Vector4[maxDirLightCount];
    
    private CullingResults cullingResults;
    private Shadows shadows = new Shadows();

    private CommandBuffer cmd = new CommandBuffer()
    {
        name = cmdName
    };

    public void Setup(ScriptableRenderContext context, CullingResults cullingResults, ShadowSettings shadowSettings)
    {
        this.cullingResults = cullingResults;
        cmd.BeginSample(cmdName);
        shadows.Setup(context, cullingResults, shadowSettings);
        SetupLights();
        shadows.Render();
        cmd.EndSample(cmdName);
        context.ExecuteCommandBuffer(cmd);
        cmd.Clear();
    }

    void SetupDirectionalLight(int index, ref VisibleLight visibleLight)
    {
        dirLightColors[index] = visibleLight.finalColor;
        dirLightDirections[index] = -visibleLight.localToWorldMatrix.GetColumn(2);
        dirLightShadowData[index] =  shadows.ReserveDirectionalShadows(visibleLight.light, index);
    }
    
    void SetupLights()
    {
        NativeArray<VisibleLight> visibleLights = cullingResults.visibleLights;
        int dirLightCount = 0;
        for (int i = 0; i < visibleLights.Length; i++)
        {
            VisibleLight visibleLight = visibleLights[i];
            if (visibleLight.lightType == LightType.Directional)
            {
                SetupDirectionalLight(dirLightCount++, ref visibleLight);
                if (dirLightCount >= maxDirLightCount)
                {
                    break;
                }
            }
        }

        cmd.SetGlobalInt(dirLightCountId, visibleLights.Length);
        cmd.SetGlobalVectorArray(dirLightColorsId, dirLightColors);
        cmd.SetGlobalVectorArray(dirLightDirectionsId, dirLightDirections);
        cmd.SetGlobalVectorArray(dirLightShadowDataId, dirLightShadowData);
    }

    public void Cleanup()
    {
        shadows.Cleanup();
    }
}