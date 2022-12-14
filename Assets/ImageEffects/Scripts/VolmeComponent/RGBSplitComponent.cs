using System;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace ImageEffects
{
    [Serializable, VolumeComponentMenuForRenderPipeline("Custom/RGBSplit", typeof(UniversalRenderPipeline))]
    public class RGBSplitComponent : VolumeComponent, IPostProcessComponent
    {
        public const float AmplitudeDefault = 3.0f;
        
        public ClampedFloatParameter amplitude = new ClampedFloatParameter(value: 0, min: 0, max: 5, overrideState: true);
        public ClampedFloatParameter speed = new ClampedFloatParameter(value: 1, min: 0, max: 1, overrideState: true);

        // 告诉我们的效果应该何时呈现
        public bool IsActive() => amplitude.value > 0 && speed.value > 0;
        public bool IsTileCompatible() => false;
    }
}