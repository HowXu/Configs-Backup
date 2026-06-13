return {
  {
    "mfussenegger/nvim-jdtls",
    optional = true,
    opts = function(_, opts)
      opts.cmd = opts.cmd or { "jdtls" }

      local optimized_jvm_args = {
        "-Xmx2G",
        "-Xms1G",
        "-XX:+UseG1GC",
        "-XX:+UseStringDeduplication",
        "-XX:ReservedCodeCacheSize=512m",
        "-Dsun.zip.disableMemoryMapping=true",
        "-Xlog:disable",
      }
      for _, arg in ipairs(optimized_jvm_args) do
        table.insert(opts.cmd, "--jvm-arg=" .. arg)
      end
    -- close arguments submit
      opts.settings = opts.settings or {}
      opts.settings.java = opts.settings.java or {}
      opts.settings.java.completion = opts.settings.java.completion or {}
      opts.settings.java.completion.guessMethodArguments = false
    end,
  },
}
