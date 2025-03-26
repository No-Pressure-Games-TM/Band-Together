extends SceneTree

func _init():
    print("Importing project...")
    var err = ProjectSettings.load_resource_pack("res://")
    if err != OK:
        print("Failed to import project")
        quit(1)
    print("Project imported successfully")
    quit(0)