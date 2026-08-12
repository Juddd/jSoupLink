Needs["PacletTools`"];
PacletDirectoryLoad[DirectoryName[DirectoryName[$TestFileName]]];
Needs["jsoupLink`"];

fixture = FileNameJoin[{DirectoryName[$TestFileName], "Fixtures", "sample.html"}];
dom = Import[fixture, "HTMLDOM"];
main = First@dom["Select", "main"];
lead = First@dom["Select", "p.lead"];
link = First@dom["Select", "a"];
peer = First@dom["Select", ".peer"];

VerificationTest[Head[dom] === Global`HTMLElement, True, TestID -> "HTMLElement remains in Global context"]
VerificationTest[dom["TagName"], "html", TestID -> "Import HTMLDOM"]
VerificationTest[dom["Properties"], {"TagName", "Root", "Parent", "Children", "Siblings", "Select", "AllElements", "Value", "InnerHTML", "OuterHTML", "OwnText", "AllText", "ID", "ClassNames", "HasAttribute", "Attribute", "Attributes", "RemoveAttribute", "IsBlock", "HasText", "BaseURI", "HasClass", "AddClass", "RemoveClass", "ToggleClass", "After", "Before", "Append", "Prepend", "ReplaceWith", "Remove", "Wrap", "Unwrap", "Clean", "DeepCopy", "DOMTree"}, TestID -> "Legacy property list"]
VerificationTest[lead["OwnText"], "Hello", TestID -> "Legacy OwnText property"]
VerificationTest[lead["AllText"], "Hello world", TestID -> "Legacy AllText property"]
VerificationTest[lead["Attribute", "data-kind"], "intro", TestID -> "Legacy Attribute property"]
VerificationTest[lead["data-kind"], "intro", TestID -> "Legacy attribute shorthand"]
VerificationTest[lead["Attributes"], <|"class" -> "lead", "data-kind" -> "intro"|>, TestID -> "Legacy Attributes property"]
VerificationTest[lead["Parent"]["TagName"], "main", TestID -> "Legacy Parent property"]
VerificationTest[Length@main["Children"], 3, TestID -> "Legacy Children property"]
VerificationTest[Sort[#["TagName"] & /@ link["Siblings"]], {"div", "p"}, TestID -> "Legacy Siblings property"]
VerificationTest[Length@dom["AllElements"] > 5, True, TestID -> "Legacy AllElements property"]
VerificationTest[dom["Root"]["TagName"], "html", TestID -> "Legacy Root property"]
VerificationTest[Length@dom["Select", "p.lead"], 1, TestID -> "Legacy Select property"]
VerificationTest[Length@dom["Select", ":containsData(fkey)"] > 0, True, TestID -> "Issue 5 containsData selector"]
VerificationTest[HTMLSelect[dom, "p.lead"], dom["Select", "p.lead"], TestID -> "HTMLSelect wrapper"]
VerificationTest[HTMLSelect["p.lead"][dom], dom["Select", "p.lead"], TestID -> "HTMLSelect operator form"]
VerificationTest[HTMLAttribute[lead, "data-kind"], lead["Attribute", "data-kind"], TestID -> "HTMLAttribute wrapper"]
VerificationTest[HTMLAttribute["data-kind"][lead], lead["Attribute", "data-kind"], TestID -> "HTMLAttribute operator form"]
VerificationTest[HTMLAttributes[lead], lead["Attributes"], TestID -> "HTMLAttributes wrapper"]
VerificationTest[HTMLParent[lead], lead["Parent"], TestID -> "HTMLParent wrapper"]
VerificationTest[HTMLChildren[main], main["Children"], TestID -> "HTMLChildren wrapper"]
VerificationTest[HTMLSiblings[link], link["Siblings"], TestID -> "HTMLSiblings wrapper"]
VerificationTest[HTMLOwnText[lead], lead["OwnText"], TestID -> "HTMLOwnText wrapper"]
VerificationTest[HTMLAllText[lead], lead["AllText"], TestID -> "HTMLAllText wrapper"]
VerificationTest[StringQ[HTMLTree::usage] && StringContainsQ[HTMLTree::usage, "DOM tree"], True, TestID -> "HTMLTree usage"]
VerificationTest[Length[DownValues[HTMLTree]] > 0, True, TestID -> "HTMLTree definition exists"]
VerificationTest[Quiet[lead["NoSuchProperty"]], $Failed, TestID -> "Unknown property failure"]
VerificationTest[Quiet[lead["Children", 1]], $Failed, TestID -> "Wrong argument count failure"]

exported = CreateTemporary[];
Export[exported, dom, "HTMLDOM"];
VerificationTest[StringContainsQ[Import[exported, "Text"], "data-kind=\"intro\""], True, TestID -> "Export HTMLDOM"]
DeleteFile[exported];

copy = lead["DeepCopy"];
copy["Attribute", "data-copy", "yes"];
VerificationTest[{copy["Attribute", "data-copy"], lead["HasAttribute", "data-copy"]}, {"yes", False}, TestID -> "Legacy DeepCopy and Attribute mutation"]

mutable = peer["DeepCopy"];
mutable["AddClass", "added"];
mutable["ToggleClass", "added"];
mutable["Attribute", <|"data-a" -> "1", "data-b" -> "2"|>];
mutable["RemoveAttribute", "data-b"];
VerificationTest[{mutable["HasClass", "added"], mutable["Attribute", "data-a"], mutable["HasAttribute", "data-b"]}, {False, "1", False}, TestID -> "Legacy class and attribute mutation"]

Clear[fixture, dom, main, lead, link, peer, copy, mutable, exported];
