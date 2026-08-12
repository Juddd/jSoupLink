#!/usr/bin/env wolframscript

Needs["PacletTools`"];

projectRoot = DirectoryName[DirectoryName[$InputFileName]];
sourceRoot = FileNameJoin[{projectRoot, "jsoupLink"}];
buildRoot = FileNameJoin[{projectRoot, "build"}];
expectedFiles = {
  "PacletInfo.wl",
  "Kernel/jsoupLink.wl",
  "Kernel/assets/documenticon.png",
  "Java/jsoup-1.23.1.jar",
  "Documentation/English/Guides/jsoupLinkSymbols.nb",
  "Documentation/English/ReferencePages/Symbols/HTMLTree.nb"
};

fail[message_] := (WriteString[$Output, "Build failed: " <> message <> "\n"]; Exit[1]);

If[DirectoryQ[buildRoot], DeleteDirectory[buildRoot, DeleteContents -> True]];
CreateDirectory[buildRoot];

result = PacletBuild[sourceRoot, buildRoot];
If[Head[result] =!= Success, fail["PacletBuild did not return Success."]];

manifestFiles = FileNameJoin /@ FileNameSplit /@ (ToString[#, InputForm] & /@ Normal[result["PacletManifest"]]["Files"][[All, "File"]]);
manifestFiles = StringReplace[manifestFiles, {"File[\"" -> "", "\"]" -> ""}];
If[!SubsetQ[manifestFiles, Rest[expectedFiles]], fail["required files are missing from PacletManifest.wl."]];

archive = result["PacletArchive"];
extractRoot = CreateDirectory[];
ExtractPacletArchive[archive, extractRoot];
archiveRoot = First@Select[FileNames["*", extractRoot], DirectoryQ];
missing = Select[expectedFiles, !FileExistsQ[FileNameJoin[{archiveRoot, #}]] &];
If[missing =!= {}, fail["archive is missing: " <> StringRiffle[missing, ", "]]];

sourceHash = FileHash[FileNameJoin[{sourceRoot, "Java", "jsoup-1.23.1.jar"}], "SHA256", "HexString"];
archiveHash = FileHash[FileNameJoin[{archiveRoot, "Java", "jsoup-1.23.1.jar"}], "SHA256", "HexString"];
If[sourceHash =!= archiveHash, fail["archived jsoup JAR hash does not match the source."]];

forbidden = {"jSoupLink.wl", "jSoupLink.m", "jsoup-1.17.2.jar", "jsoup-1.9.2.jar"};
archiveFileNames = FileNameTake /@ Select[FileNames["*", archiveRoot, Infinity], FileType[#] === File &];
If[Intersection[archiveFileNames, forbidden] =!= {}, fail["archive contains an obsolete entry file or JAR."]];

DeleteDirectory[extractRoot, DeleteContents -> True];
WriteString[$Output, archive <> "\n"];
WriteString[$Output, "SHA256 " <> FileHash[archive, "SHA256", "HexString"] <> "\n"];
Exit[0];
