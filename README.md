# WechatOpenSDK-SPM

## 更新 SDK

腾讯发布新版本后，在仓库根目录运行：

```sh
./update_sdk.sh 2.0.8
```

脚本会依次：

1. 检查本地 `main` 是否落后于远端（落后则退出，需先 `git pull --rebase`），以及该版本的 tag 是否已存在（存在则退出）
2. 从 `https://dldir1.qq.com/WechatWebDev/opensdk/XCFramework/OpenSDK<版本号>.zip` 下载 SDK
3. 解压并替换 `WechatOpenSDK.xcframework`，删除 zip 和 `.DS_Store`
4. 提交 `framework to <版本号>`，打 tag `<版本号>`，并把 `main` 和 tag 一起推送（`--atomic`）

如果下载的 framework 与仓库中完全一致，脚本不会提交，也不会打 tag。
