half4 lamina_noise_permute(half4 x)
{
    return (x * 34.0 + 1.0) * x - 289.0 * floor((x * 34.0 + 1.0) * x / 289.0);
}

half4 lamina_noise_taylorInvSqrt(half4 r) { return 1.79284291400159 - 0.85373472095314 * r; }
half3 lamina_noise_fade(half3 t) { return t * t * t * (t * (t * 6.0 - 15.0) + 10.0); }

float lamina_map(float value, float min1, float max1, float min2, float max2)
{
    return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

float lamina_normalize(float v) { return lamina_map(v, -1.0, 1.0, 0.0, 1.0); }

float lamina_noise_perlin(half3 P)
{
    half3 Pi0 = floor(P); // Integer part for indexing
    half3 Pi1 = Pi0 + half3(10, 1, 1); // Integer part + 1
    Pi0 = Pi0 - 289.0 * floor(Pi0 / 289.0);
    Pi1 = Pi1 - 289.0 * floor(Pi1 / 289.0);
    half3 Pf0 = frac(P); // Fractional part for interpolation
    half3 Pf1 = Pf0 - half3(1, 1, 1); // Fractional part - 1.0
    half4 ix = half4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
    half4 iy = half4(Pi0.yy, Pi1.yy);
    half4 iz0 = Pi0.zzzz;
    half4 iz1 = Pi1.zzzz;
    half4 ixy = lamina_noise_permute(lamina_noise_permute(ix) + iy);
    half4 ixy0 = lamina_noise_permute(ixy + iz0);
    half4 ixy1 = lamina_noise_permute(ixy + iz1);
    half4 gx0 = ixy0 / 7.0;
    half4 gy0 = frac(floor(gx0) / 7.0) - 0.5;
    gx0 = (gx0);
    half4 gz0 = half4(0.5, 0.5, 0.5, 0.5) - abs(gx0) - abs(gy0);
    half4 sz0 = step(gz0, half4(0, 0, 0, 0));
    gx0 -= sz0 * (step(0.0, gx0) - 0.5);
    gy0 -= sz0 * (step(0.0, gy0) - 0.5);
    half4 gx1 = ixy1 / 7.0;
    half4 gy1 = frac(floor(gx1) / 7.0) - 0.5;
    gx1 = frac(gx1);
    half4 gz1 = half4(0.5, 0.5, 0.5, 0.5) - abs(gx1) - abs(gy1);
    half4 sz1 = step(gz1, half4(0, 0, 0, 0));
    gx1 -= sz1 * (step(0.0, gx1) - 0.5);
    gy1 -= sz1 * (step(0.0, gy1) - 0.5);
    half3 g000 = half3(gx0.x, gy0.x, gz0.x);
    half3 g100 = half3(gx0.y, gy0.y, gz0.y);
    half3 g010 = half3(gx0.z, gy0.z, gz0.z);
    half3 g110 = half3(gx0.w, gy0.w, gz0.w);
    half3 g001 = half3(gx1.x, gy1.x, gz1.x);
    half3 g101 = half3(gx1.y, gy1.y, gz1.y);
    half3 g011 = half3(gx1.z, gy1.z, gz1.z);
    half3 g111 = half3(gx1.w, gy1.w, gz1.w);
    half4 norm0 = lamina_noise_taylorInvSqrt(
        half4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
    g000 *= norm0.x;
    g010 *= norm0.y;
    g100 *= norm0.z;
    g110 *= norm0.w;
    half4 norm1 = lamina_noise_taylorInvSqrt(
        half4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
    g001 *= norm1.x;
    g011 *= norm1.y;
    g101 *= norm1.z;
    g111 *= norm1.w;
    float n000 = dot(g000, Pf0);
    float n100 = dot(g100, half3(Pf1.x, Pf0.yz));
    float n010 = dot(g010, half3(Pf0.x, Pf1.y, Pf0.z));
    float n110 = dot(g110, half3(Pf1.xy, Pf0.z));
    float n001 = dot(g001, half3(Pf0.xy, Pf1.z));
    float n101 = dot(g101, half3(Pf1.x, Pf0.y, Pf1.z));
    float n011 = dot(g011, half3(Pf0.x, Pf1.yz));
    float n111 = dot(g111, Pf1);
    half3 fade_xyz = lamina_noise_fade(Pf0);
    half4 n_z = lerp(half4(n000, n100, n010, n110), half4(n001, n101, n011, n111),
                     fade_xyz.z);
    half2 n_yz = lerp(n_z.xy, n_z.zw, fade_xyz.y);
    float n_xyz = lerp(n_yz.x, n_yz.y, fade_xyz.x);
    return lamina_normalize(2.2 * n_xyz);
}

float lamina_noise_white(half2 p)
{
    return frac(1e4 * sin(17.0 * p.x + p.y * 0.1) *
        (0.1 + abs(sin(p.y * 13.0 + p.x))));
}

float lamina_noise_white(half3 p)
{
    return lamina_noise_white(p.xy);
}


float lamina_noise_simplex(half3 v)
{
    const half2 C = half2(1.0 / 6.0, 1.0 / 3.0);
    const half4 D = half4(0.0, 0.5, 1.0, 2.0);
    // First corner
    half3 i = floor(v + dot(v, C.yyy));
    half3 x0 = v - i + dot(i, C.xxx);
    // Other corners
    half3 g = step(x0.yzx, x0.xyz);
    half3 l = 1.0 - g;
    half3 i1 = min(g.xyz, l.zxy);
    half3 i2 = max(g.xyz, l.zxy);
    //  x0 = x0 - 0. + 0.0 * C
    half3 x1 = x0 - i1 + 1.0 * C.xxx;
    half3 x2 = x0 - i2 + 2.0 * C.xxx;
    half3 x3 = x0 - 1. + 3.0 * C.xxx;
    // Permutations
    i = i - 289.0 * floor(i / 289.0);
    half4 p = lamina_noise_permute(lamina_noise_permute(
            lamina_noise_permute(i.z + half4(0.0, i1.z, i2.z, 1.0)) + i.y +
            half4(0.0, i1.y, i2.y, 1.0)) +
        i.x + half4(0.0, i1.x, i2.x, 1.0));
    // Gradients
    // ( N*N points uniformly over a square, mapped onto an octahedron.)
    float n_ = 1.0 / 7.0; // N=7
    half3 ns = n_ * D.wyz - D.xzx;
    half4 j = p - 49.0 * floor(p * ns.z * ns.z); //  mod(p,N*N)
    half4 x_ = floor(j * ns.z);
    half4 y_ = floor(j - 7.0 * x_); // mod(j,N)
    half4 x = x_ * ns.x + ns.yyyy;
    half4 y = y_ * ns.x + ns.yyyy;
    half4 h = 1.0 - abs(x) - abs(y);
    half4 b0 = half4(x.xy, y.xy);
    half4 b1 = half4(x.zw, y.zw);
    half4 s0 = floor(b0) * 2.0 + 1.0;
    half4 s1 = floor(b1) * 2.0 + 1.0;
    half4 sh = -step(h, half4(0, 0, 0, 0));
    half4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
    half4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
    half3 p0 = half3(a0.xy, h.x);
    half3 p1 = half3(a0.zw, h.y);
    half3 p2 = half3(a1.xy, h.z);
    half3 p3 = half3(a1.zw, h.w);
    // Normalise gradients
    half4 norm = lamina_noise_taylorInvSqrt(half4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;
    // Mix final noise value
    half4 m =
        max(0.6 - half4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
    m = m * m;
    return lamina_normalize(42.0 *
        dot(m * m, half4(dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3))));
}
