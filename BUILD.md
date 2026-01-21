# Building the Plugin

This plugin includes a build script to create a distributable ZIP file ready for WordPress.org submission or manual installation.

## Usage

### Using the bash script (recommended)

```bash
# Build without version bump
./build.sh --no-bump

# Build with patch version bump (default)
./build.sh --patch

# Build with minor version bump
./build.sh --minor

# Build with major version bump
./build.sh --major

# Or just use default (patch bump)
./build.sh
```

This will:
1. Extract the plugin name and version from `quotes-collection.php`
2. Create a temporary `build/` directory
3. Copy all necessary files (excluding development files)
4. Create a ZIP file in the `dist/` directory
5. Clean up the temporary build directory

The resulting ZIP file will be named `{plugin-name}.zip` and can be found in the `dist/` directory.

### Using npm (if you have Node.js installed)

```bash
# Build without version bump
npm run build

# Build with patch version bump
npm run build:patch

# Build with minor version bump
npm run build:minor

# Build with major version bump
npm run build:major

# Release (patch bump)
npm run release
```

All npm commands run the same `build.sh` script with appropriate flags.

## Version Bumping

The build script can automatically bump the version number for you:

**Patch bump (default)**: `2.5.3` → `2.5.4`
- Use for bug fixes, small improvements
- Run: `./build.sh` or `./build.sh --patch`

**Minor bump**: `2.5.3` → `2.6.0`
- Use for new features, backward-compatible changes
- Run: `./build.sh --minor`

**Major bump**: `2.5.3` → `3.0.0`
- Use for breaking changes, major rewrites
- Run: `./build.sh --major`

The script automatically updates the version in:
- `quotes-collection.php` (Plugin file)
- `package.json` (NPM config)

## What Gets Included

The build script includes the following files and directories:

- `blocks/` - Block editor blocks
- `css/` - Stylesheets
- `examples/` - Example files
- `inc/` - PHP classes
- `js/` - JavaScript files
- `languages/` - Translation files
- `*.php` - All PHP files in root
- `*.txt` - readme.txt
- `LICENSE` - License file
- `screenshot-*.png` - Plugin screenshots
- `quotes-collection.json` - Example JSON data

## What Gets Excluded

- Development files (`.git`, `.DS_Store`, etc.)
- `uninstall.php` (development only)
- `languages/README.md` (not needed in distribution)

## Output

The build process creates:

- `dist/{plugin-name}.zip` - The distributable ZIP file

Example output:
```
Building Quotes_Collection v2.5.3 alpha 1...
Cleaning up old builds...
Copying files...
Creating ZIP archive...
Build complete!
ZIP file: dist/Quotes_Collection.zip
Size: 480K
Cleaning up build directory...
Done!
```

## Distribution

Once built, you can:

1. Upload to WordPress.org (if you have commit access)
2. Upload to your own WordPress site via Plugins → Add New → Upload Plugin
3. Share the ZIP file for others to install manually

## Notes

- The plugin version is automatically extracted from the main plugin file
- The build script creates a clean build every time (it doesn't cache)
- Make sure the `build.sh` script has execute permissions: `chmod +x build.sh`
