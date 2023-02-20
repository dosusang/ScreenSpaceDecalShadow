# ScreenSpaceDecalShadow
# 使用ScreenSpaceDecal来给角色创建阴影，逆向崩坏3得到的做法
# 基本思路：以灯光视角渲出阴影图，使用decal投影到地表，stencil排除角色
主要代码见：BoxShadow.cs
