extends Node
#save location
const SAVE_PATH = "user://savegame.cfg"

@export var mob_scene: PackedScene
var score
var record = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_record()
	$HUD.show_start_screen(record)
	#new_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func game_over() -> void:
	$ScoreTimer.stop()
	$MobTimer.stop()
	
	if score > record:
		record = score
		save_record()
		
	$HUD.show_game_over(record)
	
	$AudioStreamPlayer.stop()
	$DeathSound.play()
	
func new_game():
	$MobTimer.stop()
	$ScoreTimer.stop()
	$StartTimer.stop()
	get_tree().call_group("mobs", "queue_free")
	
	score = 0
	$HUD.show_game_hud(score)
	$HUD.show_message("Get Ready")
	$Player.start($StartPosition.position)
	$StartTimer.start()
	
	$AudioStreamPlayer.play()


func _on_mob_timer_timeout() -> void:
	
	$HUD.update_score(score)
		# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to the random location.
	mob.position = mob_spawn_location.position

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(100.0, 150.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
	


func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)


func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()

#Save functions
func load_record():
	var config = ConfigFile.new()
	var error = config.load(SAVE_PATH)

	if error == OK:
		record = config.get_value("scores", "record", 0)
		
		
func save_record():
	var config = ConfigFile.new()
	config.set_value("scores", "record", record)
	config.save(SAVE_PATH)
