extends SceneTree

func _init():
    print("Importing project...")
    var err = ProjectSettings.load_resource_pack("res://")
    if err != OK:
        print("Failed to import project")
        get_tree().quit(1)
    else:
        print("Project imported successfully")
        get_tree().quit(0)