extends SceneTree

func _init():
    print("Importing project...")
    ProjectSettings.load_resource_pack("res://")
    print("Project imported successfully")
    quit(0)