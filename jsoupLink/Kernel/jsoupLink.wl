(* ::Package:: *)

(* Mathematica Package                     *)

(* :Title: jsoupLink                       *)
(* :Context: jsoupLink`                    *)
(* :Author: Calle Ekdahl                   *)
(* :Date: 2026-08-12                       *)

(* :Package Version: 1.1.2                 *)
(* :Mathematica Version: 12.3.0.0          *)
(* :Copyright: (c) 2015-2024 Calle Ekdahl  *)
(* :Keywords:                              *)
(* :Discussion:                            *)

BeginPackage["jsoupLink`"];

HTMLSelect::usage = "HTMLSelect[rootElement, selector] returns the elements that match the CSS selector.
HTMLSelect[selector] represents an operator form of HTMLSelect that can be applied to an element.";
HTMLAttribute::usage ="HTMLAttribute[element, attribute] gets the given attribute from the element.
HTMLAttribute[attribute] represents an operator form of HTMLAttribute that can be applied to an element.";
HTMLAttributes::usage = "HTMLAttributes[element] returns the attributes of the element in the form of an association.";
HTMLParent::usage = "HTMLParent[element] returns the parent of the element.";
HTMLChildren::usage = "HTMLChildren[element] returns the list of children of the element.";
HTMLSiblings::usage = "HTMLSiblings[element] returns the list of siblings of the element.";
HTMLOwnText::usage = "HTMLOwnText[element] returns the text directly under the element, i.e. not nested in a child. The own text of <h1>Hello <b>world</b></h1> is \"Hello\".";
HTMLAllText::usage = "HTMLAllText[element] returns all text under the element. Applied to <h1>Hello <b>world</b></h1> it would return \"Hello world\".";
HTMLSelectFirst::usage = "HTMLSelectFirst[rootElement, selector] returns the first element that matches the CSS selector. HTMLSelectFirst[selector] represents an operator form.";
HTMLExpectFirst::usage = "HTMLExpectFirst[rootElement, selector] returns the first element that matches the CSS selector and fails if there is no match. HTMLExpectFirst[selector] represents an operator form.";
HTMLClosest::usage = "HTMLClosest[element, selector] returns the closest matching element, including the element itself. HTMLClosest[selector] represents an operator form.";
HTMLSelectXPath::usage = "HTMLSelectXPath[rootElement, xpath] returns the elements that match the XPath expression. HTMLSelectXPath[xpath] represents an operator form.";
HTMLWholeText::usage = "HTMLWholeText[element] returns the element's full text while preserving whitespace.";
HTMLWholeOwnText::usage = "HTMLWholeOwnText[element] returns the element's direct text while preserving whitespace, excluding descendant elements.";
HTMLDataset::usage = "HTMLDataset[element] returns the element's data-* attributes as an association.";
HTMLCSSSelector::usage = "HTMLCSSSelector[element] returns a CSS selector that identifies the element.";
HTMLTree::usage = "HTMLTree[element] opens an interactive DOM tree for the element. It is equivalent to element[\"DOMTree\"].";

Begin["`Private`"]; (* Begin Private Context *)

Needs["JLink`"];
InstallJava[];
AddToClassPath[FileNameJoin[{DirectoryName[DirectoryName[$InputFileName]], "Java", "jsoup-1.23.1.jar"}]];
LoadJavaClass["org.jsoup.Jsoup"];
LoadJavaClass["org.jsoup.safety.Safelist"];

ImportExport`RegisterImport["HTMLDOM", jsoupLink`DownloadDOM];
ImportExport`RegisterExport["HTMLDOM", jsoupLink`ExportDOM];

DownloadDOM[filename_String, opts___] := ParseDOM[Import[filename, "Text", opts]];
DownloadDOM[$Failed, _String] := $Failed;

ParseDOM[html_String, baseUri_String:""] := Module[{doc, root},
  doc = JavaBlock[Jsoup`parse[html, baseUri]];
  root = First[doc@children[]@toArray[]];
  Global`HTMLElement[root]
];

wrapElement[node_] := If[node === Null, Null, Global`HTMLElement[node]];
wrapElements[elements_] := Global`HTMLElement /@ elements@toArray[];
javaMapAssociation[map_] := Association @@ (#@getKey[] -> #@getValue[] & /@ map@entrySet[]@toArray[]);

ExportDOM[filename_, data_, opts___] := Export[filename, data["OuterHTML"], "Text", opts];

icon = Import[FileNameJoin[{DirectoryName[$InputFileName], "assets/documenticon.png"}]];

(* http://mathematica.stackexchange.com/questions/77658/how-to-create-a-dynamic-expanding-displayforms-styled-like-the-ones-in-v10/79891#79891 *)
MakeBoxes[obj_Global`HTMLElement, fmt_] ^:= Module[{el = First[obj], shown, hidden, icon = Show[icon, ImageSize -> 70]},
      shown = {
        {BoxForm`MakeSummaryItem[{"Tag: ", el@tagName[]}, fmt], SpanFromLeft},
        {BoxForm`MakeSummaryItem[{"Children: ", Length@el@children[]@toArray[]}, fmt], SpanFromLeft},
        {BoxForm`MakeSummaryItem[{"Has text: ", el@hasText[]}, fmt], SpanFromLeft}
      };
      hidden = {
        {BoxForm`MakeSummaryItem[{"ID: ", el@id[]}, fmt], SpanFromLeft},
        {BoxForm`MakeSummaryItem[{"Classes: ", Row[el@classNames[]@toArray[], ", "]}, fmt], SpanFromLeft},
        {BoxForm`MakeSummaryItem[{"Block level: ", el@isBlock[]}, fmt], SpanFromLeft}
      };
      BoxForm`ArrangeSummaryBox[Global`HTMLElement, obj, icon, shown, hidden, fmt, "Interpretable" -> True]
    ];

(* https://chat.stackexchange.com/transcript/message/47430225#47430225 *)
Global`HTMLElement::reserved = "The attribute \"``\" can't be set using Set (=) because the name collides with a jsoupLink property.";
SetAttributes[myMutationHandler, HoldAllComplete];
myMutationHandler[Set[node_[attr_], val_]] := If[
  MemberQ[node["Properties"], attr],
  Message[Global`HTMLElement::reserved, attr]; node,
  node["Attribute", attr, val]
];
myMutationHandler[___] := Language`MutationFallthrough;
Language`SetMutationHandler[Global`HTMLElement, myMutationHandler];

Global`HTMLElement[el_]["TagName"] := el@tagName[];
Global`HTMLElement[el_]["TagName", tag_] := el@tagName[tag];
Global`HTMLElement[el_]["Root"] := Global`HTMLElement[First[el@ownerDocument[]@children[]@toArray[]]];
Global`HTMLElement[el_]["Parent"] := If[el@tagName[] != "html", Global`HTMLElement[el@parent[]], Global`HTMLElement[el]];
Global`HTMLElement[el_]["Children"] := Global`HTMLElement /@ el@children[]@toArray[];
Global`HTMLElement[el_]["Siblings"] := Global`HTMLElement /@ el@siblingElements[]@toArray[];
Global`HTMLElement[el_]["Select", selector_String] := Global`HTMLElement /@ el@select[selector]@toArray[];
Global`HTMLElement[el_]["SelectFirst", selector_String] := wrapElement[el@selectFirst[selector]];
Global`HTMLElement[el_]["ExpectFirst", selector_String] := Global`HTMLElement[el@expectFirst[selector]];
Global`HTMLElement[el_]["Closest", selector_String] := wrapElement[el@closest[selector]];
Global`HTMLElement[el_]["SelectXPath", xpath_String] := wrapElements[el@selectXpath[xpath]];
Global`HTMLElement[el_]["AllElements"] := Global`HTMLElement /@ el@getAllElements[]@toArray[];
Global`HTMLElement[el_]["Value"] := el@val[];
Global`HTMLElement[el_]["InnerHTML"] := el@html[];
Global`HTMLElement[el_]["InnerHTML", newHTML_String] := Global`HTMLElement[el@html[newHTML]];
Global`HTMLElement[el_]["OuterHTML"] := el@outerHtml[];
Global`HTMLElement[el_]["OwnText"] := el@ownText[];
Global`HTMLElement[el_]["WholeText"] := el@wholeText[];
Global`HTMLElement[el_]["WholeOwnText"] := el@wholeOwnText[];
Global`HTMLElement[el_]["AllText"] := el@text[];
Global`HTMLElement[el_]["AllText", txt_] := Global`HTMLElement[el@text[txt]];
Global`HTMLElement[el_]["ID"] := el@id[];
Global`HTMLElement[el_]["ClassNames"] := el@classNames[]@toArray[];
Global`HTMLElement[el_]["HasAttribute", attribute_String] := el@hasAttr[attribute];
Global`HTMLElement[el_]["Attribute", attribute_String] := el@attr[attribute];
Global`HTMLElement[el_]["Attribute", key_String, value_String] := Global`HTMLElement[el@attr[key, value]];
Global`HTMLElement[el_]["Attribute", assoc_Association] := (KeyValueMap[el@attr[#,#2] &, assoc]; Global`HTMLElement[el]);
Global`HTMLElement[el_]["Attributes"] := Association @@ (#@getKey[] -> #@getValue[] & /@ el@attributes[]@asList[]@toArray[]);
Global`HTMLElement[el_]["Dataset"] := javaMapAssociation[el@dataset[]];
Global`HTMLElement[el_]["RemoveAttribute", attribute_String] := Global`HTMLElement[el@removeAttr[attribute]];
Global`HTMLElement[el_]["IsBlock"] := el@isBlock[];
Global`HTMLElement[el_]["HasText"] := el@hasText[];
Global`HTMLElement[el_]["BaseURI"] := el@baseUri[];
Global`HTMLElement[el_]["BaseURI", uri_String] := el@setBaseUri[uri];
Global`HTMLElement[el_]["HasClass", class_String] := el@hasClass[class];
Global`HTMLElement[el_]["CSSSelector"] := el@cssSelector[];
Global`HTMLElement[el_]["AddClass", class_String] := Global`HTMLElement[el@addClass[class]];
Global`HTMLElement[el_]["RemoveClass", class_String] := Global`HTMLElement[el@removeClass[class]];
Global`HTMLElement[el_]["ToggleClass", class_String] := Global`HTMLElement[el@toggleClass[class]];
Global`HTMLElement[el_]["After", html_String] := Global`HTMLElement[el@after[html]];
Global`HTMLElement[el_]["Before", html_String] := Global`HTMLElement[el@before[html]];
Global`HTMLElement[el_]["After", Global`HTMLElement[child_]] := Global`HTMLElement[el@after[child]];
Global`HTMLElement[el_]["Before", Global`HTMLElement[child_]] := Global`HTMLElement[el@before[child]];
Global`HTMLElement[el_]["Append", html_String] := Global`HTMLElement[el@append[html]];
Global`HTMLElement[el_]["Prepend", html_String] := Global`HTMLElement[el@prepend[html]];
Global`HTMLElement[el_]["Append", Global`HTMLElement[child_]] := Global`HTMLElement[el@appendChild[child]];
Global`HTMLElement[el_]["Prepend", Global`HTMLElement[child_]] := Global`HTMLElement[el@prependChild[child]];
Global`HTMLElement[el_]["ReplaceWith", Global`HTMLElement[replacement_]] := Global`HTMLElement[el@replaceWith[replacement]];
Global`HTMLElement[el_]["Remove"] := (el@remove[]; Null);
Global`HTMLElement[el_]["Wrap", html_] := Global`HTMLElement[el@wrap[html]];
Global`HTMLElement[el_]["Unwrap"] := With[{p = el@parent[]}, el@unwrap[]; wrapElement[p]];
Global`HTMLElement[el_]["Clean"] := Global`HTMLElement[el@html[Jsoup`clean[el@html[], Safelist`relaxed[]]]];
Global`HTMLElement[el_]["DeepCopy"] := Global`HTMLElement[JavaBlock[el@clone[]]];
Global`HTMLElement[el_]["DOMTree"] := popup[el];

properties = {"TagName", "Root", "Parent", "Children", "Siblings",
  "Select", "SelectFirst", "ExpectFirst", "Closest", "SelectXPath", "AllElements", "Value", "InnerHTML", "OuterHTML",
  "OwnText", "WholeText", "WholeOwnText", "AllText", "ID", "ClassNames", "HasAttribute",
  "Attribute", "Attributes", "Dataset", "RemoveAttribute", "IsBlock", "HasText",
  "BaseURI", "HasClass", "AddClass", "RemoveClass", "ToggleClass", "CSSSelector",
  "After", "Before", "Append", "Prepend", "ReplaceWith", "Remove",
  "Wrap", "Unwrap", "Clean", "DeepCopy", "DOMTree"};

Global`HTMLElement[el_]["Properties"] := properties;

hasPropertyQ[prop_] := MemberQ[properties, prop];
hasAttributeQ[node_, attr_] := MemberQ[Keys[node["Attributes"]], attr];

HTMLElement::argx = "Property `1` called with the wrong number of arguments.";
HTMLElement::noproperty = "The property `1` does not exist.";

Global`HTMLElement[el_][prop_?hasPropertyQ, ___] := (Message[HTMLElement::argx, prop]; $Failed);
Global`HTMLElement[el_][prop_, __] := (Message[HTMLElement::noproperty, prop]; $Failed);
Global`HTMLElement[el_][attr_?(Not[hasPropertyQ[#]]&)] := If[
  hasAttributeQ[Global`HTMLElement[el], attr],
  Global`HTMLElement[el]["Attribute", attr],
  Message[HTMLElement::noproperty, attr]; $Failed
];

(* http://mathematica.stackexchange.com/questions/59768/how-to-call-a-java-method-that-takes-a-boolean-not-boolean
This may not work on all systems. *)
Global`HTMLElement[el_]["Attribute", key_String, value:(True | False)] := Global`HTMLElement[el@attr[key, value]];

Global`HTMLElement[el_][prop_?Not@*hasPropertyQ] := Global`HTMLElement[el]["Attribute", prop];

ElementProperty[node_Global`HTMLElement, property__] := node[property];
ElementProperty[node_Global`HTMLElement][property__] := node[property];

HTMLSelect[el_Global`HTMLElement, selector_String] := el["Select", selector];
HTMLSelect[selector_String][el_Global`HTMLElement] := el["Select", selector];
HTMLAttribute[el_Global`HTMLElement, attribute_String] := el["Attribute", attribute];
HTMLAttribute[attribute_String][node_Global`HTMLElement] := node["Attribute", attribute];
HTMLAttributes[el_Global`HTMLElement] := el["Attributes"];
HTMLParent[el_Global`HTMLElement] := el["Parent"];
HTMLChildren[el_Global`HTMLElement] := el["Children"];
HTMLSiblings[el_Global`HTMLElement] := el["Siblings"];
HTMLOwnText[el_Global`HTMLElement] := el["OwnText"];
HTMLAllText[el_Global`HTMLElement] := el["AllText"];
HTMLSelectFirst[el_Global`HTMLElement, selector_String] := el["SelectFirst", selector];
HTMLSelectFirst[selector_String][el_Global`HTMLElement] := el["SelectFirst", selector];
HTMLExpectFirst[el_Global`HTMLElement, selector_String] := el["ExpectFirst", selector];
HTMLExpectFirst[selector_String][el_Global`HTMLElement] := el["ExpectFirst", selector];
HTMLClosest[el_Global`HTMLElement, selector_String] := el["Closest", selector];
HTMLClosest[selector_String][el_Global`HTMLElement] := el["Closest", selector];
HTMLSelectXPath[el_Global`HTMLElement, xpath_String] := el["SelectXPath", xpath];
HTMLSelectXPath[xpath_String][el_Global`HTMLElement] := el["SelectXPath", xpath];
HTMLWholeText[el_Global`HTMLElement] := el["WholeText"];
HTMLWholeOwnText[el_Global`HTMLElement] := el["WholeOwnText"];
HTMLDataset[el_Global`HTMLElement] := el["Dataset"];
HTMLCSSSelector[el_Global`HTMLElement] := el["CSSSelector"];
HTMLTree[el_Global`HTMLElement] := el["DOMTree"];

(* DOM Tree *)
colors = <|
    "background" -> RGBColor[{1, 1, 1}],
    "tag" -> RGBColor[{117, 5, 126}/255 // N],
    "attributes" -> RGBColor[{137, 73, 0}/255 // N],
    "arguments" -> RGBColor[{46, 42, 171}/255 // N],
    "glue" -> RGBColor[{163, 148, 165}/255 // N],
    "doctype" -> RGBColor[{192, 192, 192}/255 // N],
    "comment" -> RGBColor[{68, 111, 44}/255 // N],
    "url" -> RGBColor[{47, 82, 203}/255 // N],
    "text" -> RGBColor[{54, 60, 68}/255 // N],
    "highlight" -> RGBColor[{236, 241, 252}/255 // N],
    "searchSelected" -> <|"background" -> RGBColor[{255, 248, 196}/255 // N]|>,
    "selected" -> <|
        "background" -> RGBColor[{79, 118, 216}/255 // N],
        "tag" -> RGBColor[{1, 1, 1}],
        "attributes" -> RGBColor[{200, 201, 203}/255 // N],
        "arguments" -> RGBColor[{1, 1, 1}],
        "glue" -> RGBColor[{157, 160, 167}/255 // N],
        "doctype" -> RGBColor[{1, 1, 1}],
        "comment" -> RGBColor[{1, 1, 1}],
        "url" -> RGBColor[{1, 1, 1}],
        "text" -> RGBColor[{1, 1, 1}]
        |>
    |>;

c::invalidColor = "The color specification `1` is not recognized.";
Options[c] = {"Selected" -> False};
c[s_String, type_String, OptionsPattern[]] := If[
  StringMatchQ[type, "tag" | "attributes" | "arguments" | "glue" | "doctype" | "comment" | "url" | "text"],
  If[OptionValue["Selected"],
    ToString[Style[s, colors["selected", type]], StandardForm],
    ToString[Style[s, colors[type]], StandardForm]
  ],
  Message[c::invalidColor, type]; ""
];
cs[s_String, type_String] := c[s, type, "Selected" -> True];

c[attributes_Association, c_: c] := StringJoin[KeyValueMap[StringJoin[
      " ",
      c[#, "attributes"],
      c["=\"", "glue"],
      If[# == "href" || # == "src",
        ToString[MouseAppearance[Hyperlink[c[#2, "url"], #2, ActiveStyle -> Underlined], "LinkHand"], StandardForm],
        c[#2, "arguments"]
      ],
      c["\"", "glue"]
    ] &, attributes]];
cs[attributes_Association] := c[attributes, cs];

elementDescription[el_, c_: c] /; InstanceOf[el, "org.jsoup.nodes.Element"] := If[
  el@childNodeSize[] > 0,
  StringJoin[
    c["<", "glue"],
    c[el@tagName[], "tag"],
    c[elementAttributes[el]],
    c[">\[Ellipsis]</", "glue"],
    c[el@tagName[], "tag"],
    c[">", "glue"]
  ],
  StringJoin[
    c["<", "glue"],
    c[el@tagName[], "tag"],
    c[elementAttributes[el]],
    c["/>", "glue"]
  ]
];

elementDescription[el_, ___] /; InstanceOf[el, "org.jsoup.nodes.TextNode"] := If[StringMatchQ[el@text[], Whitespace], Nothing, el@text[]];
elementDescription[el_, ___] /; InstanceOf[el, "org.jsoup.nodes.DataNode"] := el@getWholeData[];

elementOpen[el_, c_: c] := StringJoin[
  c["<", "glue"],
  c[el@tagName[], "tag"],
  c[elementAttributes[el]],
  c[">", "glue"]
];

elementClose[el_, c_: c] := StringJoin[
  c["</", "glue"],
  c[el@tagName[], "tag"],
  c[">", "glue"]
];

elementAttributes[el_] := Module[{attrs},
  attrs = <|#@getKey[] -> #@getValue[] & /@ el@attributes[]@asList[]@toArray[]|>;
  If[KeyExistsQ[attrs, "href"] && el@baseUri[] != "", attrs["href"] = el@attr["abs:href"]];
  If[KeyExistsQ[attrs, "src"] && el@baseUri[] != "", attrs["src"] = el@attr["abs:src"]];
  attrs
];

elementChildren[el_] := el@childNodes[]@toArray[];

attachEventHandler[element_, root_, ID_, refreshTree_] := Item[
  EventHandler[element, {
    {"MouseClicked", 1} :> (
      root["searchSelected"] = Null;
      If[sameNodeQ[root["selected"], ID], root["selected"] = Null, root["selected"] = ID];
      refreshTree[]
    )
  }, Method -> "Queued", PassEventsDown -> True],
  Alignment -> Left,
  If[sameNodeQ[root["selected"], ID],
    Background -> If[sameNodeQ[root["searchSelected"], ID], colors["searchSelected", "background"], colors["selected", "background"]],
    ## &[]
  ]
] /; InstanceOf[ID, "org.jsoup.nodes.Element"];

attachEventHandler[el_, root_, ID_, _] /; InstanceOf[ID, "org.jsoup.nodes.TextNode"] := Item[
  el,
  Alignment -> Left,
  If[domTreeSearchTextNodeQ[root, ID], Background -> colors["searchSelected", "background"], ## &[]]
];
attachEventHandler[Nothing[], root_, ID_, _] /; InstanceOf[ID, "org.jsoup.nodes.TextNode"] := Nothing;
attachEventHandler[el_, root_, ID_, _] /; InstanceOf[ID, "org.jsoup.nodes.DataNode"] := Item[el, Alignment -> Left];

sameNodeQ[node1_, node2_] := JavaObjectQ[node1] && JavaObjectQ[node2] && TrueQ[SameObjectQ[node1, node2]];

domTreeCurrentMatch[root_] := If[
  ListQ[root["matches"]] && IntegerQ[root["current"]] && 1 <= root["current"] <= Length[root["matches"]],
  root["matches"][[root["current"]]],
  Missing["NotFound"]
];

domTreeSearchElementQ[root_, node_] := With[{match = domTreeCurrentMatch[root]}, AssociationQ[match] && sameNodeQ[root["searchSelected"], match["Element"]] && sameNodeQ[match["Element"], node]];
domTreeSearchTextNodeQ[root_, node_] := With[{match = domTreeCurrentMatch[root]}, AssociationQ[match] && sameNodeQ[root["searchSelected"], match["Element"]] && sameNodeQ[match["TextNode"], node]];

domTreeDescendants[node_] := Prepend[Flatten[domTreeDescendants /@ elementChildren[node]], node];

domTreeSearchMatches[el_, query_String] := Module[{textNodes, matchingNodes},
  If[StringTrim[query] === "", Return[{}]];
  textNodes = Select[domTreeDescendants[el], InstanceOf[#, "org.jsoup.nodes.TextNode"] && !StringMatchQ[#@text[], Whitespace] &];
  matchingNodes = Select[textNodes, StringContainsQ[#@text[], query, IgnoreCase -> True] &];
  Fold[
    Function[{matches, textNode},
      With[{element = textNode@parent[]},
        If[AnyTrue[matches, sameNodeQ[#Element, element] &], matches, Append[matches, <|"Element" -> element, "TextNode" -> textNode|>]]
      ]
    ],
    {}, matchingNodes
  ]
];

domTreePath[el_, target_] := Module[{node = target, path = {}},
  While[node =!= Null,
    AppendTo[path, node];
    If[sameNodeQ[node, el], Break[]];
    node = node@parent[]
  ];
  If[path =!= {} && sameNodeQ[Last[path], el], path, {}]
];

domTreeVisibleRows[node_, openQ_, depth_:0] /; InstanceOf[node, "org.jsoup.nodes.Element"] := Module[{children = elementChildren[node]},
  If[children === {},
    {<|"Kind" -> "Element", "Node" -> node, "Depth" -> depth|>},
    If[TrueQ@openQ[node],
      Join[
        {<|"Kind" -> "Open", "Node" -> node, "Depth" -> depth|>},
        Flatten[domTreeVisibleRows[#, openQ, depth + 1] & /@ children],
        {<|"Kind" -> "Close", "Node" -> node, "Depth" -> depth|>}
      ],
      {<|"Kind" -> "Summary", "Node" -> node, "Depth" -> depth|>}
    ]
  ]
];
domTreeVisibleRows[node_, _, depth_:0] /; InstanceOf[node, "org.jsoup.nodes.TextNode"] := If[
  StringMatchQ[node@text[], Whitespace], {}, {<|"Kind" -> "Text", "Node" -> node, "Depth" -> depth|>}
];
domTreeVisibleRows[node_, _, depth_:0] /; InstanceOf[node, "org.jsoup.nodes.DataNode"] := {<|"Kind" -> "Data", "Node" -> node, "Depth" -> depth|>};
domTreeVisibleRows[_, _, ___] := {};

domTreeRowHeight[fontSize_] := Max[18, fontSize + 6];

domTreeRowBackground[row_, root_] := Module[{kind = row["Kind"], node = row["Node"]},
  Which[
    MemberQ[{"Open", "Summary", "Element"}, kind] && domTreeSearchElementQ[root, node], colors["searchSelected", "background"],
    kind === "Text" && domTreeSearchTextNodeQ[root, node], colors["searchSelected", "background"],
    domTreeSearchElementQ[root, node], None,
    InstanceOf[node, "org.jsoup.nodes.Element"] && sameNodeQ[root["selected"], node], colors["selected", "background"],
    True, None
  ]
];

setDOMTreeNodeOpen[root_, node_, value_, refreshTree_] := (
  root[node] = TrueQ[value];
  refreshTree[];
  Null
);

domTreeOpener[root_, node_, refreshTree_] := With[{targetNode = node},
  Opener[Dynamic[TrueQ[root[targetNode]], (setDOMTreeNodeOpen[root, targetNode, #, refreshTree]) &]]
];

renderDOMTreeRow[row_, root_, refreshTree_] := Module[{kind = row["Kind"], node = row["Node"], indent, opener, content},
  indent = Spacer[row["Depth"] 18];
  opener = If[MemberQ[{"Open", "Summary"}, kind],
    domTreeOpener[root, node, refreshTree],
    Spacer[12]
  ];
  content = Switch[kind,
    "Open", attachEventHandler[If[sameNodeQ[root["selected"], node] && !domTreeSearchElementQ[root, node], elementOpen[node, cs], elementOpen[node]], root, node, refreshTree],
    "Close", attachEventHandler[If[sameNodeQ[root["selected"], node] && !domTreeSearchElementQ[root, node], elementClose[node, cs], elementClose[node]], root, node, refreshTree],
    "Summary" | "Element", attachEventHandler[If[sameNodeQ[root["selected"], node] && !domTreeSearchElementQ[root, node], elementDescription[node, cs], elementDescription[node]], root, node, refreshTree],
    "Text" | "Data", attachEventHandler[elementDescription[node], root, node, refreshTree]
  ];
  Item[
    Pane[Row[{indent, opener, content}, BaselinePosition -> Baseline], ImageSize -> {Automatic, root["rowHeight"]}, Alignment -> {Left, Center}],
    Alignment -> Left,
    Background -> domTreeRowBackground[row, root]
  ]
];

renderDOMTreeRows[rows_, root_, refreshTree_] := Grid[List /@ (renderDOMTreeRow[#, root, refreshTree] & /@ rows), Alignment -> Left, Spacings -> {0, 0}];

domTreeResultLabel[root_] := If[root["matches"] === {}, "0 / 0", ToString[root["current"]] <> " / " <> ToString[Length@root["matches"]]];

setDOMTreeEventMode[root_, showSearch_] := SetOptions[root["notebook"], NotebookEventActions -> {
  {"MenuCommand", "FindExpression"} :> beginDOMTreeSearch[root, showSearch]
}];

beginDOMTreeSearch[root_, showSearch_] := (
  showSearch[True];
  FrontEnd`MoveCursorToInputField[root["notebook"], "jsoupLinkDOMTreeSearch"]
);

selectDOMTreeMatch[root_, index_Integer, refreshTree_:(Null &)] := Module[{count = Length@root["matches"], match, path, rows, rowPosition},
  If[count === 0, Return[Null]];
  root["current"] = Mod[index - 1, count] + 1;
  match = root["matches"][[root["current"]]];
  root["selected"] = match["Element"];
  root["searchSelected"] = match["Element"];
  path = domTreePath[root["treeRoot"], match["Element"]];
  Scan[(root[#] = True) &, path];
  rows = domTreeVisibleRows[root["treeRoot"], TrueQ[root[#]] &];
  rowPosition = FirstPosition[rows, row_ /; sameNodeQ[row["Node"], match["TextNode"]], Missing["NotFound"]];
  If[!MissingQ[rowPosition], root["scrollPosition"] = {0, Max[0, (First[rowPosition] - 3) root["rowHeight"]]}];
  refreshTree[];
  Null
];

submitDOMTreeSearch[root_, refreshTree_:(Null &)] := (
  root["matches"] = domTreeSearchMatches[root["treeRoot"], root["query"]];
  If[root["matches"] === {},
    root["current"] = 0;
    root["selected"] = Null;
    root["searchSelected"] = Null;
    refreshTree[],
    selectDOMTreeMatch[root, 1, refreshTree]
  ];
  Null
);
submitDOMTreeSearch[root_, query_String, refreshTree_:(Null &)] := (root["query"] = query; submitDOMTreeSearch[root, refreshTree]);

navigateDOMTreeSearch[root_, delta_Integer, refreshTree_:(Null &)] := If[root["matches"] =!= {}, selectDOMTreeMatch[root, root["current"] + delta, refreshTree], Null];

initializeDOMTree[root_, showSearch_] := (
  root["notebook"] = EvaluationNotebook[];
  setDOMTreeEventMode[root, showSearch]
);

Options[tree] = {
  "Width" -> 1400,
  "Height" -> 480,
  "FontSize" -> 12
};
tree[el_, OptionsPattern[]] := DynamicModule[{root, searchQuery = "", searchVisible = False, treeRevision = 0},
  root[_] := False;
  root["selected"] := Null;
  root["searchSelected"] := Null;
  root["treeRoot"] = el;
  root["query"] = "";
  root["matches"] = {};
  root["current"] = 0;
  root["scrollPosition"] = {0, 0};
  root["fontSize"] = OptionValue["FontSize"];
  root["rowHeight"] = domTreeRowHeight[root["fontSize"]];
  With[{refreshTree = Function[treeRevision++]}, Deploy@Panel[Column[{
      Dynamic@Pane[Row[{
        Button["Copy node", CopyToClipboard[Global`HTMLElement[root["selected"]]], Enabled -> (root["selected"] =!= Null)],
        Button["Copy CSS selector", CopyToClipboard[root["selected"]@cssSelector[]], Enabled -> (root["selected"] =!= Null)]
      }]],
      Dynamic[
        If[searchVisible, Row[{
          InputField[Dynamic[searchQuery], String, BoxID -> "jsoupLinkDOMTreeSearch", FieldHint -> "Search text", FieldSize -> 36, ContinuousAction -> True, BaseStyle -> {Editable -> True, Selectable -> True}],
          Button["Search", submitDOMTreeSearch[root, searchQuery, refreshTree]],
          Button["prev", navigateDOMTreeSearch[root, -1, refreshTree], Enabled -> Dynamic[root["matches"] =!= {}]],
          Button["next", navigateDOMTreeSearch[root, 1, refreshTree], Enabled -> Dynamic[root["matches"] =!= {}]],
          Spacer[8],
          Dynamic@domTreeResultLabel[root]
        }], Spacer[0]],
        TrackedSymbols :> {searchVisible}
      ],
      Pane[Dynamic[
        treeRevision;
        renderDOMTreeRows[domTreeVisibleRows[el, TrueQ[root[#]] &], root, refreshTree],
        TrackedSymbols :> {treeRevision},
        SynchronousUpdating -> False
      ],
        Scrollbars -> True,
        ScrollPosition -> Dynamic[root["scrollPosition"]],
        BaseStyle -> {Background -> White, FontSize -> OptionValue["FontSize"], Editable -> False, Selectable -> False},
        ImageSize -> {OptionValue["Width"], OptionValue["Height"]},
        FrameMargins -> 20
      ]
    }]]],
  Initialization :> initializeDOMTree[root, Function[value, searchVisible = value]]
];

Options[popup] = {
  "WindowWidth" -> 1420,
  "WindowHeight" -> 560,
  "Width" -> 1400,
  "Height" -> 480,
  "FontSize" -> 12
};
popup[el_, opts: OptionsPattern[]] := CreateDocument[tree[el, opts],
  "CellInsertionPointCell" -> Cell[],
  Deployed -> False,
  Editable -> True,
  Selectable -> True,
  ShowCellBracket -> False,
  WindowFrame -> "Generic",
  WindowSize -> {OptionValue["WindowWidth"], OptionValue["WindowHeight"]},
  WindowTitle -> None,
  WindowToolbars -> {}
];

End[]; (* End Private Context *)

EndPackage[]
