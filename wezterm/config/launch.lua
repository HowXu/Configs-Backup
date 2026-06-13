local options = {
   default_prog = { 'pwsh.exe -NoLogo' },
   launch_menu = {
      { label = 'PowerShell', args = { 'pwsh.exe -NoProfileLoadTime -NoLogo' } },
      { label = 'Nushell',    args = { 'nu.exe' } },
      { label = 'Command',        args = { 'cmd.exe' } },
   },
}

return options
