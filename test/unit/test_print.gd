# ------------------------------------------------------------------------------
# These tests are used to test the output generated by parameterized
# tests.  These are only for visually verifying output formatting.
# ------------------------------------------------------------------------------
extends "res://addons/gut/test.gd"

var _old_indent_string = ''

func before_all():
	gut.p('[before all]')
	_old_indent_string = gut.get_logger().get_indent_string()
	#gut.get_logger().set_indent_string('|---')

func after_all():
	gut.p('[after all]')
	gut.get_logger().set_indent_string(_old_indent_string)

func before_each():
	gut.p('[before each]')

func after_each():
	gut.p('[after each]')

func test_print_indent():
	gut.p('one')
	gut.p('two', 1, 2)
	gut.p('three', 1, 3)
	gut.p('four', 1, 4)

func test_print_non_strings():
	gut.p([1, 2, 3])
	var n2d = Node2D.new()
	gut.p(n2d)
	n2d.free()

func test_print_multiple_lines():
	var lines = "hello\nworld\nhow\nare\nyou?"
	gut.p(lines)

func test_no_parameters():
	assert_true(true, 'this passes')

func test_multiple_passing_no_params():
	assert_true(true, 'passing test one')
	gut.p('something')
	assert_false(false, 'passing test two')

func test_multiple_failing_no_params():
	assert_false(true, 'failing test one')
	assert_true(false, 'failing test two')

func test_basic_array(p=use_parameters([1, 2, 1, 4])):
	assert_eq(p, 1, 'output test may fail')

func test_all_passing(p=use_parameters([[1, 2], [3, 4], [5, 6]])):
	assert_eq(p[0], p[1 -1], 'output test, should all pass.')

func test_show_error():
	_lgr.error('Something bad happened')
	assert_false(false)

func test_show_warning():
	_lgr.warn('Something kinda bad happened')
	assert_true(true)

func test_show_info():
	_lgr.info('Something happened')
	assert_true(true)

func test_yield():
	gut.p('starting yield')
	yield(yield_for(2), YIELD)
	gut.p('end yield')

class TestGuiOutput:
	extends 'res://addons/gut/test.gd'

	func test_embedded_bbcode():
		_lgr.log('[u]this should not be underlined')
		assert_string_contains(gut.get_gui().get_text_box().get_text(), '[u]this should')

	func test_embedded_bbcode_with_format():
		_lgr.log('[i]this should not be italic', _lgr.fmts.yellow)
		assert_string_contains(gut.get_gui().get_text_box().get_text(), '[i]this should')

class TestBasicLoggerOutput:
	extends 'res://test/gut_test.gd'

	var _test_logger = null
	func before_each():
		_test_logger = _utils.Logger.new()
		_test_logger.set_gut(gut)
		_test_logger.set_indent_string('|...')
		_test_logger._skip_test_name_for_testing = true

	func test_indent_levels():
		_test_logger.log('0 indent')
		_test_logger.inc_indent()
		_test_logger.log('1 indent')
		_test_logger.inc_indent()
		_test_logger.inc_indent()
		_test_logger.log('3 indents')
		_test_logger.set_indent_level(1)
		_test_logger.log('1 indent')
		_test_logger.set_indent_level(10)
		_test_logger.log('10 indents')
		assert_true(true)

	func test_indent_with_new_lines():
		_test_logger.set_indent_level(2)
		_test_logger.log("hello\nthis\nshould\nline up")
		assert_true(true)

class TestLogLevels:
	extends 'res://addons/gut/test.gd' # this was on purpose

	var _orig_log_level = -1
	var _orig_indent_string = null

	func before_all():
		_orig_log_level = gut.get_log_level()
		_orig_indent_string = gut.get_logger().get_indent_string()
		gut.get_logger().set_indent_string('--->')

	func after_all():
		gut.set_log_level(_orig_log_level)
		gut.get_logger().set_indent_string(_orig_indent_string)

	func test_log_types_at_levels_with_passing_test(level=use_parameters([-2, -1, 0, 1, 2, 3])):
		gut.set_log_level(level)
		gut.get_logger().warn('test text')
		gut.get_logger().error('test text')
		gut.get_logger().info('test text')
		gut.get_logger().debug('test text')
		assert_true(true, 'this should pass')

	func test_log_types_at_levels_with_failing_test(level=use_parameters([-2, -1, 0, 1, 2, 3])):
		gut.set_log_level(level)
		gut.get_logger().warn('test text')
		gut.get_logger().error('test text')
		gut.get_logger().info('test text')
		gut.get_logger().debug('test text')
		assert_true(false, str('this should fail (', level, ')'))
