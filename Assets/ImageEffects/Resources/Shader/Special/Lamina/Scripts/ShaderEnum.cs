
public class ShaderEnum
{
    public enum DepthMappingEnum
    {
        Vector = 0,
        World = 1,
        Camera = 2
    }
    
    public enum NoiseMappingEnum
    {
        UV = 0,
        Local = 1,
        World = 2
    }
    
    public enum NoiseTypeEnum
    {
        White = 0,
        Perlin = 1,
        Simplex = 2
    }
    
    public enum BlendModeEnum
    {
        Normal = -1,
        Add = 0,
        Subtract = 1,
        Multiply = 21,
        Lighten = 25,
        Darken = 24,
        Overlay = 23,
        Screen = 22,
        Softlight = 29
    }
}