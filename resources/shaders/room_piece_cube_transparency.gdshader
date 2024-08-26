shader_type spatial;

uniform vec3 camera_position; // The position of the camera
uniform vec3 player_position; // The position of the player
uniform float fade_distance;  // The distance at which the object should start to fade
uniform float max_distance;   // The distance at which the object should be fully transparent

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Calculate the distance from the camera to the object (current fragment)
	float object_to_camera_distance = length(camera_position - MODEL_MATRIX[3].xyz);
	vec3 node_world_pos = NODE_POSITION_WORLD;
	 

	// Calculate the distance from the camera to the player
	float camera_to_player_distance = length(camera_position - player_position);

	// Determine if the object is between the camera and the player
	if (object_to_camera_distance < camera_to_player_distance) {
		// Calculate the alpha value based on the distance
		float alpha = 1.0;

		// Fade out the object based on the distance between the camera and the object
		if (object_to_camera_distance < fade_distance) {
			alpha = 1.0;
		} else if (object_to_camera_distance < max_distance) {
			alpha = mix(1.0, 0.0, (object_to_camera_distance - fade_distance) / (max_distance - fade_distance));
		} else {
			alpha = 0.0;
		}

		ALBEDO = vec3(1.0); // Set the object color (white in this example)
		ALPHA = alpha;      // Set the alpha based on the calculated value
	} else {
		ALBEDO = vec3(1.0); // Set the object color (white in this example)
		ALPHA = 1.0;        // Fully opaque if not between the camera and the player
	}
}

