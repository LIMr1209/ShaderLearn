using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace ImageEffects
{
    [Serializable, VolumeComponentMenuForRenderPipeline("Custom/Sharpen", typeof(UniversalRenderPipeline))]
    public class SharpenComponent : VolumeComponent, IPostProcessComponent
    {

        public const float SharpnessDefault = 0.5f;
        
        public ClampedFloatParameter sharpness =
            new ClampedFloatParameter(value: 0.0f, min: 0.0f, max: 1.0f, overrideState: true);


        // 告诉我们的效果应该何时呈现
        public bool IsActive() => sharpness.value > 0;
        public bool IsTileCompatible() => true;
    }
}