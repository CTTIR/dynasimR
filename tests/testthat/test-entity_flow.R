# Synthetic entity table with stage-time columns for throughput tests.
make_stage_entities <- function() {
  set.seed(11)
  tibble::tibble(
    scenario        = rep(c("A-S00", "A-S01"), each = 20),
    time_to_stage1  = stats::runif(40, 1, 10),
    time_to_stage2  = stats::runif(40, 5, 30),
    reached_stage1  = rep(c(1, 0), 20),
    reached_stage2  = rep(c(1, 1, 0, 1), 10)
  )
}

test_that("stage_throughput summarises per scenario/stage", {
  ent <- make_stage_entities()
  tp <- stage_throughput(ent, stages = c("Stage1", "Stage2"))
  expect_s3_class(tp, "tbl_df")
  expect_true(all(c("scenario", "stage", "n", "median_time",
                    "q25", "q75", "completed_frac") %in% names(tp)))
  # two scenarios x two stages = 4 rows
  expect_equal(nrow(tp), 4L)
  expect_true(all(is.na(tp$completed_frac) |
                    (tp$completed_frac >= 0 & tp$completed_frac <= 1)))
})

test_that("stage_throughput drops stages with no time column", {
  ent <- make_stage_entities()
  tp <- stage_throughput(ent, stages = c("Stage1", "StageMissing"))
  # StageMissing has no time column -> only Stage1 rows
  expect_true(all(tp$stage == "Stage1"))
})

test_that("stage_throughput accepts a dynasimR_data object", {
  sim <- load_example_data()
  tp <- stage_throughput(sim, stages = c("Stage2"))
  expect_s3_class(tp, "tbl_df")
  expect_gt(nrow(tp), 0)
})

test_that("stage_throughput completed_frac is NA without reached col", {
  ent <- make_stage_entities()
  ent$reached_stage1 <- NULL
  tp <- stage_throughput(ent, stages = c("Stage1"))
  expect_true(all(is.na(tp$completed_frac)))
})

test_that("detect_bottlenecks flags top-quartile stages", {
  ent <- make_stage_entities()
  tp <- stage_throughput(ent, stages = c("Stage1", "Stage2"))
  bn <- detect_bottlenecks(tp, threshold = 0.5)
  expect_true("is_bottleneck" %in% names(bn))
  expect_true(all(bn$is_bottleneck))
})

test_that("detect_bottlenecks works directly on dynasimR_data", {
  sim <- load_example_data()
  bn <- detect_bottlenecks(sim, threshold = 0.5)
  expect_s3_class(bn, "tbl_df")
})

test_that("detect_bottlenecks aborts without median_time column", {
  expect_error(
    detect_bottlenecks(tibble::tibble(x = 1:3)),
    "median_time"
  )
})
