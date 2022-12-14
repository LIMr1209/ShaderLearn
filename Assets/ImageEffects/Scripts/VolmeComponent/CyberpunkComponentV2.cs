using System;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace ImageEffects
{
    [Serializable, VolumeComponentMenuForRenderPipeline("Custom/Cyberpunk V2", typeof(UniversalRenderPipeline))]
    public class CyberpunkComponentV2 : VolumeComponent, IPostProcessComponent
    {
        public ClampedFloatParameter red = new ClampedFloatParameter(value: 0.0f, min: -1.0f, max: 0.5f);
        public ClampedFloatParameter orange = new ClampedFloatParameter(value: 0.0f, min: -0.5f, max: 0.5f);
        public ClampedFloatParameter yellow = new ClampedFloatParameter(value: 0.0f, min: -0.5f, max: 1.0f);
        public ClampedFloatParameter green = new ClampedFloatParameter(value: 0.0f, min: -1.0f, max: 1.0f);
        public ClampedFloatParameter cyan = new ClampedFloatParameter(value: 0.0f, min: -1.0f, max: 1.0f);
        public ClampedFloatParameter blue = new ClampedFloatParameter(value: 0.0f, min: -1.0f, max: 0.5f);
        public ClampedFloatParameter purple = new ClampedFloatParameter(value: 0.0f, min: -0.5f, max: 0.5f);
        public ClampedFloatParameter magenta = new ClampedFloatParameter(value: 0.0f, min: -0.5f, max: 1.0f);
    
        public ClampedFloatParameter  power = new ClampedFloatParameter(value: 1, min: 1, max: 10, overrideState: true);
        public ClampedFloatParameter value = new ClampedFloatParameter(value: 1, min: 0.0f, max:2.0f);

        // 告诉我们的效果应该何时呈现
        public bool IsActive() => power.value > 1;
        public bool IsTileCompatible() => true;
    }
}