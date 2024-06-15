#version 460 core

struct QuadData {
  uint quadData1;
  uint quadData2;
};

layout(binding = 0, std430) readonly buffer ssbo1 {
  QuadData data[];  
};

uniform mat4 u_view;
uniform mat4 u_projection;

out VS_OUT {
  out vec3 pos;
  flat vec3 normal;
  flat vec3 color;
} vs_out;

const vec3 normalLookup[6] = {
  vec3( 0, 1, 0 ),
  vec3(0, -1, 0 ),
  vec3( 1, 0, 0 ),
  vec3( -1, 0, 0 ),
  vec3( 0, 0, 1 ),
  vec3( 0, 0, -1 )
};

const vec3 colorLookup[8] = {
  vec3(0.2, 0.659, 0.839),
  vec3(0.302, 0.302, 0.302),
  vec3(0.278, 0.600, 0.141),
  vec3(0.1, 0.1, 0.6),
  vec3(0.1, 0.6, 0.6),
  vec3(0.6, 0.1, 0.6),
  vec3(0.6, 0.6, 0.1),
  vec3(0.6, 0.1, 0.1)
};

const int flipLookup[6] = int[6](1, -1, -1, 1, -1, 1);

void main() {
  vec3 chunkOffsetPos = vec3(gl_BaseInstance&255u, gl_BaseInstance>>8&255u, gl_BaseInstance>>16&255u) * 62;
  uint face = gl_BaseInstance>>24;

  int quadIndex = int(gl_VertexID&3u);
  uint ssboIndex = gl_VertexID >> 2u;

  uint quadData1 = data[ssboIndex].quadData1;
  uint quadData2 = data[ssboIndex].quadData2;

  float x = float(quadData1&63u);
  float y = float((quadData1 >> 6u)&63u);
  float z = float((quadData1 >> 12u)&63u);

  float w = float((quadData1 >> 18u)&63u);
  float h = float((quadData1 >> 24u)&63u);

  uint wDir = (face & 2) >> 1, hDir = 2 - (face >> 2);
  int wMod = quadIndex >> 1, hMod = quadIndex & 1;

  vs_out.pos = chunkOffsetPos + vec3(x, y, z);
  vs_out.pos[wDir] += w * wMod * flipLookup[face];
  vs_out.pos[hDir] += h * hMod;

  vs_out.normal = normalLookup[face];
  vs_out.color = colorLookup[(quadData2&255u) - 1];
  
  gl_Position = u_projection * u_view * vec4(vs_out.pos, 1);
}