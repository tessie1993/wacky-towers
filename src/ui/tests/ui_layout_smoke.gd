extends SceneTree
const UI = preload("res://src/ui/game_ui.gd")
func _initialize(): call_deferred("_run")
func _run():
    var ui=UI.new()
    root.add_child(ui)
    await process_frame
    for viewport_size in [Vector2i(1280,720),Vector2i(720,1280)]:
      root.size=viewport_size
      await process_frame
      for prefs in [{"text_scale":1.0,"button_scale":1.0},{"text_scale":1.5,"button_scale":1.0},{"text_scale":1.0,"button_scale":1.5},{"text_scale":1.5,"button_scale":2.0}]:
        ui.apply_prefs(prefs)
        ui.show_hud({"can_tilt":true,"can_roll":true,"skill_ready":true,"selected_potion":"slow_time","potion_count":5,"level_name":"The Meadow","goal":"Layers","progress":0,"target":4,"capabilities":{"undo":true,"reset":true,"choose_down":true}})
        for i in 4: await process_frame
        var logical=root.get_visible_rect().size
        var area=ui.board_area()
        var board=Rect2(area.position*logical,area.size*logical)
        var window=Rect2(Vector2.ZERO,logical)
        for b in ui._hud.find_children("*","Button",true,false):
          var bounds=b.get_global_rect()
          if not window.encloses(bounds):
            push_error("Control outside window: "+b.text+" "+str(bounds)+" "+str(window))
            quit(1)
            return
          if board.intersects(bounds):
            push_error("Control overlaps board: "+b.text+" "+str(bounds)+" "+str(board))
            quit(1)
            return
        print("UI_LAYOUT_PASS ",viewport_size," ",prefs," board=",board)
    ui.queue_free()
    await process_frame
    quit(0)
