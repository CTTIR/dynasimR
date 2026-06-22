test_that("group colour and fill scales are ggplot scales", {
  sc1 <- scale_color_group_dynasimR()
  sc2 <- scale_fill_group_dynasimR()
  expect_s3_class(sc1, "Scale")
  expect_s3_class(sc2, "Scale")
})

test_that("policy colour scale is a ggplot scale", {
  sc <- scale_color_policy_dynasimR()
  expect_s3_class(sc, "Scale")
})

test_that("theme_dynasimR honours legend position and base size", {
  th <- theme_dynasimR(base_size = 14, legend_pos = "right")
  expect_s3_class(th, "theme")
  expect_equal(th$legend.position, "right")
})

test_that("dynasimR_colors are valid hex strings", {
  cols <- dynasimR_colors()
  expect_true(all(vapply(cols, function(x) grepl("^#[0-9A-Fa-f]{6}$", x),
                         logical(1))))
})
