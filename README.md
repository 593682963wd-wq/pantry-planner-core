# 食材与周计划Swift组件

保留食材/食谱模型、紧急度、覆盖率排序、库存消耗、五日计划与购物差额组件；不带原iOS界面或真实库存。

## 使用

Python 3.11+。在本目录建立独立虚拟环境：

```sh
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements.txt
.venv/bin/python cli.py example.json
.venv/bin/python -m unittest discover -v
```

`example.json`从零编写，仅含虚构输入。可以显式提供自己的同结构JSON文件。输出默认为终端；`--output result.json`使用独占创建，避免覆盖已有结果。CLI失败退出码2。

## 数据与边界

不发现本机账号、不读取环境中的模型密钥、不发送消息、不请求远端数据。只处理调用方明确传入的文件、记录或参数。合成示例不代表任何实际业务结果。需Swift工具链；测试为Foundation命令行组件，未执行iOS UI、持久化用户库存或真机验收。

## 发布状态

本项目源码采用 MIT 许可证，见 LICENSE。依赖按各自上游许可使用，安装的依赖/模型/字体/媒体不随此源码目录分发。

## 2026-11-08 候选修订

- 各餐共享剩余库存，每份库存仅抵扣一次。
- 库存和采购按名称+单位匹配，异单位保持不同列表身份。
- 规范化同名同单位批次累加，使用最早到期日，避免重复字典键崩溃。

使用包内合成样例复跑；发布集合根目录的 `verify_release.py --project personal-ios-useitup` 会依次执行测试和首次使用命令。原有版本的测试计数属于当时记录，本轮汇总以集合验证报告为准。
