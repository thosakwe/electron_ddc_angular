import 'package:angular/src/source_gen/source_gen.dart';
import 'package:angular/src/transform/stylesheet_compiler/transformer.dart';
import 'package:angular_compiler/angular_compiler.dart';
import 'package:build_barback/build_barback.dart';
import 'package:build_compilers/build_compilers.dart';
import 'package:build_runner/build_runner.dart';
import 'package:build_test/builder.dart';
import 'package:glob/glob.dart';

const String package = 'app';

// Specify the entry point here.
const List<String> inputs = const [
  'web/main.dart',
];

final PackageGraph packageGraph = new PackageGraph.forThisPackage();

final CompilerFlags flags = new CompilerFlags(genDebugInfo: true, entryPoints: [
  new Glob('web/main.dart'),
]);

// Add additional builders here.
final List<BuilderApplication> builderApplications = [
  apply(
    'angular',
    'angular',
    [
      (_) => const TemplatePlaceholderBuilder(),
      (_) => createSourceGenTemplateCompiler(flags),
      (_) => new TransformerBuilder(new StylesheetCompiler(flags), {
            '.css': ['.css.dart', '.css.shim.dart']
          }),
    ],
    toAll([
      toPackage('angular'),
      toDependentsOf('angular'),
    ]),
  ),

  // Run all dependencies.
  apply(
    'build_compilers',
    'ddc',
    [
      (_) => new ModuleBuilder(),
      (_) => new UnlinkedSummaryBuilder(),
      (_) => new LinkedSummaryBuilder(),
      (_) => new DevCompilerBuilder(),
    ],
    toAllPackages(),
    isOptional: true,
  ),

  // Compile the entry point(s).
  applyToRoot(
    new DevCompilerBootstrapBuilder(),
    inputs: inputs,
  ),
];
