extends SceneTree

func _init():
    print("Importing project...")
    var err = ProjectSettings.load_resource_pack("res://")
    if err != OK:
        print("Failed to import project")
        OS.exit(1)
    print("Project imported successfully")
    OS.exit(0)