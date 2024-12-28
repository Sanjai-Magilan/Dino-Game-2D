extends CharacterBody2D

const GRAVITY :int = 4200
const JUMP_SPEED : int = -900


func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("idle")
		else:
			$runcoll.disabled = false
			if Input.is_action_pressed("ui_up"):
				velocity.y = JUMP_SPEED
				$jumpSound.play()
			elif Input.is_action_pressed("ui_down"):
				$AnimatedSprite2D.play("duck")
				$runcoll.disabled = true
			else:
				$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("jump")
		
	move_and_slide()     
