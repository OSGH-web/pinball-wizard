extends TileMapLayer


func open_gate():
	self.visible = false
	self.collision_enabled = false
	
	
func close_gate():
	self.visible = true
	self.collision_enabled = true
