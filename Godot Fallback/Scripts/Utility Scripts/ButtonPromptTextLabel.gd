extends RichTextLabel

class_name ButtonPromptTextLabel

var raw_text : String

func _init():
	raw_text = self.text

func _ready():
	TextPromptParser.control_mode_changed.connect(refresh_label_text)
	GlobalSignals.bindings_changed.connect(refresh_label_text)
	refresh_label_text()

func set_raw_text(s : String):
	raw_text = s
	refresh_label_text()

func refresh_label_text():
	self.text = TextPromptParser.parse_text(raw_text)
