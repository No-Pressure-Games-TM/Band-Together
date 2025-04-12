extends Panel

func _process(delta):
	if visible:
		if Input.is_action_pressed("ui_down"):
			$CreditsText.get_v_scroll_bar().value += 1.3
		elif Input.is_action_pressed("ui_up"):
			$CreditsText.get_v_scroll_bar().value -= 1.3
	else:
		$CreditsText.get_v_scroll_bar().value = 0
