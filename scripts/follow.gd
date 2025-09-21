extends State

func enter():
	super.enter()
	owner.set_physics_process(true)
	animationPlayer.play("idle")

func exit():
	super.exit()
	owner.set_physics_process(false)

func transition():
	var distance = owner.direction.length()
	if distance<=60:
		get_parent().change_state("meleeAttack")
	elif distance>130:
		var chance = randi()%2
		get_parent().change_state("homingMissile")
		#match chance:
			#0:
				#get_parent().change_state("homingMissile")
			#1: 
				#get_parent().change_state("laser")
