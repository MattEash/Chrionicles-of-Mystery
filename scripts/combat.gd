extends Control
signal world_changed(world_name)
@export var world_name = ""
signal textbox_closed
@export var enemy: Resource
@export var heal : Resource

var current_player_health = 0
var current_enemy_health = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_health($EnemyContainer/ProgressBar, enemy.health, enemy.health)
	set_health($PlayerContainer/ProgressBar, PlayerState.current_health, PlayerState.max_health)
	$EnemyContainer/Enemy.texture = enemy.texture
	$Textbox/Label.hide()
	$"Panel/Skills menu".hide()
	$BattleMusic.play()
	display_text("A wild %s apppers!" % enemy.name)
	
	current_enemy_health = enemy.health
	current_player_health = PlayerState.current_health


func set_health(progress_bar,health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node("Label").text = "HP:%d/%d" % [health, max_health]


func _input(event):
	if Input.is_action_just_pressed("text_clear") and $Textbox/Label.visible:
		$Textbox/Label.hide()
		emit_signal("textbox_closed")

func display_text(text):
	$Textbox/Label.text = text
	$Textbox/Label.show()
	
func _on_run_pressed():
	display_text("Player got away safely!")
	await(textbox_closed)
	global.transition_scene = true
	global.scene_entered = global.last_scene_used
	emit_signal("world_changed", world_name)
	global.transition_scene = false
	global.just_in_combat = false

	


func enemy_turn():
	display_text("%s attacks you with full force" % enemy.name)
	await(textbox_closed)
	$DamageSound.play()
	current_player_health = max(0 , current_player_health - enemy.damage)
	set_health($PlayerContainer/ProgressBar, current_player_health, PlayerState.max_health)
	$AnimationPlayer.play("player_damaged")
	await($AnimationPlayer)
	display_text("%s dealt %d damage!" % [enemy.name, enemy.damage])
	await(textbox_closed)
	
	
func player_turn():
	$AnimationPlayer.play("player_attack")
	await($AnimationPlayer)
	display_text("You swing your sword at %s" % enemy.name)
	await(textbox_closed)
	$DamageSound.play()
	current_enemy_health = max(0 , current_enemy_health - PlayerState.base_damage)
	set_health($EnemyContainer/ProgressBar, current_enemy_health, enemy.health)
	$AnimationPlayer.play("ememy_damaged")
	await($AnimationPlayer)
	display_text("You dealt %d damage!" % PlayerState.base_damage)
	await(textbox_closed)


func _on_attack_pressed():
	if PlayerState.base_speed >= enemy.speed:
		await  player_turn()
		enemy_turn()
	else:
		await enemy_turn()
		player_turn()
	if current_player_health == 0:
		$AnimationPlayer.play("player_death")
		await($AnimationPlayer)
		display_text("%s has been defeated" % PlayerState.player_name)
		await(textbox_closed)
		display_text("%s, better luck in your next life!" % PlayerState.name)
		await(textbox_closed)
		await get_tree().create_timer(0.25).timeout
		get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
	if current_enemy_health == 0:
		$AnimationPlayer.play("enemy_death")
		await($AnimationPlayer)
		display_text("%s has been defeated" % enemy.name)
		await(textbox_closed)
		await get_tree().create_timer(0.25).timeout
		PlayerState.current_health = current_player_health
		global.transition_scene = true
		global.scene_entered = global.last_scene_used
		emit_signal("world_changed", world_name)
		global.transition_scene = false
		global.just_in_combat = false
	#enemy_turn()
	print("testing")
func _on_skills_toggled(button_pressed):
	if button_pressed == true:
		$"Panel/Skills menu".show()
	else:
		$"Panel/Skills menu".hide()


