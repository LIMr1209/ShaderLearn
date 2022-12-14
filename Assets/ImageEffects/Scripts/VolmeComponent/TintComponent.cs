using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace ImageEffects
{
    [Serializable, VolumeComponentMenuForRenderPipeline("Custom/Tint", typeof(UniversalRenderPipeline))]
    public class TintComponent : VolumeComponent, IPostProcessComponent
    {

        public const float IntensityDefault = 1;
        
        public ClampedFloatParameter intensity =
            new ClampedFloatParameter(value: 0.0f, min: 0.0f, max: 1.0f, overrideState: true);


        public ColorParameter colorTint = new ColorParameter(new Color(0.9f, 1.0f, 0.0f, 1));

        // 告诉我们的效果应该何时呈现
        public bool IsActive() => intensity.value > 0;
        public bool IsTileCompatible() => true;
    }
}