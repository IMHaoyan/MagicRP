using UnityEngine;
using UnityEngine.Rendering;

public partial class CameraRenderer
{
    private ScriptableRenderContext context;
    private Camera camera;
    private const string cmdName = "Render Camera";
    private CullingResults cullingResults;
    private Lighting lighting = new Lighting();

    private CommandBuffer cmd = new CommandBuffer()
    {
        name = cmdName
    };

    private static ShaderTagId unlitShaderTagId = new ShaderTagId("SRPDefaultUnlit");
    private static ShaderTagId litShaderTagId = new ShaderTagId("MagicRPLit");

    public void Render(ScriptableRenderContext context, Camera camera, bool useDynamicBatching, bool useGPUInstancing,
        ShadowSettings shadowSettings)
    {
        this.context = context;
        this.camera = camera;

        PrepareBuffer();
        PrepareForSceneWindow();

        if (!Cull(shadowSettings.maxDistance))
        {
            return;
        }

        cmd.BeginSample(SampleName);
        ExecuteBuffer();
        lighting.Setup(context, cullingResults, shadowSettings);
        cmd.EndSample(SampleName);

        Setup();

        DrawVisibleGeometry(useDynamicBatching, useGPUInstancing);
        DrawUnsupportedShaders();
        DrawGizmos();

        lighting.Cleanup();
        Submit();
    }

    bool Cull(float maxShadowDistance)
    {
        if (camera.TryGetCullingParameters(out ScriptableCullingParameters p))
        {
            p.shadowDistance = Mathf.Min(maxShadowDistance, camera.farClipPlane);
            cullingResults = context.Cull(ref p);
            return true;
        }

        return false;
    }

    void Setup()
    {
        context.SetupCameraProperties(camera);

        //From 1 to 4 they are Skybox, Color, Depth, and Nothing.
        CameraClearFlags flags = camera.clearFlags;
        bool clearDepth = flags <= CameraClearFlags.Depth;
        bool clearColor = flags <= CameraClearFlags.Color;
        cmd.ClearRenderTarget(clearDepth, clearColor, clearColor ? camera.backgroundColor.linear : Color.clear);

        cmd.BeginSample(SampleName);
        ExecuteBuffer();
    }

    void Submit()
    {
        cmd.EndSample(SampleName);
        ExecuteBuffer();
        context.Submit();
    }

    void ExecuteBuffer()
    {
        context.ExecuteCommandBuffer(cmd);
        cmd.Clear();
    }

    void DrawVisibleGeometry(bool useDynamicBatching, bool useGPUInstancing)
    {
        // Opaque
        var sortingSettings = new SortingSettings(camera)
        {
            criteria = SortingCriteria.CommonOpaque
        };
        var drawingSettings = new DrawingSettings(unlitShaderTagId, sortingSettings)
        {
            enableDynamicBatching = useDynamicBatching,
            enableInstancing = useGPUInstancing,
            perObjectData = PerObjectData.Lightmaps | PerObjectData.LightProbe | PerObjectData.LightProbeProxyVolume
        };
        drawingSettings.SetShaderPassName(1, litShaderTagId);

        var filteringSettings = new FilteringSettings(RenderQueueRange.opaque);
        context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);

        // Skybox
        if (camera.clearFlags == CameraClearFlags.Skybox)
        {
            context.DrawSkybox(camera);
        }

        // Transparent
        sortingSettings.criteria = SortingCriteria.CommonTransparent;
        drawingSettings.sortingSettings = sortingSettings;
        filteringSettings.renderQueueRange = RenderQueueRange.transparent;
        context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);
    }
}