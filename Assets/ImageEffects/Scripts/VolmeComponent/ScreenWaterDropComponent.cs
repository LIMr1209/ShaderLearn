using System;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace ImageEffects
{
    [Serializable, VolumeComponentMenuForRenderPipeline("Custom/ScreenWaterDrop", typeof(UniversalRenderPipeline))]
    public class ScreenWaterDropComponent : VolumeComponent, IPostProcessComponent
    {
        public BoolParameter status = new BoolParameter(false, overrideState: true);
        public ClampedFloatParameter distortion = new ClampedFloatParameter(value: 8.0f, min: 5, max: 64, overrideState: true);
        public ClampedFloatParameter sizeX = new ClampedFloatParameter(value: 1.0f, min: 0, max: 7, overrideState: true);
        public ClampedFloatParameter sizeY = new ClampedFloatParameter(value: 0.5f, min: 0, max: 7, overrideState: true);
        public ClampedFloatParameter dropSpeed = new ClampedFloatParameter(value: 3.6f, min: 0, max: 10, overrideState: true);
        
        // 告诉我们的效果应该何时呈现
        public bool IsActive() => status.value;
        public bool IsTileCompatible() => false;
    }
}