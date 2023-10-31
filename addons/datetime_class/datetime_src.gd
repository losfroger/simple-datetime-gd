@icon("res://addons/datetime_class/datetime_icon.png")
class_name DateTime
## DateTime class, that can parse ISO 8601 strings with timezones.
##
## Has Add, difference functions. That can convert to UTC and the system timezone.

## - Year is considered as 365 days [br]
## - Month is considered as 31 days [br]
## - Day is considered as 24 hours [br]
## - Hour is considered as 60 minutes [br]
## - Minutes is considered as 60 seconds [br]
enum TIME_UNIT {
	YEAR,
	MONTH,
	DAY,
	HOUR,
	MINUTE,
	SECOND,
}


var _is_utc: bool = true


# Time.datetime dict { year, month, day, hour, minute, second }
var _date_time_dict: Dictionary

# Unix time stamp in seconds
var _unix_time_stamp: float = 0.0 : set = _set_unix_time

## Set timezone, valid values must follow ISO nomenclature e.g.: [br]
##  [code]Z[/code], [code]+01:00[/code], [code]+0100[/code], [code]+01[/code]
var timezone_str: String = "Z"  : set = set_timezone
var _has_timezone: bool = false

# If timezone is positive (e.g. +01:00) = 1
# If timezone is negative (e.g. -01:00) = -1
var _timezone_sign: int = 1

# Timezone in seconds, useful for converting back into utc
var _timezone_seconds: float = 0.0
# Regex function to get the timezone part from the iso string
var _timezone_regex = RegEx.new().create_from_string("(\\+|\\-){1}([0-9:]+)$")

## Initialize the date using a string
func start_string(date_string: String) -> void:
	self.timezone_str = date_string
	self._unix_time_stamp = Time.get_unix_time_from_datetime_string(date_string.to_upper())


## Initializes date with date from the system as UTC
func start_now() -> void:
	self.timezone_str = "Z"
	self._unix_time_stamp = Time.get_unix_time_from_system()


## Returns the difference with another date in seconds
## It never returns negative numbers|
func difference(date_b: DateTime) -> float:

	var aux_date_a = self.convert_to_utc()
	var aux_date_b = date_b.convert_to_utc()

	return absf(aux_date_a._unix_time_stamp - aux_date_b._unix_time_stamp)


## Returns the difference with another date as a datetime dict
func difference_as_dict(date_b: DateTime) -> Dictionary:
	var dif = self.difference(date_b)
	var dict = Time.get_datetime_dict_from_unix_time(dif)

	var new_dict = {
		"years": dict.year - 1970,
		"months": dict.month - 1,
		"days": dict.day - 1,
		"hours": dict.hour,
		"minutes": dict.minute,
		"seconds": dict.second,
	}

	return new_dict


## Duplicates the date object
func duplicate() -> DateTime:
	var copy: DateTime = get_script().new()
	copy._is_utc = _is_utc
	copy.timezone_str = timezone_str
	copy._has_timezone = _has_timezone
	copy._timezone_sign = _timezone_sign
	copy._timezone_seconds = _timezone_seconds
	copy._date_time_dict = _date_time_dict.duplicate(true)
	copy._unix_time_stamp = _unix_time_stamp
	return copy


## Converts the object to utc timezone
func convert_to_utc() -> DateTime:
	if _is_utc:
		return self.duplicate()
	else:
		var aux_date: DateTime = self.duplicate()
		aux_date.add(aux_date._timezone_seconds * aux_date._timezone_sign, DateTime.TIME_UNIT.SECOND)
		aux_date.set_timezone("Z")
		return aux_date


## Convert to system timezone
func convert_to_sys_tz() -> DateTime:
	var tz = Time.get_time_zone_from_system()
	var aux_date = self.duplicate()

	if !_is_utc:
		aux_date = aux_date.convert_to_utc()

	aux_date.add(tz.bias, TIME_UNIT.MINUTE)
	aux_date._set_timezone_from_dict(tz)

	return aux_date


## Add the number of units ([enum DateTime.TIME_UNIT]) to the date
func add(number: float, unit: DateTime.TIME_UNIT) -> void:
	var seconds_to_add = 0.0
	match(unit):
		DateTime.TIME_UNIT.YEAR:
			# 365 Days * 24 hours * 60 minutes * 60 seconds = 31_536_000
			seconds_to_add = number * 31_536_000.0
		DateTime.TIME_UNIT.MONTH:
			# 31 Days * 24 hours * 60 minutes * 60 seconds = 2_678_400
			seconds_to_add = number * 2_678_400.0
		DateTime.TIME_UNIT.DAY:
			# 24 hours * 60 minutes * 60 seconds = 86_400
			seconds_to_add = number * 86_400.0
		DateTime.TIME_UNIT.HOUR:
			# 60 minutes * 60 seconds = 3_600
			seconds_to_add = number * 3_600.0
		DateTime.TIME_UNIT.MINUTE:
			# 1 minute * 60 seconds = 60
			seconds_to_add = number * 60.0
		DateTime.TIME_UNIT.SECOND:
			seconds_to_add = number
		_:
			seconds_to_add = number

	self._unix_time_stamp += seconds_to_add


## Converts the date to a string, following the ISO format
func _to_string() -> String:
	return "%02d-%02d-%02dT%02d:%02d:%02d%s" % [
		_date_time_dict.year,
		_date_time_dict.month,
		_date_time_dict.day,
		_date_time_dict.hour,
		_date_time_dict.minute,
		_date_time_dict.second,
		timezone_str
	]


## Pass tz dictionary from Time.get_time_zone_from_system()
func _set_timezone_from_dict(tz_dict: Dictionary) -> void:
	tz_dict.bias *= -1

	var hours = int(tz_dict.bias) / 60 # Remove any decimal point
	var minutes = tz_dict.bias % 60
	var tz_sign = "+" if sign(tz_dict.bias) == 1 else "-"

	self.timezone_str = "%s%02d:%02d" % [
		tz_sign,
		hours,
		minutes
	]


# Calculate timezone things
func set_timezone(new_tz: String) -> void:
	_is_utc = new_tz.to_upper().find("Z") > -1

	if _is_utc:
		_has_timezone = false
		timezone_str = "Z"
		_timezone_seconds = 0.0
		_timezone_sign = 1
		return

	var timezone_rgx_result: RegExMatch = _timezone_regex.search(new_tz)
	if timezone_rgx_result:
		_has_timezone = true
		timezone_str = timezone_rgx_result.get_string()

		_timezone_sign = 1 if timezone_str.find("+") > -1 else -1

		# Calculate timezone minutes
		var timezone_hours = 0.0
		var timezone_minutes = 0.0
		match timezone_str.length():
			# Big timezone string (e.g. +01:00)
			6:
				timezone_hours = float(timezone_str.substr(1, 2))
				timezone_minutes = float(timezone_str.substr(4, -1))
				prints("Length 6:", timezone_str.substr(1, 2), timezone_str.substr(4, -1))

			# Medium timezone string (e.g. +0100)
			5:
				timezone_hours = float(timezone_str.substr(1, 2))
				timezone_minutes = float(timezone_str.substr(3, -1))
				prints("Length 5:", timezone_str.substr(1, 2), timezone_str.substr(3, -1))

			# Small timezone string (e.g. +01)
			3:
				timezone_hours = float(timezone_str.substr(1))
				prints("Length 3:", timezone_str.substr(1))

			_:
				assert("Timezone format not valid")

		_timezone_seconds = ((timezone_hours * 60.0) + timezone_minutes) * 60.0 * _timezone_sign
		timezone_str = "%s%02d:%02d" % ["-" if _timezone_sign < 0 else "+", timezone_hours, timezone_minutes]

	else:
		assert("No valid timezone detected")


func _set_unix_time(new_val: float) -> void:
	_unix_time_stamp = new_val
	_date_time_dict = Time.get_datetime_dict_from_unix_time(new_val)
