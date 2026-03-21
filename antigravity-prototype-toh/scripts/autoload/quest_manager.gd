extends Node

signal quest_updated(title: String, description: String, progress: float, goal: float)
signal quest_completed(title: String)

enum QuestType { COLLECT_WOOD, KILL_ENEMIES, UNLOCK_AREA, UPGRADE_BUILDING }

# Quests are managed as Dictionaries in the quests array.

var current_quest_index: int = 0
var quests: Array = []

func _ready() -> void:
	_setup_quests()
	# 初期クエストの通知を少し遅らせる（HUDのReadyを待つ）
	get_tree().create_timer(1.0).timeout.connect(_broadcast_current_quest)

func _setup_quests() -> void:
	quests = [
		{
			"title": "Gathering Basics",
			"description": "Collect 20 Wood",
			"type": QuestType.COLLECT_WOOD,
			"target": 20,
			"current": 0,
			"reward_stone": 10
		},
		{
			"title": "Base Expansion",
			"description": "Unlock the South Field",
			"type": QuestType.UNLOCK_AREA,
			"target": 1,
			"current": 0,
			"reward_wood": 50
		},
		{
			"title": "Extermination",
			"description": "Kill 5 Enemies",
			"type": QuestType.KILL_ENEMIES,
			"target": 5,
			"current": 0,
			"reward_iron": 5
		}
	]

func _broadcast_current_quest() -> void:
	if current_quest_index < quests.size():
		var q = quests[current_quest_index]
		quest_updated.emit(q.title, q.description, q.current, q.target)

func notify_progress(type: QuestType, amount: int = 1) -> void:
	if current_quest_index >= quests.size(): return
	
	var q = quests[current_quest_index]
	if q.type == type:
		q.current += amount
		_broadcast_current_quest()
		
		if q.current >= q.target:
			_complete_quest()

func _complete_quest() -> void:
	var q = quests[current_quest_index]
	quest_completed.emit(q.title)
	
	# 報酬の付与
	if GameStateManager:
		if q.has("reward_wood"): GameStateManager.add_resource("wood", q.reward_wood)
		if q.has("reward_stone"): GameStateManager.add_resource("stone", q.reward_stone)
		if q.has("reward_iron"): GameStateManager.add_resource("iron", q.reward_iron)
	
	current_quest_index += 1
	_broadcast_current_quest()
