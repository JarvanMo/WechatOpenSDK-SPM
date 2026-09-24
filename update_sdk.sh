#!/usr/bin/env bash
# 用法: ./update_sdk.sh 2.0.8
# 下载指定版本的微信 OpenSDK XCFramework，替换仓库中的 WechatOpenSDK.xcframework 并提交。
set -euo pipefail

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
  echo "用法: $0 <版本号>   例如: $0 2.0.8" >&2
  exit 1
fi
if [[ ! "$VERSION" =~ ^[0-9]+(\.[0-9]+)*$ ]]; then
  echo "版本号格式不正确: $VERSION" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
FRAMEWORK_NAME="WechatOpenSDK.xcframework"
URL="https://dldir1.qq.com/WechatWebDev/opensdk/XCFramework/OpenSDK${VERSION}.zip"
ZIP_FILE="$ROOT_DIR/OpenSDK${VERSION}.zip"
WORK_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$WORK_DIR"
  rm -f "$ZIP_FILE"
}
trap cleanup EXIT

cd "$ROOT_DIR"

echo "==> 下载 $URL"
curl -fL --retry 3 -o "$ZIP_FILE" "$URL"

echo "==> 解压"
unzip -q "$ZIP_FILE" -d "$WORK_DIR"

NEW_FRAMEWORK="$(find "$WORK_DIR" -type d -name "$FRAMEWORK_NAME" -not -path '*/__MACOSX/*' -prune | head -n 1)"
if [[ -z "$NEW_FRAMEWORK" ]]; then
  echo "压缩包中未找到 $FRAMEWORK_NAME" >&2
  exit 1
fi

echo "==> 替换 $FRAMEWORK_NAME"
rm -rf "$ROOT_DIR/$FRAMEWORK_NAME"
mv "$NEW_FRAMEWORK" "$ROOT_DIR/$FRAMEWORK_NAME"
find "$ROOT_DIR/$FRAMEWORK_NAME" -name '.DS_Store' -delete

echo "==> 删除 zip"
rm -f "$ZIP_FILE"

echo "==> 提交"
git add -A "$FRAMEWORK_NAME"
if git diff --cached --quiet; then
  echo "没有变化，无需提交（可能已是 $VERSION）"
  exit 0
fi
git commit -m "framework to $VERSION"

echo "==> 完成: 已更新到 $VERSION"
