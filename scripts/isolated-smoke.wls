archive = SelectFirst[$CommandLine, StringEndsQ[#, ".paclet"] &, Missing["Archive"]];
If[MissingQ[archive] || !FileExistsQ[archive], WriteString[$Output, "Archive not found.\n"]; Exit[1]];

installed = PacletInstall[archive, ForceVersionInstall -> True];
If[Head[installed] =!= PacletObject || installed["Version"] =!= "1.1.1", WriteString[$Output, "PacletInstall failed.\n"]; Exit[1]];
WriteString[$Output, "Installed " <> installed["Name"] <> " " <> installed["Version"] <> "\n"];
Exit[0];
