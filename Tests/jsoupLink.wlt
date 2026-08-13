Needs["PacletTools`"];
PacletDirectoryLoad[DirectoryName[DirectoryName[$TestFileName]]];
Needs["jsoupLink`"];

fixture = FileNameJoin[{DirectoryName[$TestFileName], "Fixtures", "sample.html"}];
searchFixture = FileNameJoin[{DirectoryName[$TestFileName], "Fixtures", "search.html"}];
dom = Import[fixture, "HTMLDOM"];
searchDOM = Import[searchFixture, "HTMLDOM"];
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
VerificationTest[!FreeQ[SubValues[Global`HTMLElement], jsoupLink`Private`popup, Infinity], True, TestID -> "DOM tree uses editable document window"]
VerificationTest[FreeQ[SubValues[Global`HTMLElement], _CreateDialog, Infinity], True, TestID -> "DOM tree does not use deployed dialog window"]
VerificationTest[!FreeQ[DownValues[jsoupLink`Private`popup], HoldPattern[Deployed -> False], Infinity], True, TestID -> "DOM tree window remains undeployed"]
searchMatches = jsoupLink`Private`domTreeSearchMatches[First@searchDOM, "needle"];
VerificationTest[Length@searchMatches, 2, TestID -> "DOM tree search deduplicates parent elements"]
VerificationTest[#@id[] & /@ searchMatches[[All, "Element"]], {"first", "second"}, TestID -> "DOM tree search preserves document order"]
VerificationTest[Length@jsoupLink`Private`domTreeSearchMatches[First@searchDOM, "NeEdLe"], 2, TestID -> "DOM tree search ignores case"]
VerificationTest[Length@jsoupLink`Private`domTreeSearchMatches[First@searchDOM, "cross boundary"], 0, TestID -> "DOM tree search does not join text nodes"]
VerificationTest[Length@jsoupLink`Private`domTreeSearchMatches[First@searchDOM, "data-key"], 0, TestID -> "DOM tree search ignores attributes"]
VerificationTest[Length@jsoupLink`Private`domTreeSearchMatches[First@searchDOM, "hiddenNeedle"], 0, TestID -> "DOM tree search ignores data nodes"]
VerificationTest[Length@jsoupLink`Private`domTreeSearchMatches[First@searchDOM, "   "], 0, TestID -> "DOM tree search ignores blank queries"]
searchRoot[_] := False;
searchRoot["treeRoot"] = First@searchDOM;
searchRoot["matches"] = searchMatches;
searchRoot["current"] = 0;
searchRoot["selected"] = Null;
searchRoot["query"] = "needle";
searchRoot["fontSize"] = 12;
searchRoot["rowHeight"] = jsoupLink`Private`domTreeRowHeight[searchRoot["fontSize"]];
searchRoot["scrollPosition"] = {0, 0};
jsoupLink`Private`selectDOMTreeMatch[searchRoot, 1];
VerificationTest[{searchRoot["current"], searchRoot["selected"]@id[], jsoupLink`Private`domTreeResultLabel[searchRoot]}, {1, "first", "1 / 2"}, TestID -> "DOM tree search selects and counts current result"]
VerificationTest[jsoupLink`Private`sameNodeQ[searchRoot["selected"], searchMatches[[1, "TextNode"]]@parent[]], True, TestID -> "DOM tree search selects smallest containing element"]
VerificationTest[And @@ (TrueQ[searchRoot[#]] & /@ jsoupLink`Private`domTreePath[searchRoot["treeRoot"], searchRoot["selected"]]), True, TestID -> "DOM tree search expands ancestor path"]
currentTextPosition = First@FirstPosition[jsoupLink`Private`domTreeVisibleRows[searchRoot["treeRoot"], TrueQ[searchRoot[#]] &], row_ /; jsoupLink`Private`sameNodeQ[row["Node"], searchMatches[[1, "TextNode"]]]];
VerificationTest[searchRoot["scrollPosition"], {0, Max[0, (currentTextPosition - 3) searchRoot["rowHeight"]]}, TestID -> "DOM tree search scroll uses rendered row height"]
currentElementRow = SelectFirst[jsoupLink`Private`domTreeVisibleRows[searchRoot["treeRoot"], TrueQ[searchRoot[#]] &], #Kind === "Open" && jsoupLink`Private`sameNodeQ[#Node, searchRoot["selected"]] &];
currentTextRow = SelectFirst[jsoupLink`Private`domTreeVisibleRows[searchRoot["treeRoot"], TrueQ[searchRoot[#]] &], jsoupLink`Private`sameNodeQ[#Node, searchMatches[[1, "TextNode"]]] &];
VerificationTest[And @@ (jsoupLink`Private`domTreeRowBackground[#, searchRoot] === jsoupLink`Private`colors["searchSelected", "background"] & /@ {currentElementRow, currentTextRow}), True, TestID -> "DOM tree search highlights current smallest element"]
VerificationTest[MatchQ[jsoupLink`Private`renderDOMTreeRows[{currentElementRow, currentTextRow}, searchRoot, Null &], Grid[{{_Item}, {_Item}}, ___]], True, TestID -> "DOM tree renders row backgrounds in a grid"]
VerificationTest[FreeQ[DownValues[jsoupLink`Private`setDOMTreeEventMode], HoldPattern[{"KeyDown", "n"} | {"KeyDown", "p"}], Infinity], True, TestID -> "DOM tree navigation does not reserve n or p keys"]
VerificationTest[FreeQ[DownValues[jsoupLink`Private`setDOMTreeEventMode], "ReturnKeyDown"], True, TestID -> "DOM tree search does not intercept ReturnKeyDown"]
VerificationTest[FreeQ[DownValues[jsoupLink`Private`beginDOMTreeSearch], _FinishDynamic, Infinity], True, TestID -> "DOM tree search focus does not force global dynamic completion"]
VerificationTest[FreeQ[DownValues[jsoupLink`Private`submitDOMTreeSearch], _SelectionMove], True, TestID -> "DOM tree search submit does not manipulate the notebook selection"]
VerificationTest[!FreeQ[DownValues[jsoupLink`Private`tree], HoldPattern[InputField[Dynamic[_], String, ___, ContinuousAction -> True, ___]]], True, TestID -> "DOM tree search field keeps its dynamic value current"]
VerificationTest[!FreeQ[DownValues[jsoupLink`Private`tree], HoldPattern[InputField[___, BaseStyle -> {Editable -> True, Selectable -> True}, ___]]], True, TestID -> "DOM tree search field remains editable and selectable"]
VerificationTest[FreeQ[DownValues[jsoupLink`Private`tree], HoldPattern[EventHandler[InputField[___], ___]], Infinity], True, TestID -> "DOM tree search field has no event interception"]
VerificationTest[Sort@Select[Cases[DownValues[jsoupLink`Private`tree], HoldPattern[Button[label_String, ___]] :> label, Infinity], MemberQ[{"Search", "prev", "next"}, #] &], {"next", "prev", "Search"}, TestID -> "DOM tree search uses explicit search and navigation buttons"]
VerificationTest[!FreeQ[DownValues[jsoupLink`Private`tree], HoldPattern[Deploy[Panel[_Column]]], Infinity], True, TestID -> "DOM tree panel blocks notebook content selection"]
VerificationTest[!FreeQ[DownValues[jsoupLink`Private`tree], HoldPattern[BaseStyle -> {___, Editable -> False, Selectable -> False, ___}], Infinity], True, TestID -> "DOM tree text remains protected from editing"]
VerificationTest[MemberQ[Cases[DownValues[jsoupLink`Private`tree], HoldPattern[TrackedSymbols :> symbols_] :> HoldComplete[symbols], Infinity], HoldComplete[{jsoupLink`Private`treeRevision}]], True, TestID -> "DOM tree rendering tracks only its explicit revision"]
VerificationTest[FreeQ[DownValues[jsoupLink`Private`tree], HoldPattern[TrackedSymbols :> {root}], Infinity], True, TestID -> "DOM tree rendering does not track all root state"]
VerificationTest[!FreeQ[DownValues[jsoupLink`Private`domTreeOpener], HoldPattern[Opener[Dynamic[_, _Function]]], Infinity], True, TestID -> "DOM tree expansion uses a native opener with a dynamic setter"]
VerificationTest[!FreeQ[DownValues[jsoupLink`Private`domTreeOpener], jsoupLink`Private`setDOMTreeNodeOpen, Infinity] && FreeQ[DownValues[jsoupLink`Private`renderDOMTreeRow], HoldPattern[Button[_, action_, ___]] /; !FreeQ[Unevaluated[action], jsoupLink`Private`setDOMTreeNodeOpen, Infinity], Infinity], True, TestID -> "DOM tree expansion binds the native opener to the explicit refresh path"]
VerificationTest[FreeQ[DownValues[jsoupLink`Private`popup], _WindowElements, Infinity], True, TestID -> "DOM tree window preserves default keyboard command elements"]
VerificationTest[!FreeQ[DownValues[jsoupLink`Private`popup], HoldPattern[Editable -> True], Infinity] && !FreeQ[DownValues[jsoupLink`Private`popup], HoldPattern[Selectable -> True], Infinity], True, TestID -> "DOM tree notebook permits input field editing and selection"]
secondBranch = First@First@HTMLSelect[searchDOM, "#second-branch"];
secondBranchRow = SelectFirst[jsoupLink`Private`domTreeVisibleRows[searchRoot["treeRoot"], TrueQ[searchRoot[#]] &], #Kind === "Summary" && jsoupLink`Private`sameNodeQ[#Node, secondBranch] &];
visibleRowCount = Length@jsoupLink`Private`domTreeVisibleRows[searchRoot["treeRoot"], TrueQ[searchRoot[#]] &];
refreshCount = 0;
jsoupLink`Private`setDOMTreeNodeOpen[searchRoot, secondBranch, True, Function[refreshCount++]];
VerificationTest[{TrueQ[searchRoot[secondBranch]], Length@jsoupLink`Private`domTreeVisibleRows[searchRoot["treeRoot"], TrueQ[searchRoot[#]] &] > visibleRowCount, refreshCount}, {True, True, 1}, TestID -> "DOM tree expansion changes state and requests one render"]
searchRoot["searchSelected"] = Null;
VerificationTest[jsoupLink`Private`domTreeRowBackground[currentTextRow, searchRoot], None, TestID -> "DOM tree manual selection clears search highlight"]
searchRoot["searchSelected"] = searchRoot["selected"];
jsoupLink`Private`navigateDOMTreeSearch[searchRoot, -1];
VerificationTest[{searchRoot["current"], searchRoot["selected"]@id[]}, {2, "second"}, TestID -> "DOM tree previous result wraps"]
jsoupLink`Private`navigateDOMTreeSearch[searchRoot, 1];
VerificationTest[{searchRoot["current"], searchRoot["selected"]@id[]}, {1, "first"}, TestID -> "DOM tree next result wraps"]
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

Clear[fixture, searchFixture, dom, searchDOM, searchMatches, searchRoot, currentTextPosition, currentElementRow, currentTextRow, secondBranch, secondBranchRow, visibleRowCount, refreshCount, main, lead, link, peer, copy, mutable, exported];
