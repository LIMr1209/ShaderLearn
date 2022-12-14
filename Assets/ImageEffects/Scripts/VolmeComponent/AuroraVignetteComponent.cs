using System;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace ImageEffects
{
    [Serializable, VolumeComponentMenuForRenderPipeline("Custom/AuroraVignette", typeof(UniversalRenderPipeline))]
    public class AuroraVignetteComponent : VolumeComponent, IPostProcessComponent
    {
        // 从0到1的强度参数

        public const float VignetteSmothnessDefault = 0.5f;
        
        public ClampedFloatParameter vignetteArea = new ClampedFloatParameter(value: 0.8f, min: 0, max: 1, overrideState: true);
        public ClampedFloatParameter vignetteSmothness = new ClampedFloatParameter(value: 0.0f, min: 0, max: 1, overrideState: true);
        public ClampedFloatParameter vignetteFading = new ClampedFloatParameter(value: 1f, min: 0, max: 1, overrideState: true);
        public ClampedFloatParameter colorChange = new ClampedFloatParameter(value: 0.1f, min: 0.1f, max: 1, overrideState: true);
        public ClampedFloatParameter colorFactorR = new ClampedFloatParameter(value: 1f, min: 0, max: 2, overrideState: true);
        public ClampedFloatParameter colorFactorG = new ClampedFloatParameter(value: 1f, min: 0, max: 2, overrideState: true);
        public ClampedFloatParameter colorFactorB = new ClampedFloatParameter(value: 1f, min: 0, max: 2, overrideState: true);
        public ClampedFloatParameter flowSpeed = new ClampedFloatParameter(value: 1f, min: -2, max: 2, overrideState: true);
        
        // 告诉我们的效果应该何时呈现
        public bool IsActive() => vignetteSmothness.value >0 && vignetteFading.value>0;
        public bool IsTileCompatible() => false;
    }
}