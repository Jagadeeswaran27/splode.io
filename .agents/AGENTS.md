# Workspace Rules

## Agent Rule

1. Do not run the flutter app through CLI. This should only be run by the author.
2. Do not go inside the /credentials folder unless the author gives the permission.

## Widget Rules

- **Modular Widgets**: Widgets must be aggressive about modularity. Break down complex widgets into smaller, reusable components.
- **Reusable Widgets**: Aggressively extract common UI patterns (like dividers, text prompts, buttons, etc.) into reusable widgets in `lib/core/widgets/` to avoid code duplication across screens. Always check if a widget exists before building a new one.
- **File Length**: Files should not be lengthy. Keep files concise (aim for under 200–250 lines). If a file grows too large, extract components or logic into separate files inside a `widgets/` subdirectory to maintain readability and modularity.

## Import Ordering

Imports in Dart/Flutter files must strictly follow this 4-group order, separated by empty lines:

### Imports should always use absolete path, not relative path

1. Dart SDK imports (e.g., `import 'dart:async';`, `import 'dart:ui';`, `import 'dart:math';`)
2. *Empty Line*
3. Flutter framework imports (e.g., `import 'package:flutter/material.dart';`, `import 'package:flutter/services.dart';`)
4. *Empty Line*
5. External package imports (e.g., `import 'package:flutter_riverpod/flutter_riverpod.dart';`, `import 'package:google_fonts/google_fonts.dart';`)
6. *Empty Line*
7. Local file imports using absolute package paths (e.g., `import 'package:narrata/core/widgets/bouncy_button.dart';`, no relative paths)

## Git Workflow Rules

- **No Automatic Commits or Pushes**: Never automatically run `git commit` or `git push`. Always leave modified code and changes uncommitted in the local working tree so the user can inspect, commit, and push them manually.
