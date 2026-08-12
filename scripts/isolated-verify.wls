expectedJarHash = "8b15e2b28eeb1e0a88a9b7dab4dc0c23524491c56959785dea22f7846897b668";
fixture = FileNameJoin[{DirectoryName[DirectoryName[$InputFileName]], "Tests", "Fixtures", "sample.html"}];
paclets = PacletFind["jsoupLink"];
matchingPaclets = Select[paclets, #["Version"] === "1.1.0" &];
If[Length[matchingPaclets] =!= 1, WriteString[$Output, "PacletFind did not find exactly one 1.1.0 paclet.\n"]; Exit[1]];

paclet = First[matchingPaclets];
expectedEntry = FileNameJoin[{paclet["Location"], "Kernel", "jsoupLink.wl"}];
If[ExpandFileName[FindFile["jsoupLink`"]] =!= ExpandFileName[expectedEntry], WriteString[$Output, "Paclet resolution did not select the 1.1.0 entry file.\n"]; Exit[1]];
jar = FileNameJoin[{paclet["Location"], "Java", "jsoup-1.23.1.jar"}];
If[!FileExistsQ[jar] || FileHash[jar, "SHA256", "HexString"] =!= expectedJarHash, WriteString[$Output, "Installed jsoup JAR is missing or has the wrong hash.\n"]; Exit[1]];

Needs["jsoupLink`"];
dom = Import[fixture, "HTMLDOM"];
lead = First@HTMLSelect["p.lead"]@dom;
checks = {
  Head[dom] === Global`HTMLElement,
  dom["TagName"] === "html",
  HTMLAttribute["data-kind"]@lead === "intro",
  HTMLAllText[lead] === "Hello world",
  Length@HTMLSelect[dom, ":containsData(fkey)"] > 0,
  Length[DownValues[HTMLTree]] > 0,
  $MessageList === {}
};
If[!And @@ checks, WriteString[$Output, "Fresh-kernel smoke checks failed: " <> ToString[checks, InputForm] <> "\n"]; Exit[1]];
WriteString[$Output, "Fresh-kernel verification passed.\n"];
Exit[0];
