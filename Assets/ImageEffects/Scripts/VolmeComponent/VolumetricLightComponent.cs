using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace ImageEffects
{
    [Serializable, VolumeComponentMenuForRenderPipeline("Custom/VolumetricLight", typeof(UniversalRenderPipeline))]
    public class VolumetricLightComponent : VolumeComponent, IPostProcessComponent
    {
        
        public const float IntensityDefault = 1;

        public ClampedFloatParameter intensity = new ClampedFloatParameter(value: 0, min: 0, max: 1, overrideState: true);

        public ClampedFloatParameter blurWidth = new ClampedFloatParameter(value: 0.85f, min: 0, max: 1, overrideState: true);


        // 告诉我们的效果应该何时呈现
        public bool IsActive() => intensity.value > 0;
        public bool IsTileCompatible() => true;
    }
}