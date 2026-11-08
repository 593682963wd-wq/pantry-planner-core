"""作者：Wangyuan；日期：2026-10-29；职责：编译并运行无界面Swift领域组件。"""
import json,subprocess,tempfile
from pathlib import Path

def run(payload):
    if not isinstance(payload,dict):raise TypeError('输入须对象')
    with tempfile.TemporaryDirectory() as d:
        binary=Path(d)/'planner';sources=sorted((Path(__file__).parent/'Sources').glob('*.swift'))
        subprocess.run(['swiftc',*[str(x) for x in sources],'-o',str(binary)],capture_output=True,text=True,check=True,timeout=120)
        result=subprocess.run([str(binary)],input=json.dumps(payload),capture_output=True,text=True,timeout=15)
        if result.returncode:raise ValueError('Swift输入校验失败')
        return json.loads(result.stdout)
