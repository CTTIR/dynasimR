# Scenario metadata for Profile A and Profile B

Describes all supported simulation scenarios (Profile A: A-S00..A-S14;
Profile B: B-S00..B-S20) with their research-question mapping, policy,
resource configuration and autonomy level.

## Usage

``` r
scenario_meta
```

## Format

A tibble with 36 rows and the following columns:

- id:

  Character. Scenario identifier with prefix (`"A-"` for Profile A,
  `"B-"` for Profile B).

- profile:

  Character. `"Profile_A"` or `"Profile_B"`.

- label:

  Character. Human-readable scenario name.

- rq:

  Character. Associated research question tag (`"RQ1"`..`"RQ4"`,
  `"SENS"`, `"PIPE"`).

- policy:

  Character. Policy type (`"policy_a"`, `"policy_b"`, `"mixed"`,
  `"NA"`).

- resource:

  Character. Auxiliary-resource configuration (`"none"`,
  `"observation"`, `"transport"`, `"active"`, `"mixed"`).

- al:

  Integer. Autonomy level (0-5) or `NA`.

## Source

Package example data.
