#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Welcome to the OpenWrt ucode Package Template Setup!${NC}"
echo "This script will customize the template for your new package."
echo ""

# 1. Get Package Name
read -p "Enter your new package name (e.g., ucode-mod-mytool): " PKG_NAME
if [ -z "$PKG_NAME" ]; then
    echo "Package name cannot be empty."
    exit 1
fi

# 2. Get Maintainer Info
read -p "Enter Maintainer Name (e.g., Jane Doe): " MAINTAINER_NAME
read -p "Enter Maintainer Email (e.g., jane@example.com): " MAINTAINER_EMAIL

# 3. Get Description
read -p "Enter a short description for the package: " PKG_TITLE

echo ""
echo "Configuration:"
echo "  Package:    $PKG_NAME"
echo "  Maintainer: $MAINTAINER_NAME <$MAINTAINER_EMAIL>"
echo "  Title:      $PKG_TITLE"
echo ""
read -p "Is this correct? (y/n) " CONFIRM
if [[ $CONFIRM != "y" ]]; then
    echo "Aborted."
    exit 1
fi

echo -e "\n${GREEN}Applying changes...${NC}"

# Update Makefile
sed -i "s/^PKG_NAME:=.*/PKG_NAME:=$PKG_NAME/" Makefile
sed -i "s/^PKG_MAINTAINER:=.*/PKG_MAINTAINER:=$MAINTAINER_NAME <$MAINTAINER_EMAIL>" Makefile
sed -i "s/^define Package\/.*\$/define Package\/$PKG_NAME/" Makefile
sed -i "s/^\s*TITLE:=.*/  TITLE:=$PKG_TITLE/" Makefile
sed -i "s/^\s*My ucode library/$PKG_TITLE/" Makefile # For description

# Update CMakeLists.txt
sed -i "s/project(ucode_native_modules C)/project($(echo $PKG_NAME | tr '-' '_') C)/" src/CMakeLists.txt

# Update README.md (Naive replacement, but effective)
sed -i "s/ucode-mod-mylib/$PKG_NAME/g" README.md
sed -i "s/My ucode library/$PKG_TITLE/g" README.md

# Update dev.mk (It extracts from Makefile, but just in case of hardcoded comments)
# No changes needed for dev.mk as it is dynamic!

# Rename source file example
if [ -f src/mymodule.c ]; then
    mv src/mymodule.c src/$(echo $PKG_NAME | sed 's/ucode-mod-//').c || true
fi

# Rename ucode script example
if [ -f files/usr/share/ucode/mylib.uc ]; then
    mv files/usr/share/ucode/mylib.uc files/usr/share/ucode/$(echo $PKG_NAME | sed 's/ucode-mod-//').uc || true
fi

# Update test file
if [ -f test/unit/mylib_test.uc ]; then
    mv test/unit/mylib_test.uc test/unit/$(echo $PKG_NAME | sed 's/ucode-mod-//')_test.uc || true
    # Update imports in the test file
    sed -i "s/from 'mylib'/from '$(echo $PKG_NAME | sed 's/ucode-mod-//')'/" test/unit/*_test.uc
fi

# Update native test file
if [ -f test/unit/native_test.uc ]; then
    # Update imports in the native test file
    sed -i "s/from 'mymodule'/from '$(echo $PKG_NAME | sed 's/ucode-mod-//')'/" test/unit/native_test.uc
fi

# Update GitHub workflows
find .github/workflows -name "*.yml" -exec sed -i "s/ucode-mod-mylib/$PKG_NAME/g" {} \;

echo -e "${GREEN}Done!${NC}"
echo "You can now delete this script and start developing."
echo "Run: rm setup.sh"
