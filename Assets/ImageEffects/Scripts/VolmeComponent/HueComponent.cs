using System;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace ImageEffects
{
    [Serializable, VolumeComponentMenuForRenderPipeline("Custom/Hue", typeof(UniversalRenderPipeline))]
    public class HueComponent : VolumeComponent, IPostProcessComponent
    {
        public const float HueDegreeDefault = 20f;
        
        public ClampedFloatParameter hueDegree =
            new ClampedFloatParameter(value: 0, min: -180.0f, max: 180.0f, overrideState: true);

        // 告诉我们的效果应该何时呈现
        public bool IsActive() => hueDegree.value != 0;
        public bool IsTileCompatible() => true;
    }
}