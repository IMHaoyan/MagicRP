using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[DisallowMultipleComponent]
public class PerObjectMaterialProperties : MonoBehaviour
{
    private static int baseColorId = Shader.PropertyToID("_BaseColor");
    private static int cutoffId = Shader.PropertyToID("_Cutoff");
    private static int metallicId = Shader.PropertyToID("_Metallic");
    private static int smoothnessId = Shader.PropertyToID("_Smoothness");

    private static MaterialPropertyBlock block;
    [SerializeField] Color baseColor = Color.white;
    [SerializeField, Range(0f, 1f)] float cutoff = 0.8f;
    [SerializeField, Range(0f, 1f)] float metallic = 0.0f;
    [SerializeField, Range(0f, 1f)] float smoothness = 0.5f;

    void Awake()
    {
        OnValidate();
    }

    private void OnValidate()
    {
        if (block == null)
        {
            block = new MaterialPropertyBlock();
        }

        block.SetColor(baseColorId, baseColor);
        block.SetFloat(cutoffId, cutoff);
        block.SetFloat(metallicId, metallic);
        block.SetFloat(smoothnessId, smoothness);
        GetComponent<Renderer>().SetPropertyBlock(block);
    }
}