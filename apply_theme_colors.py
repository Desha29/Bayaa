#!/usr/bin/env python3
"""
Batch script to replace common hardcoded colors with AppColors constants
across all Dart files in the features directory.
"""

import re
import os
from pathlib import Path

# Color mappings: hardcoded -> AppColors constant
COLOR_REPLACEMENTS = {
    # Common hardcoded hex colors
    r'Color\(0xFFFF6B35\)': 'AppColors.primaryColor',
    r'Color\(0xFFD4AF37\)': 'AppColors.primaryColor',
    r'Color\(0xFFD4A05A\)': 'AppColors.primaryColor',
    
    # Flutter Colors
    r'Colors\.blue(?:Accent)?': 'AppColors.primaryColor',
    r'Colors\.purple': 'AppColors.primaryColor',
    r'Colors\.pink': 'AppColors.accentGold',
    r'Colors\.orange(?:Accent)?': 'AppColors.warningColor',
    r'Colors\.yellow': 'AppColors.warningColor',
    r'Colors\.red(?:Accent)?': 'AppColors.errorColor',
    r'Colors\.green': 'AppColors.successColor',
    r'Colors\.grey(?:\[(?:600|700)\])?': 'AppColors.mutedColor',
    r'Colors\.teal': 'AppColors.accentGold',
}

IMPORT_LINE = "import 'package:crazy_phone_pos/core/constants/app_colors.dart';\n"

def process_file(filepath):
    """Process a single Dart file to replace colors."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return False
    
    original_content = content
    modified = False
    
    # Apply color replacements
    for pattern, replacement in COLOR_REPLACEMENTS.items():
        if re.search(pattern, content):
            content = re.sub(pattern, replacement, content)
            modified = True
    
    # Add import if AppColors is used but not imported
    if modified and 'AppColors' in content:
        if "import 'package:crazy_phone_pos/core/constants/app_colors.dart'" not in content:
            # Find the last import statement
            import_match = list(re.finditer(r"^import ['\"].*?['\"];?\s*$", content, re.MULTILINE))
            if import_match:
                last_import = import_match[-1]
                insert_pos = last_import.end()
                content = content[:insert_pos] + '\n' + IMPORT_LINE + content[insert_pos:]
                modified = True
    
    # Write back if modified
    if modified and content != original_content:
        try:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✓ Updated: {filepath}")
            return True
        except Exception as e:
            print(f"Error writing {filepath}: {e}")
            return False
    
    return False

def main():
    """Main function to process all Dart files."""
    project_root = Path(r'd:\Work\crazy_phone_pos')
    features_dir = project_root / 'lib' / 'features'
    
    if not features_dir.exists():
        print(f"Features directory not found: {features_dir}")
        return
    
    dart_files = list(features_dir.rglob('*.dart'))
    print(f"Found {len(dart_files)} Dart files in features directory")
    print("Processing...")
    print()
    
    updated_count = 0
    for filepath in dart_files:
        if process_file(filepath):
            updated_count += 1
    
    print()
    print(f"✓ Complete! Updated {updated_count} files")

if __name__ == '__main__':
    main()
