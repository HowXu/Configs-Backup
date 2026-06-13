local options = {
   default_prog = { 'pwsh.exe -NoLogo -NoProfileLoadTime' },
   launch_menu = {
      { label = 'PowerShell', args = { 'pwsh.exe -NoLogo -NoProfileLoadTime' } },
      { label = 'Nushell',    args = { 'nu.exe' } },
      { label = 'Command',        args = { 'cmd.exe' } },
   },
}

return options
