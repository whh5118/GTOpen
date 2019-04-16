il_allegro << EOF


file = strcat(buildString(parseString(getShellEnvVar("HOME") "\\\\") "/") "/pcbenv/allegro.ilinit")
port = outfile(file "a")
fprintf(port "load(\"%s/Code/gtopen_main.il\")\n" buildString(parseString(getWorkingDir() "\\\\") "/"))
close(port)

exit
EOF