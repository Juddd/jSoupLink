# Building jsoupLink 1.1.3

The supported build environment is Wolfram Language 12.3 or later with the `PacletTools` paclet. The release artifact is produced by one command from the repository root:

```bash
./scripts/build.wls
```

The script calls `PacletBuild` once and writes the result to `build/jsoupLink-1.1.3.paclet`. It fails unless the manifest and extracted archive contain all required package, Java, icon, and documentation files. It also verifies that the archived jsoup JAR has the same SHA-256 hash as the source JAR and rejects obsolete entry files or JAR versions.

Run the source regression suite with:

```bash
WolframKernel -noinit -noprompt -run 'report=TestReport["Tests/jsoupLink.wlt"]; success=Length[report["TestsSucceededKeys"]]; failed=Total[Length[report[#]]&/@{"TestsFailedWrongResultsKeys","TestsFailedWithMessagesKeys","TestsNotEvaluatedKeys"}]; Print[<|"Succeeded"->success,"FailedOrSkipped"->failed|>]; If[success===103&&failed===0,Exit[0],Exit[1]]'
```

Run the final archive through a fresh, isolated user paclet repository with:

```bash
./scripts/test-isolated-install.sh
```

The isolation script uses a temporary `WOLFRAM_USERBASE`; it does not install the test paclet into the normal user repository.

## Updating jsoup

The bundled dependency is `Java/jsoup-1.23.1.jar`, downloaded from Maven Central. After replacing it, update the filename in `PacletInfo.wl`, `Kernel/jsoupLink.wl`, the build assertions, and the dependency hashes in the README. A successful `PacletBuild` alone is not sufficient: the extracted `.paclet` and a fresh-kernel class load must both pass.
