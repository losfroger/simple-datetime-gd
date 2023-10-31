extends GutTest
func before_each():
	gut.p("ran setup", 2)

func after_each():
	gut.p("ran teardown", 2)

func before_all():
	gut.p("ran run setup", 2)

func after_all():
	gut.p("ran run teardown", 2)

func test_datetime_duplication():
	var date_a: DateTime = DateTime.new()
	date_a.start_now()
	var date_b: DateTime = date_a.duplicate()
	
	assert_eq(date_b._date_time_dict, date_a._date_time_dict, "Date A and B should be equal")


func test_datetime_negative_tz_convert_to_utc():
	var date_a: DateTime = DateTime.new()
	date_a.start_string("2023-01-01T06:00:00.000-06:00")
	var date_utc: DateTime = date_a.convert_to_utc()
	assert_eq_deep(
		date_utc._date_time_dict,
		{ "year": 2023, "month": 1, "day": 1, "hour": 12, "minute": 0, "second": 0, "weekday": 0 }
	)


func test_datetime_positive_tz_convert_to_utc():
	var date_a: DateTime = DateTime.new()
	date_a.start_string("2023-01-01T00:00:00.000+06:00")
	var date_utc: DateTime = date_a.convert_to_utc()
	assert_eq_deep(
		date_utc._date_time_dict,
		{ "year": 2023, "month": 1, "day": 1, "hour": 6, "minute": 0, "second": 0, "weekday": 0 }
	)


func test_datetine_to_sys_tz():
	var date_a: DateTime = DateTime.new()
	date_a.start_string("2023-01-01T00:00:00.000Z")
	var date_syz_tz: DateTime = date_a.convert_to_sys_tz()
	
	var tz = Time.get_time_zone_from_system()
	var timestamp = 1672531200 + (tz.bias * 60.0)
	
	
	assert_eq_deep(
		date_syz_tz._unix_time_stamp,
		timestamp
	)


func test_datetime_adding_seconds():
	var date_a: DateTime = DateTime.new()
	date_a.start_string("2023-01-01T00:00:00.000Z")
	
	date_a.add(30.0, DateTime.TIME_UNIT.SECOND)
	
	assert_eq_deep(
		date_a._date_time_dict,
		{ "year": 2023, "month": 1, "day": 1, "hour": 0, "minute": 0, "second": 30, "weekday": 0 }
	)


func test_datetime_adding_minutes():
	var date_a: DateTime = DateTime.new()
	date_a.start_string("2023-01-01T00:00:00.000Z")
	
	date_a.add(30.0, DateTime.TIME_UNIT.MINUTE)
	
	assert_eq_deep(
		date_a._date_time_dict,
		{ "year": 2023, "month": 1, "day": 1, "hour": 00, "minute": 30, "second": 0, "weekday": 0 }
	)


func test_datetime_adding_hours():
	var date_a: DateTime = DateTime.new()
	date_a.start_string("2023-01-01T00:00:00.000Z")
	
	date_a.add(12.0, DateTime.TIME_UNIT.HOUR)
	
	assert_eq_deep(
		date_a._date_time_dict,
		{ "year": 2023, "month": 1, "day": 1, "hour": 12, "minute": 0, "second": 0, "weekday": 0 }
	)

func test_datetime_adding_hour_fractions():
	var date_a: DateTime = DateTime.new()
	date_a.start_string("2023-01-01T00:00:00.000Z")
	
	date_a.add(1.5, DateTime.TIME_UNIT.HOUR)
	
	assert_eq_deep(
		date_a._date_time_dict,
		{ "year": 2023, "month": 1, "day": 1, "hour": 1, "minute": 30, "second": 0, "weekday": 0 }
	)

func test_datetime_adding_days():
	var date_a: DateTime = DateTime.new()
	date_a.start_string("2023-01-01T00:00:00.000Z")
	
	date_a.add(15.0, DateTime.TIME_UNIT.DAY)
	
	assert_eq_deep(
		date_a._date_time_dict,
		{ "year": 2023, "month": 1, "day": 16, "hour": 0, "minute": 0, "second": 0, "weekday": 1 }
	)


func test_datetime_adding_months():
	var date_a: DateTime = DateTime.new()
	date_a.start_string("2023-01-01T00:00:00.000Z")
	
	date_a.add(6.0, DateTime.TIME_UNIT.MONTH)
	
	assert_eq_deep(
		date_a._date_time_dict,
		{ "year": 2023, "month": 7, "day": 6, "hour": 0, "minute": 0, "second": 0, "weekday": 4 }
	)


func test_datetime_adding_years():
	var date_a: DateTime = DateTime.new()
	date_a.start_string("2023-01-01T00:00:00.000Z")
	
	date_a.add(1.0, DateTime.TIME_UNIT.YEAR)
	
	assert_eq_deep(
		date_a._date_time_dict,
		{ "year": 2024, "month": 1, "day": 1, "hour": 0, "minute": 0, "second": 0, "weekday": 1 }
	)
