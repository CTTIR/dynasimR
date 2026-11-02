## server.R - dynasimR Shiny dashboard

# Source module servers
module_dir <- file.path("modules")
for (m in list.files(module_dir, pattern = "\\.R$",
                     full.names = TRUE))
  source(m, local = TRUE)

function(input, output, session) {
  mod_overview_server("overview",     SIM_DATA)
  mod_comparison_server("comparison", SIM_DATA)
  if (!.is_profile_b) {
    mod_map_server("map",             SIM_DATA)
    mod_survival_server("survival",   SIM_DATA)
    mod_policy_server("policy",       SIM_DATA,
      default_policy_a = DEFAULT_POLICY_A,
      default_policy_b = DEFAULT_POLICY_B)
    mod_autonomy_server("autonomy",   SIM_DATA)
  }
  mod_export_server("export",         SIM_DATA)
}
