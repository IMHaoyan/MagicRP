using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class MagicRP : RenderPipeline
{
    private CameraRenderer renderer = new CameraRenderer();
    private bool useDynamicBatching, useGPUInstancing;
    private ShadowSettings shadowSettings;

    public MagicRP(bool useDynamicBatching, bool useGPUInstancing, bool useSRPBatcher, ShadowSettings shadowSettings)
    {
        this.shadowSettings = shadowSettings;
        this.useDynamicBatching = useDynamicBatching;
        this.useGPUInstancing = useGPUInstancing;
        GraphicsSettings.useScriptableRenderPipelineBatching = useSRPBatcher;
        GraphicsSettings.lightsUseLinearIntensity = true;
    }
    // legacy
    protected override void Render(ScriptableRenderContext context, Camera[] cameras)
    {
    }

    protected override void Render(ScriptableRenderContext context, List<Camera> cameras)
    {
        for (int i = 0; i < cameras.Count; i++)
        {
            renderer.Render(context, cameras[i], useDynamicBatching, useGPUInstancing, shadowSettings);
        }
    }
}