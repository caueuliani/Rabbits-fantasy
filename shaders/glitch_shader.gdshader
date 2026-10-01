shader_type canvas_item;

uniform float intensity: float = 1.0;
uniform float time: float = 0.0;

void fragment() {
	// Obter cor original
	vec4 color = texture(TEXTURE, UV);
	
	// Converter para escala de cinza (preto e branco)
	float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
	
	// Aplicar efeito de glitch
	float glitch = sin(time * 10.0 + UV.y * 20.0) * 0.05;
	
	// Misturar cor original com escala de cinza baseado na intensidade
	vec3 final_color = mix(color.rgb, vec3(gray), intensity);
	
	// Adicionar glitch sutil
	final_color += glitch * intensity;
	
	COLOR = vec4(final_color, color.a);
}