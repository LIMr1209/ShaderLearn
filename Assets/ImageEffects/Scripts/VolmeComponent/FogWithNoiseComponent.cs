using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace ImageEffects
{
    [Serializable, VolumeComponentMenuForRenderPipeline("Custom/FogWithNoise", typeof(UniversalRenderPipeline))]
    public class FogWithNoiseComponent : VolumeComponent, IPostProcessComponent
    {
        public const float FogDensityDefault = 1.0f;

        public ClampedFloatParameter fogDensity = new ClampedFloatParameter(value: 0.0f, min: 0.0f, max: 3.0f, overrideState: true); // 雾浓度

        public ColorParameter fogColor = new ColorParameter(Color.white); // 雾颜色
        
        
        public FloatParameter fogStart = new FloatParameter(0.0f); // 雾颜色
        
        public FloatParameter fogEnd = new FloatParameter(2.0f); // 雾颜色

        public ClampedFloatParameter fogXSpeed = new ClampedFloatParameter(value: 0.1f, min: -0.5f, max: 0.5f, overrideState: true); // 雾浓度
        public ClampedFloatParameter fogYSpeed = new ClampedFloatParameter(value: 0.1f, min: -0.5f, max: 0.5f, overrideState: true); // 雾浓度
        public ClampedFloatParameter noiseAmount = new ClampedFloatParameter(value: 1.0f, min: 0.0f, max: 3.0f, overrideState: true); // 雾浓度

        
        
        // 告诉我们的效果应该何时呈现
        public bool IsActive() => fogDensity.value > 0;
        public bool IsTileCompatible() => false;
    }
}