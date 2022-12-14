using System;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace ImageEffects
{
    [Serializable, VolumeComponentMenuForRenderPipeline("Custom/GaussianBlur", typeof(UniversalRenderPipeline))]
    public class GaussianBlurComponent : VolumeComponent, IPostProcessComponent
    {
        public const float BlurRadiusDefault = 3.0f;
        
        public FloatParameter blurRadius = new ClampedFloatParameter(value: 0, min: 0, max: 5);

        public IntParameter iteration = new ClampedIntParameter(value: 6, min: 1, max: 15);

        public FloatParameter rTDownScaling = new ClampedFloatParameter(value: 2, min: 1, max: 8);


        // 告诉我们的效果应该何时呈现
        public bool IsActive() => blurRadius.value > 0;
        public bool IsTileCompatible() => true;
    }
}