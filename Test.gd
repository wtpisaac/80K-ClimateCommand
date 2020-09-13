extends Node2D

var spawn_speed: float = 5.0
const PLAYER_SPEED: int = 500
var testSeconds: float = 0.0
var testSpeed: int = 50

const INPUTTIMEOUT = 0.25
var timeoutForInput: float = 0
var processInputs: bool = false
var over: bool = false
var gameOverTimer: float = 0.0

var level: int = 1
var pollution: int = 1
var levelActive: bool = false
var levelAnnounced: bool = false
var levelEndAnnounced: bool = false
var levelSeconds: float = 0.0
const LEVELTIMER = 5.0
const LEVELPROJ = 15
const INITIALSPAWNRATE = 4.0

var levelEnded: bool = false

var planeCount:int = 0
var totalPlanesSent:int = 0
var currentlyPlayingPlane: bool = false

const INITIALHOSTILES = 10
var levelHostiles = 10
var hostilesToSpawn = 15
var hostilesToDespawn = 15

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var vs = get_viewport_rect().size
#	$Trail.anchor(Vector2(vs.x / 2, vs.y / 2))
#	$Trail.freePos = get_viewport().get_mouse_position()
#	$Trail.display()
	
	# Add relevant nodes to groups
	$Sky.add_to_group("land")
	$Farm1.add_to_group("land")
	$Farm2.add_to_group("land")
	$Farm3.add_to_group("land")
	$Farm4.add_to_group("land")
	$Farm5.add_to_group("land")
	$Farm6.add_to_group("land")

func spawn_missile(position: Vector2, destination: Vector2, friendly: bool, speed: int):
	var projectileScn = preload("res://Objects/Projectile.tscn")
	var projectile = projectileScn.instance()
	projectile.position = position
	projectile.finalPosition = Vector2(destination.x, destination.y)
	projectile.speed = speed
	if friendly:
		projectile.color = Color.darkgray
		projectile.get_node("AuxSprite").texture = preload("res://Res/Final/airplanes.png")
		planeCount += 1
	else:
		projectile.color = Color.yellow
		projectile.add_to_group("hostile")
		var rand = rand_range(0, 5)
		if(rand < 1):
			play_sound("res://Res/Final/SFX/Sunlight1.wav")
		elif (rand < 2):
			play_sound("res://Res/Final/SFX/Sunlight2.wav")
		elif (rand < 3):
			play_sound("res://Res/Final/SFX/Sunlight3.wav")
		else:
			play_sound("res://Res/Final/SFX/Sunlight4.wav")
		projectile.connect("projectileDestroyed", self, "hostile_despawned")
	add_child(projectile)
	
func spawn_storm(startPos: Vector2):
	var stormScn = preload("res://Objects/DustStorm.tscn")
	var storm = stormScn.instance()
	storm.position = startPos
	storm.velocity = Vector2(rand_range(50, 200), rand_range(50, 200))
	storm.connect("stormDestroyed", self, "hostile_despawned")
	add_child(storm)

func spawn_hostile():
	if(hostilesToSpawn == 0):
		return
	hostilesToSpawn -= 1
	# get viewport size
	var vs = get_viewport_rect().size
	
	# Spawn random position and choose random position
	var start = Vector2(rand_range(0, vs.x), 0)
	var end = Vector2(rand_range(0, vs.x), vs.y)
	
	var rand = rand_range(1,7)
	
	if(rand < 6-floor(pollution/7)):
		# Spawn hostile missile
		spawn_missile(start, end, false, testSpeed)
	else:
		spawn_storm(start)

func plane_sound():
	play_sound("res://Res/Final/SFX/airplane.wav")

func play_sound(path):
	var audScn = preload("res://Objects/InstantaneousAudioStreamPlayer.tscn")
	var aud = audScn.instance()
	aud.path = path
	add_child(aud)
	return aud

func hostile_despawned():
	if(hostilesToDespawn > 0):
		hostilesToDespawn -= 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!over):
		if(levelActive):
			if(!processInputs):
				timeoutForInput += delta
				if(timeoutForInput > INPUTTIMEOUT):
					processInputs = true
			else:
				if(Input.is_action_just_released("fire_left_airport") and $AirportL.healthy and $AirportL.airplanes > 0 and $AirportL.cooldown <= 0.0):
					var mousePos = get_viewport().get_mouse_position()
					spawn_missile($AirportL.position, mousePos, true, PLAYER_SPEED)
					$AirportL.planeFired()
					plane_sound()
					totalPlanesSent += 1
				if(Input.is_action_just_released("fire_center_airport") and $AirportC.healthy and $AirportC.airplanes > 0 and $AirportC.cooldown <= 0.0):
					var mousePos = get_viewport().get_mouse_position()
					spawn_missile($AirportC.position, mousePos, true, PLAYER_SPEED)
					$AirportC.planeFired()
					plane_sound()
					totalPlanesSent += 1
				if(Input.is_action_just_released("fire_right_airport") and $AirportR.healthy and $AirportR.airplanes > 0 and $AirportR.cooldown <= 0.0):
					var mousePos = get_viewport().get_mouse_position()
					spawn_missile($AirportR.position, mousePos, true, PLAYER_SPEED)
					$AirportR.planeFired()
					plane_sound()
					totalPlanesSent += 1
			# Spawn missiles in test pattern
			testSeconds += delta
			if(testSeconds > spawn_speed and hostilesToSpawn > 0):
				testSeconds = 0
				for i in range(randi()%1+int(pollution/4)+1):
					spawn_hostile()
			if(!$Farm1.healthy and !$Farm2.healthy and !$Farm3.healthy and !$Farm4.healthy and !$Farm5.healthy and !$Farm6.healthy):
				$Sky.texture = preload("res://Res/Final/gameoversky.png")
				over = true
			if(hostilesToDespawn == 0):
				levelEnded = true
				levelActive = false
		else:
			# Level not active so must be changing levels
			if(!levelAnnounced):
				if(levelEnded):
					# End the level
					if(levelEndAnnounced):
						levelSeconds += delta
						if(levelSeconds > LEVELTIMER):
							# reset level and start next one
							$AirportL.resetAirport()
							$AirportC.resetAirport()
							$AirportR.resetAirport()
							spawn_speed = clamp(5.0-pollution*0.1, 1.0, 5.0)
							hostilesToSpawn = 15
							hostilesToDespawn = 15
							totalPlanesSent = 0
							planeCount = 0
							levelEndAnnounced = false
							levelEnded = false
							level += 1
							levelSeconds = 0.0
					else:
						$LAnnounce.get_node("YearLabel").bbcode_text = "[center]End of Year " + str(level) + "[/center]"
						# Calculate total counts
						if(totalPlanesSent > 25):
							pollution += 3
							testSpeed += 15
							$LAnnounce.get_node("PollutionLabel").bbcode_text = "[center]Pollution Levels High[/center]"
						elif(totalPlanesSent > 18):
							pollution += 2
							testSpeed += 10
							$LAnnounce.get_node("PollutionLabel").bbcode_text = "[center]Pollution Levels Normal[/center]"
						else:
							pollution += 1
							testSpeed += 5
							$LAnnounce.get_node("PollutionLabel").bbcode_text = "[center]Pollution Levels Low[/center]"
						$LAnnounce.get_node("LuckLabel").bbcode_text = "[center]Valiant Effort[/center]"
						$LAnnounce.visible = true
						levelEndAnnounced = true
						levelSeconds = 0.0
				else:
					$LAnnounce.get_node("YearLabel").bbcode_text = "[center]Year " + str(level) + "[/center]"
					if(pollution < 5):
						$LAnnounce.get_node("PollutionLabel").bbcode_text = "[center]Atmospheric Pollution Low[/center]"
						$Sky.texture = preload("res://Res/Final/clear sky.png")
					elif(pollution < 10):
						$LAnnounce.get_node("PollutionLabel").bbcode_text = "[center]Atmospheric Pollution Medium[/center]"
						$Sky.texture = preload("res://Res/Final/slight fog sky.png")
					else:
						$LAnnounce.get_node("PollutionLabel").bbcode_text = "[center]Pollution Level High[/center]"
						$Sky.texture = preload("res://Res/Final/Heavy fog sky.png")
					$LAnnounce.get_node("LuckLabel").bbcode_text = "[center]Good Luck[/center]"
					$LAnnounce.visible = true
	#				$Audi.stream = preload("res://Res/Final/SFX/start.ogg")
	#				$Audi.play()
					play_sound("res://Res/Final/SFX/start.wav")
					levelAnnounced = true
			else:
				levelSeconds += delta
				if(levelSeconds > LEVELTIMER):
					$LAnnounce.visible = false
					levelActive = true
					levelSeconds = 0.0
					levelAnnounced = false
	else:
		if(gameOverTimer == 0):
			play_sound("res://Res/Final/SFX/gameover.wav")
		gameOverTimer += delta
		if(gameOverTimer > 17):
			Global.score = level
			get_tree().change_scene("res://DraftGameOver.tscn")
