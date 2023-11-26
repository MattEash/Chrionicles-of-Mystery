extends Resource

class_name InventoryData

signal inv_updated(inv_data: InventoryData)
signal inv_interact(inv_data: InventoryData, index:int, button: int)

@export var slot_datas: Array[SlotData]

func on_slot_clicked(index:int, button:int) -> void:
	inv_interact.emit(self, index, button)

func held_slot_data(index:int) -> SlotData:
	var slot_data = slot_datas[index]
	if slot_data:
		slot_datas[index] = null
		inv_updated.emit(self)
		return slot_data
	else :
		return null
	
func drop_slot_data(held_slot_data: SlotData,index:int) -> SlotData:
	var slot_data = slot_datas[index]
	
	var return_slot_data: SlotData
	if slot_data and slot_data.can_merge_with(held_slot_data):
		slot_data.merge_with(held_slot_data)
	else:
		slot_datas[index] = held_slot_data
		return_slot_data = slot_data
	
	inv_updated.emit(self)
	return return_slot_data
	
	
