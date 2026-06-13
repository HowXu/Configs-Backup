local options = {
   default_prog = { 'pwsh.exe -NoLogo' },
   launch_menu = {
      { label = 'PowerShell', args = { 'pwsh.exe -NoLogo' } },
      { label = 'Nushell',    args = { 'nu' } },
      { label = 'Command',        args = { 'cmd' } },
   },
}

return options
