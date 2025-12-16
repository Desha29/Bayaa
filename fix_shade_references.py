#!/usr/bin/env python3
"""
Fix .shade references on AppColors constants by replacing with .withOpacity()
"""

import re
import os
from pathlib import Path

def fix_shade_references(filepath):
    """Fix .shade references in a Dart file."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return False
    
    original_content = content
    
    # Replace AppColors.*.shade50 with .withOpacity(0.1)
    content = re.sub(r'AppColors\.(\w+)\.shade50', r'AppColors.\1.withOpacity(0.1)', content)
    
    # Replace AppColors.*.shade100 with .withOpacity(0.15)
    content = re.sub(r'AppColors\.(\w+)\.shade100', r'AppColors.\1.withOpacity(0.15)', content)
    
    # Replace AppColors.*.shade200 with .withOpacity(0.3)
    content = re.sub(r'AppColors\.(\w+)\.shade200', r'AppColors.\1.withOpacity(0.3)', content)
    
    # Replace AppColors.*.shade300 with .withOpacity(0.4)
    content = re.sub(r'AppColors\.(\w+)\.shade300', r'AppColors.\1.withOpacity(0.4)', content)
    
    # Replace AppColors.*.shade600 with main color (no opacity)
    content = re.sub(r'AppColors\.(\w+)\.shade600', r'AppColors.\1', content)
    
    # Replace AppColors.*.shade700 with main color (darker - use as-is)
    content = re.sub(r'AppColors\.(\w+)\.shade700', r'AppColors.\1', content)
    
    # Replace AppColors.*.shade800 with main color (darker - use as-is)
    content = re.sub(r'AppColors\.(\w+)\.shade800', r'AppColors.\1', content)
    
    # Fix remaining Colors.amber references
    content = re.sub(r'Colors\.amber\.shade50', 'AppColors.warningColor.withOpacity(0.1)', content)
    content = re.sub(r'Colors\.amber\.shade200', 'AppColors.warningColor.withOpacity(0.3)', content)
    content = re.sub(r'Colors\.amber\.shade800', 'AppColors.warningColor', content)
    content = re.sub(r'Colors\.amber', 'AppColors.warningColor', content)
    
    if content != original_content:
        try:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✓ Fixed: {filepath}")
            return True
        except Exception as e:
            print(f"Error writing {filepath}: {e}")
            return False
    
    return False

def main():
    """Main function."""
    project_root = Path(r'd:\Work\crazy_phone_pos')
    features_dir = project_root / 'lib' / 'features'
    
    dart_files = list(features_dir.rglob('*.dart'))
    print(f"Fixing .shade references in {len(dart_files)} files...")
    print()
    
    updated_count = 0
    for filepath in dart_files:
        if fix_shade_references(filepath):
            updated_count += 1
    
    print()
    print(f"✓ Complete! Fixed {updated_count} files")

if __name__ == '__main__':
    main()
