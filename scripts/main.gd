extends Node3D

var xr_interface : XRInterface

func _ready() -> void:
    var force_no_vr = "--no-vr" in OS.get_cmdline_args()
    
    xr_interface = XRServer.find_interface("OpenXR")

    if not force_no_vr and xr_interface and xr_interface.is_initialized():
        setup_vr()
    else:
        setup_keyboard()

func setup_vr():
    print("Launching in VR mode")
    DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
    get_viewport().use_xr = true
    $KeyboardPlayer.queue_free()
    $KeyboardUI.queue_free()

func setup_keyboard():
    print("Launching in Keyboard mode")
    $Player.queue_free()
    $VRUI.queue_free()