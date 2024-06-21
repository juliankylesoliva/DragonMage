extends Node

const mage_form : PlayerForm.CharacterMode = PlayerForm.CharacterMode.MAGE

const dragon_form : PlayerForm.CharacterMode = PlayerForm.CharacterMode.DRAGON

var selected_form : PlayerForm.CharacterMode = mage_form

var form_changing_enabled : bool = false

func set_selected_form(form : PlayerForm.CharacterMode):
	selected_form = form

func toggle_selected_form():
	selected_form = (mage_form if selected_form == dragon_form else dragon_form)

func is_mage_selected():
	return selected_form == mage_form

func is_dragon_selected():
	return selected_form == dragon_form
