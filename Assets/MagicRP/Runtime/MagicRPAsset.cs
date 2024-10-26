using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[CreateAssetMenu(menuName = "MagicRP/Magic Render Pipeline")]
public class MagicRPAsset : RenderPipelineAsset
{
    [SerializeField] private bool useDynamicBatching = true, useGPUInstancing = true, useSRPBatcher = true;
    [SerializeField] private ShadowSettings shadows = default;

    protected override RenderPipeline CreatePipeline()
    {
        return new MagicRP(useDynamicBatching, useGPUInstancing, useSRPBatcher, shadows);
    }
}