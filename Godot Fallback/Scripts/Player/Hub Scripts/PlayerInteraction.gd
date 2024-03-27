extends Node

class_name PlayerInteraction

@export var hub : PlayerHub

var interactable_ref : Interactable = null

func _physics_process(_delta):
	if (Input.is_action_just_pressed("Interact") and interactable_ref != null):
		interactable_ref.interact(hub)

func set_interactable_ref(interactable : Interactable):
	interactable_ref = interactable

func unset_interactable_ref(interactable : Interactable):
	if (interactable_ref != null and interactable_ref == interactable):
		interactable_ref = null
