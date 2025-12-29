class_name CharacterNameSet extends Resource

@export var male_names: Array[String]
@export var female_names: Array[String]
@export var last_names: Array[String]


func get_random_male_name() -> String:
	assert(not male_names.is_empty())
	
	var i = randi_range(0, male_names.size()-1)
	assert(i >= 0 and i < male_names.size())
	
	var new_first_name = male_names[i]
	
	i = randi_range(0, last_names.size()-1)
	assert(i >= 0 and i < last_names.size())
	
	var new_last_name = last_names[i]
	
	return new_first_name + " " + new_last_name


func get_random_female_name() -> String:
	assert(not female_names.is_empty())
	
	var i = randi_range(0, female_names.size()-1)
	assert(i >= 0 and i < female_names.size())
	
	var new_first_name = female_names[i]
	
	i = randi_range(0, last_names.size()-1)
	assert(i >= 0 and i < last_names.size())
	
	var new_last_name = last_names[i]
	
	return new_first_name + " " + new_last_name
