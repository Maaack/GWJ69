@tool
class_name InfoPanel
extends HUDPanel

const INFO_STRING : String = "Mass: 150 Million Suns
Radius: %s
%s: %s
Elapsed Time: 
Local   - %s
Station - %s"

const DISTANCE_STRING = "Distance"
const DEPTH_STRING = "Depth"

const YEAR_SECONDS : float = 31556952
const MONTH_SECONDS : float = 2629746
const DAY_SECONDS : float = 86400
const HOUR_SECONDS : float = 3600
const MINUTE_SECONDS : float = 60
const TERA_KM_AMOUNT : float = 1000000000
const GIGA_KM_AMOUNT : float = 1000000
const MEGA_KM_AMOUNT : float = 1000


@export var radius_km : float :
	set(value):
		radius_km = value
		radius_string = _get_km_string(radius_km)

@export var distance_km : float :
	set(value):
		distance_km = value
		distance_string = _get_km_string(distance_km - radius_km)

@export var elapsed_local_time : float :
	set(value):
		elapsed_local_time = value
		elapsed_local_time_string = _get_time_string(elapsed_local_time)

@export var elapsed_station_time : float :
	set(value):
		elapsed_station_time = value
		elapsed_station_time_string = _get_time_string(elapsed_station_time)

func _get_km_string(km : float) -> String:
	var unit : String
	var unit_amount : float
	var sign_string : String = ""
	if km < 0:
		sign_string = "-"
	km = abs(km)
	if km >= TERA_KM_AMOUNT:
		unit = "Tera"
		unit_amount = km / TERA_KM_AMOUNT
	elif km >= GIGA_KM_AMOUNT:
		unit = "Giga"
		unit_amount = km / GIGA_KM_AMOUNT
	elif km > MEGA_KM_AMOUNT:
		unit = "Mega"
		unit_amount = km / MEGA_KM_AMOUNT
	else:
		unit = "Kilo"
		unit_amount = km
	if unit_amount >= 100.0:
		return "%s%.f %smeters" % [sign_string, unit_amount, unit]
	else:
		return "%s%.1f %smeters" % [sign_string, unit_amount, unit]


func _get_time_string(elapsed_time : float) -> String:
	if elapsed_time >= YEAR_SECONDS:
		if elapsed_time >= 100.0:
			return "%.f Years" % (elapsed_time / MONTH_SECONDS)
		else:
			return "%.1f Years" % (elapsed_time / MONTH_SECONDS)
	elif elapsed_time >= MONTH_SECONDS:
		return "%.1f Months" % (elapsed_time / MONTH_SECONDS)
	elif elapsed_time >= DAY_SECONDS:
		return "%.1f Days" % (elapsed_time / DAY_SECONDS)
	else:
		var seconds : float = max(elapsed_time, 0)
		var hours = floor(seconds / HOUR_SECONDS)
		seconds -= hours * HOUR_SECONDS
		var minutes = floor(seconds / MINUTE_SECONDS)
		seconds -= minutes * MINUTE_SECONDS
		return "%02d:%02d:%02d" % [hours, minutes, seconds]

var elapsed_local_time_string : String :
	set(value):
		elapsed_local_time_string = value
		_update_black_hole_info()

var elapsed_station_time_string : String :
	set(value):
		elapsed_station_time_string = value
		_update_black_hole_info()

var radius_string : String :
	set(value):
		radius_string = value
		_update_black_hole_info()

var distance_string : String :
	set(value):
		distance_string = value
		_update_black_hole_info()

func _update_black_hole_info() -> void:
		if is_inside_tree():
			var dist_or_depth : String
			if distance_km - radius_km < 0:
				dist_or_depth = DEPTH_STRING
			else:
				dist_or_depth = DISTANCE_STRING
			%BlackHoleInfo.text = INFO_STRING % [radius_string, dist_or_depth, distance_string, elapsed_local_time_string, elapsed_station_time_string]
