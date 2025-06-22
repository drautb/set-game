class_name GdUnitExampleTest
extends GdUnitTestSuite


func test_card_number_translation(card_number: int,
                                  expected_count: int,
                                  expected_color: int,
                                  expected_fill: int,
                                  expected_shape: int,
                                  test_parameters := [
                                    [0, 1, 0, 0, 0],
                                    [80, 3, 2, 2, 2]
                                  ]):
  var c = auto_free(Card.new_card(card_number));
  assert_int(c.card_number).is_equal(card_number);
  assert_int(c.shape).is_equal(expected_shape);
  assert_int(c.shape_color).is_equal(expected_color);
  assert_int(c.shape_count).is_equal(expected_count);
  assert_int(c.fill).is_equal(expected_fill);


func test_card_number_update(count: int,
                             color: int,
                             fill: int,
                             shape: int,
                             expected_card_number: int,
                             test_parameters := [
                               [1, 0, 0, 0, 0],
                               [3, 2, 2, 2, 80]
                             ]):
  var c = auto_free(Card.new());
  c.shape_count = count
  c.shape_color = color
  c.fill = fill
  c.shape = shape
  c._update_card_number()
  assert_int(c.card_number).is_equal(expected_card_number)
