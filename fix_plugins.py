import os, glob, re

# Fix all plugin build.gradle files: add namespace and kotlinOptions
for f in glob.glob(os.path.expanduser('~/.pub-cache/hosted/pub.dev/*/android/build.gradle')):
    try:
        with open(f, 'r') as fh:
            content = fh.read()
        if 'android {' not in content:
            continue
        modified = False
        if 'namespace' not in content:
            content = content.replace('android {', 'android {\n    namespace "com.plugin.fix"', 1)
            modified = True
        if 'kotlinOptions' not in content and 'kotlin-android' in content:
            # Add kotlinOptions before the last closing brace of android block
            idx = content.rfind('}')
            if idx > 0:
                content = content[:idx] + '    kotlinOptions {\n        jvmTarget = "1.8"\n    }\n' + content[idx:]
                modified = True
        if modified:
            with open(f, 'w') as fh:
                fh.write(content)
            print(f'Fixed: {f}')
    except Exception as e:
        print(f'Error {f}: {e}')

# Also fix build.gradle.kts files
for f in glob.glob(os.path.expanduser('~/.pub-cache/hosted/pub.dev/*/android/build.gradle.kts')):
    try:
        with open(f, 'r') as fh:
            content = fh.read()
        if 'namespace' not in content and 'android {' in content:
            content = content.replace('android {', 'android {\n    namespace = "com.plugin.fix"', 1)
            with open(f, 'w') as fh:
                fh.write(content)
            print(f'Fixed kts: {f}')
    except Exception as e:
        print(f'Error {f}: {e}')

print('Done')
