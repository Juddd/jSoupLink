archive = SelectFirst[$CommandLine, StringEndsQ[#, ".paclet"] &, Missing["Archive"]];
If[MissingQ[archive] || !FileExistsQ[archive], WriteString[$Output, "Official 1.0 archive not found.\n"]; Exit[1]];
installed = PacletInstall[archive, ForceVersionInstall -> True];
If[Head[installed] =!= PacletObject || installed["Version"] =!= "1.0.0", WriteString[$Output, "Installing official 1.0.0 failed.\n"]; Exit[1]];
WriteString[$Output, "Installed official 1.0.0 baseline.\n"];
Exit[0];
