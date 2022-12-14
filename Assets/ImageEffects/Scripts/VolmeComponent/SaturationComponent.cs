using System;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace ImageEffects
{
    [Serializable, VolumeComponentMenuForRenderPipeline("Custom/Saturation", typeof(UniversalRenderPipeline))]
    public class SaturationComponent : VolumeComponent, IPostProcessComponent
    {
        public const float SaturationDefault = 0;
        public ClampedFloatParameter saturation = new ClampedFloatParameter(value: 1, min: 0, max: 2, overrideState: true);

        // 告诉我们的效果应该何时呈现
        public bool IsActive() => saturation.value != 1;
        public bool IsTileCompatible() => true;
    }
}