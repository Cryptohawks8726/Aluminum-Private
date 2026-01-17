import 'dart:io';

import 'package:ffigen/ffigen.dart';

void main() {
  final packageRoot = Platform.script.resolve('../');
  FfiGenerator(
    output: Output(
      dartFile: packageRoot.resolve('lib/ntcore/ntcore.g.dart'),
      style: DynamicLibraryBindings(wrapperName: 'NTCoreLibrary'),
    ),
    headers: Headers(
      entryPoints: [packageRoot.resolve('ntcore_headers/entry.h')],
      // Tells clang to search src/include for <> includes
      // May also have trouble finding system headers - on linux I had to set CPATH to clang's system headers.
      compilerOptions: [
        '-I${packageRoot.resolve('ntcore_headers/include').toFilePath()}',
      ],
    ),
    globals: .includeAll,
    functions: .includeAll,
    structs: .includeAll,
    typedefs: .includeAll,
    unions: .includeAll,
    // caused a crash with an invalid NT_Type being returned so this is disabled for safety.
    enums: .excludeAll,
    macros: .includeAll,
  ).generate();
}
