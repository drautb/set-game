class_name GdUnitExampleTest
extends GdUnitTestSuite


func test_grid_idx_position_conversion(grid_idx: int,
                                       expected_position: Vector2,
                                       test_parameters := [
                                         [0, Vector2(0, 0)],
                                         [1, Vector2(313, 0)],
                                         [2, Vector2(626, 0)],
                                         [3, Vector2(938, 0)],
                                         [4, Vector2(0, 224)],
                                         [5, Vector2(313, 224)],
                                       ]):
  var position = Constants.grid_idx_to_position(grid_idx)
  assert_vector(position, true).is_equal(expected_position);
